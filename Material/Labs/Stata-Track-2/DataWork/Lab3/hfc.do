/* *************************************************************************** *
*						Lab Session 4							  			   *
*																 			   *
*  PURPOSE:  			This solution file is a suggested solution 			   *
						for how the file might look in the end of 			   *
						the excercise. 										   *
																			   *
																			   *
																			   *
*  WRITEN BY:  			Michael	Orevba	  									   *
*  Last time modified:  June 2018											   *
*																			   *
********************************************************************************


********************************************************************************
* 							PART 1: SETTINGS
********************************************************************************/



   * Project folder globals
   * ---------------------
	global folder		"${Lab4}"
	global output 		"${Lab4_outRaw}/HFC checks.xls" 							// This is where the HFCs will be stored
	global enumerators   pl_id_09 id_05 key submissiondate enumerator_ID

/*********************************************************************************

	** OUTLINE:		Load data
				CHECK 1:  HH ID duplicates
				CHECK 2:  Length of survey (minutes)
				CHECK 3:  No Plots were selected
				CHECK 4:  Farmer has no seasonal crops
				CHECK 5:  Equipment rent upper limit
				Save reports

** REQUIRES:	$projectfolder\data\endline_data_raw.dta

** CREATES:		Issues flags based on enumerator performance

********************************************************************************
* 								Load data
*******************************************************************************/

	*Open endline raw data set
    use "${Lab4_dtInt}/endline_data_raw.dta", clear
	gen blank = ""

	* Start flags count from zero
	local 	num_flags = 0

	* Create blank file to add observations

		putexcel	set "${output}", sheet("HH flags") replace
		putexcel	A1 = ("pl_id_09")							///				   District name
					B1 = ("id_05")								///				   HHID
					C1 = ("key") 								///				   Unique submission ID
					D1 = ("submissiondate") 					///				   Submission date
					E1 = ("enumerator_ID") 						///				   ID of the enumerator
					F1 = ("question") 							///				   Question number in questionnaire
					G1 = ("variable")							///				   Name of the variable in the data set
					H1 = ("value")								///				   Original value of variable
					I1 = ("issue")								///				   Description of the issue with the observation
					J1 = ("correction")							///				   Column for field teams to add correct values -- leave blank
					K1 = ("initials")							// 				    ID of people who added corrections

  * Clean up time variables

		gen start = trim( ///
						subinstr( ///
							subinstr( ///
								substr(starttime,strpos(starttime,"2018")+4,.) ///
							,"AM","",.) ///
						,"PM","",.) ///
						)

		gen end = trim( ///
						subinstr( ///
							subinstr( ///
								substr(endtime,strpos(endtime,"2018")+4,.) ///
							,"AM","",.) ///
						,"PM","",.) ///
						)

		gen start_clock = clock(start,"hms")
		gen end_clock = clock(end,"hms")
		replace end_clock = end_clock + 12*60*60*1000 if end_clock < start_clock

*-------------------------------------------------------------------------------
* 						Check 1: HH duplicates
*-------------------------------------------------------------------------------

* Check ID

	* Export duplicated entries list
	ieduplicates  id_05, folder("${Lab4_outRaw}") ///
						uniquevars(key) keepvars(${enumerators})

