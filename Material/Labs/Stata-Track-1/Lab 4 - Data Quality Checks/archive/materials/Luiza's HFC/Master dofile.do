/*******************************************************************************
*								MOZ LANDSCAPES 								   *
*   					  SURVEY HIGH FREQUENCY CHECKS						   *
*   							   2017										   *
********************************************************************************
	
			0. BEFORE RUNNING THE CHECKS:
				0.1 Import the data from Survey CTO
				0.2 Create a variable stamping the import date
				0.3 Ensure that text fields are always imported as strings, 
					with "" for missing values. Note that we treat "calculate" 
					fields as text -- you can destring later if you wish
				0.4 Edit the file path to the raw data in line XXX
				0.4 Edit "Change formats" do-file so that all variables are in a 
					format consistent with these checks
	
			1.	INITIAL CHECKS
				
				1.1 Check for duplicates
				1.2 Check number of incomplete interviews
				1.3 Check for consent
				1.4 Check progress (number of completed surveys per interest group)
					Create server logbook 
					Match server and field logbooks
					Check if date settings on the tablets are accurate
					
	
			2.	ENUMERATORS CHECKS
				
				2.1 List uploaded surveys by enumerator on last survey day		
				2.2 Total number of households surveyed by enumerator
				2.3 Total number of surveys completed by enumerator
				2.4 Average survey duration by enumerator
				2.5 Share of don't knows and refusals
					Check the percentage of obs giving each answer for key filter questions
					Average skips by enumerator
					
			3.	SURVEY CHECKS
				
				3.1 Share of variables with all missing observations per section
				3.2 Identify variables that only contain missing values
				3.3 Check variables that should never be missing
				3.4 Check other values to recategorize
				3.5 Check key variables for outliers 
					Check that no variable has only a single value
					Check survey logic/internal consistency	- Needs to be survey specific
					Check variables constraints
					Check if rosters opened
					Check number of roster observations
			
			BACK CHECKS
				
				Select back check sample
				Run bcstats
				
	
********************************************************************************
* 							Set initial configurations
*******************************************************************************/

	ieboilstart, version(14.0)
	`r(version)'

********************************************************************************
* 								Set folder paths
******************************************************************************** 	
	
	* Set file path
	if "`c(username)'" == "wb501238" {
		global HFC 		"C:\Users\WB501238\Documents\GitHub\HFC"
	}	
	
	global logbook	"$HFC/Logbooks"
	global raw		"$HFC/Raw data"
	global output	"$HFC/Output"
	global dofiles	"$HFC/Do-files"

	
********************************************************************************
*								PART 0: Set options
********************************************************************************

	* Install packages: only need to be run once
	local install_packages 	0
	
	* Observations to be checked:
	* --------------------------
	global completeOnly		1													// Check only observations with completed interviews
	global allObs			0													// Make it one if checks should run on all observations
	global lastDay			1													// If you want the checks to run only on observations submitted
	global lastDayChecked	0													// If you want the checks to run on observations submitted from a specific day onwards add tC value of that day here
	

*-------------------------------------------------------------------------------
*							INITIAL CHECKS
*-------------------------------------------------------------------------------
	
	/* Identify duplicated IDs
	   -----------------------
	Creates an excel file with duplicated ID reports, or one excel file per team of 
	enumerators, if teamVar is defined, and removes duplicated ID observations
	
	Requires the following globals to be defined: 
	$idVar $dateVar $startVar $endVar $keyVar $enumeratorVar */	
	global	dup_ids			0
	
	/* Identify duplicated surveys
	   ---------------------------
	Some surveyors might send a form, reopen it and change the respondent ID only
	Use variables that record the starting date and time for each module. 
	in the programming you should have a field calculate_here that record the exact time
	when starting each module of the questionnaire
	
	Requires the following globals to be defined: 
	$idVar $dateVar $startVar $endVar $keyVar $enumeratorVar issuesVarList */	
	global 	dup_times		0													// Some surveyors might send a form, reopen it and change the respondent ID only
		
	/* Check how many interviews were not finished
	   -------------------------------------------
	Requires the following globals to be defined: $completeVar	
	Optinal globals: $teamVar $progresVars */
	global  finished		0
	
	* Check for survey consent. Throws a warning and lists any households that
	* were interviewed without consent
	global 	consent			0
		
	/* Count number of surveys completed per key variables
	   ---------------------------------------------------
	Requires the following globals to be defined: 	$progressVars $completeVar 
	Optional: create varname_goal, a numeric variable with the intended number of observations for each group of each variable in progressVars*/
	global 	progress		0
	
	