*-------------------------------------------------------------------------------
* 						Check 2: Length of survey (minutes)
*-------------------------------------------------------------------------------

	 preserve

		*Gen survey time length
		gen survey_time = (end_clock-start_clock)/(1000*60) // Time is in minutes

		*Check if there are any such observations
		qui count if survey_time > 0											// All survey times
		replace survey_time=round(survey_time,.02)
		sum survey_time, d

		* If there are, export them
		if r(N) > 0 {

			* Keep these observations
			keep if survey_time < r(p5)

			* Add information about this issue
			local theMean = string(round(`r(mean)',.01))									// restrict mean to 2 decimal places
			gen question 	= "`theMean'" 													// Question number
			gen variable 	= "survey_time"													// Name of the variable
			gen issue 		= "outlier is below 5th percentile from average survey time"	// Describe the issue

			* This is used to identify in which line of the report the observations
			* will be added
			local input = `num_flags' + 2
			local num_flags = `num_flags' + _N

			* Export observations
			export excel 	${enumerators} variable question survey_time issue 	///			// $identifiers in defined in do file '0. Set globals'
							using `"${output}"', ///
							sheet("HH flags", modify) cell("A`input'")

		}

	restore


*-------------------------------------------------------------------------------
* 						Check 3: No Plots were selected
*-------------------------------------------------------------------------------

	preserve

		*Check if there are any such observations
		qui count if numplots == 0 														// Association is part of PROIRRI, but HH doesn't have any irrigated plots
		sum numplots, d

		* If there are, export them
		if r(N) > 0 {

			* Keep these observations
			keep if numplots == 0

			*This commands allows to input comment into excel sheet before delivery
			local input 	= `num_flags' + 2
			local num_flags	= _N + `num_flags'

			* Add information about this issue
			local theMean = string(round(`r(mean)',.01))								// restrict mean to 2 decimal places
			gen question 	= "`theMean'" 												// Question number
			gen variable 	= "numplots"												// Name of the variable
			gen issue 		= "Number of Plots selected is Zero"			 			// Describe the issue

			*This outputs the new set of flags to the HH flags excel sheet
			export excel 	${enumerators} variable question numplots issue ///			// $identifiers in defined in do file '0. Set globals'
							using `"${output}"', ///
							sheet("HH flags", modify) cell("A`input'")

		}

	restore


*-------------------------------------------------------------------------------
* 						Check 4: Farmer has no seasonal crops
*-------------------------------------------------------------------------------

	preserve

		*Create total seasonal crops
		egen total_crops = rowtotal(ag9n_16*)

		*Check if there are any such observations
		qui count if total_crops == 0 														// Association is part of PROIRRI, but HH doesn't have any irrigated plots
		sum total_crops, d

		* If there are, export them
		if r(N) > 0 {

			* Keep these observations
			keep if total_crops == 0

			*This commands allows to input comment into excel sheet before delivery
			local input 	= `num_flags' + 2
			local num_flags	= _N + `num_flags'

			* Add information about this issue
			local theMean = string(round(`r(mean)',.01))								// restrict mean to 2 decimal places
			gen question 	= "`theMean'" 												// Question number
			gen variable 	= "total_crops"												// Name of the variable
			gen issue 		= "Total Seasonal Crops Planted is Zero"			 		// Describe the issue

			*This outputs the new set of flags to the HH flags excel sheet
			export excel 	${enumerators} variable question total_crops issue ///		// $identifiers in defined in do file '0. Set globals'
							using `"${output}"', ///
							sheet("HH flags", modify) cell("A`input'")

		}

	restore

*-------------------------------------------------------------------------------
* 						Check 5: Agricultural Equipment rent upper limit
*-------------------------------------------------------------------------------

	preserve

		*Check if there are any such observations
		drop if exp_18==. | exp_18 < 0	// restricts to HH that rent agriculture equipment
		qui count if exp_18 > 0

		* If there are, export them
		if r(N) > 0 {

			keep if exp_18 > 100000

			* Add information about this issue
			gen question = "exp_18"
			gen variable = "Rent of purchase agricultural equipment"
			gen issue 	 = "Rent or purchase of equipment is greater than 100,000 Francs"

			*This commands allows to input comment into excel sheet before delivery
			local input 	= `num_flags' + 2 		// This contains the total number of flags
			local num_flags	= _N + `num_flags'

			*This outputs the new set of flags to the HH flags excel sheet
			export excel 	${enumerators} variable question exp_18 issue ///		// $identifiers in defined in do file '0. Set globals'
							using `"${output}"', ///
							sheet("HH flags", modify) cell("A`input'")
		}

	restore



******************* End do-file ****************************************************