*-------------------------------------------------------------------------------
*							ENUMERATORS CHECKS
*-------------------------------------------------------------------------------
	
	* Export a list of all households submitted by each enumerator
	global	enum_ids		0	
		
	* Count number of households approached and surveyed per enumerator
	global 	enum_count		0
		
	* Count number of surveys completed per enumerator
	global 	enum_finish		0
		
	* Check duration of key sections per enumerator
	global 	enum_duration	0
		
	* Check share of don't knows and refusals to answer per enumerator
	global	enum_ref		1

*-------------------------------------------------------------------------------
*							SURVEY CHECKS
*-------------------------------------------------------------------------------

	/* Check if there are any devices with inaccurate dates setting
	   ------------------------------------------------------------
	This may create problems in different checks  
	   
	Requires the following globals to be defined: 	$progressVars $completeVar 
	Optional: create varname_goal, a numeric variable with the intended number of observations for each group of each variable in progressVars*/
	global 	progress		0
	
	* Calculate share of variables with all missing observations per section
	global survey_section	0
	
	* Identify variables that only have missing variables
	global survey_missvar	0
	
	* Check variables that should never be missing
	global survey_nomiss	0
	
	* Check other values to recategorize
	global survey_other		0
	
	* Identify outliers in key questions
	global survey_outliers	0
	
********************************************************************************
*								PART 0: Set options
********************************************************************************

*-------------------------------------------------------------------------------
*							BASIC CHECKS
*-------------------------------------------------------------------------------

	* Identify observations
	global idVar 			hhid					// Uniquely identifying variable
	global locationVars		district_id village_id	// District, village, school, etc
	global startVars		start_mod*
	
	* Define date variable
	global dateVar			submissiondate			// Date of survey submission
	global startVar			starttime				// Date when survey started
	global endVar			endtime					// Date when survey ended
	global keyVar			key						// Server ID (key)
	
	* Identify percentiles to be flagged
	global lowerPctile 		20						// Lower tail: choose 0 to not flag any lower tails
	global upperPctile		80						// Upper tail: choose 100 to not flag any upper tails
	
	* List variables to be displayed in the issues report. They will be displayed
	* in the same order as below. Add any other variables you want to be displayed
	* to the following line
	global issuesVarList 	issue idStr $locationVars $enumeratorVar dateStr startStr endStr $keyVar
	
	
*-------------------------------------------------------------------------------
*							ENUMERATOR CHECKS
*-------------------------------------------------------------------------------

	global teamVar 			""						// ID for team of enumerators
	global enumeratorVar	id_03					// ID for enumerators
	
	global consentVar		consent					// Variable that indicates if HH consented to being surveyed
	global consentYesVar	consent_yes				// Equals one if household consented to survey
	global completeVar		complete				// Equals on if survey was completed
	
	global durationList		duration				// List the names of all duration variables to be checked. We suggest including duration of consent 
	
	global dkCode			-88						// Code for "don't know"
	global refCode			-66						// Code for "refuse to answer"
		
*-------------------------------------------------------------------------------
*							PROGRESS CHECKS
*-------------------------------------------------------------------------------

	global progressVars		village_id district_id	// List the names of all categories across which you want to check survey progress, e.g., village, district, gender.
	
	* Observation goals
	gen village_id_goal = 15

	
*-------------------------------------------------------------------------------
*							SURVEY CHECKS
*-------------------------------------------------------------------------------

	global surveyYear		2017
	global surveyMonths		1 // 9,10,11
	global hhRoster1		ros_
	global hhRoster2		b_
	global plotRoster		c_
	global cropRoster		d_
	global incomeSec		e_
	global questionVars		"${hhRoster1}* ${hhRoster2}* ${plotRoster}* ${cropRoster}* ${incomeSec}*"
	global sectionsList		hhRoster1 hhRoster2 plotRoster cropRoster incomeSec
	
	global nomissVarList	// List variables that should never be missing

	global otherVarList		// List of 'other' variables
	
	global outliersVarList	// Lit of variables to check for outliers
	
	

********************************************************************************
*								Run checks
********************************************************************************

	if `install_packages' {
		ssc install bcstats, replace
		ssc install ietoolkit, replace
		ssc install labutil, replace
	}
	
	use "$raw/data.dta", clear													// Load your raw data here
	
	qui do "$dofiles/Change formats.do"
	qui do "$dofiles/Calculate inputs.do"
	qui do "$dofiles/Initial checks.do"
	qui do "$dofiles/Enumerator checks.do"
	qui do "$dofiles/Survey checks.do"
	
	
********************************************************************************
*								Export results
********************************************************************************

	capture confirm file "$output/Raw files/issues.dta" 
	if !_rc {
		use "$output/Raw files/issues.dta", clear
		export excel using "$output\Final documents\Issues report.xls", firstrow(varlabels) replace
		erase "$output/Raw files/issues.dta"
	}
	