/*******************************************************************************	
*		DIME ANALYTICS :   
*		HFC TEMPLATE
********************************************************************************
** PURPOSE: 	This do-file gathers all the data quality checks to run on the 
				incoming data during the field.

** REQUIRES:    the raw dataset (right after running the IMPORT CTO dofile) 


								
**Written by:	Aurelie Rigaud
******************************************************************************/

*SETTINGS
clear all


if c(version)==14 {
set rng kiss32 
}


***set directories
if c(username)=="wb424141" {
gl data "\Users\wb424141\Dropbox\Ghana SLM"
}

*Aurelie's directories: 
	gl data "D:\Dropbox\Ghana SLM"
	
	*open the dta
*use "${data}\Survey\Data-Test\TEST4\SLWMP_training_short n long.dta"

set maxvar 30000
use "${data}\DATA Baseline\SLWMP_survey_FINAL.dta", clear


*SET THE GLOBALs
	*Variables to display in case of problem
		gl problem "district community respondent_id respondent_name phone_mobile enumerator_id enumerator_name " 
			
	*Consent to participate to the survey
	global consent "consent==1"

**CHECK the IMPORTDATE
	*IMPORTANT : after running the CTO import dofile, create the variable that will filter
		* the data you check every day. You don't want to check the data you already checked
	  cap gen importDate = "`c(current_date)'"
		replace importDate = "`c(current_date)'" if importDate == ""
		
		
		
*_______________________________________________________________________________
*                                                                              *
*   					 CHECKS TO RUN ON THE WHOLE DATASET                    *
*______________________________________________________________________________*		
		

		

**********   ***RECODE ENUMERATOR ID AND NAMES ************************************


replace enum="Lisare David" 			if enumerator_id=="041" | enumerator_id=="41" 
replace enum="Samuel Akugidumah A." 	if enumerator_id=="040" | enumerator_id=="40"
replace enum="Abubakar Abdul-Basit" 	if enumerator_id=="025" | enumerator_id=="25"
replace enum="Ayogaane A Maxwell" 		if enumerator_id=="037" | enumerator_id=="37"
replace enum="Eric A. Atongdewe" 		if enumerator_id=="039" | enumerator_id=="39"
replace enum="Kankwah Rufus Bama" 		if enumerator_id=="030" | enumerator_id=="30" 
replace enum="Mohammed J.Fuseini" 		if enumerator_id=="031" | enumerator_id=="31" 
replace enum="Alhaji Y.Fuseini" 		if enumerator_id=="028" | enumerator_id=="028"
replace enum="Ajuik Theophillus" 		if enumerator_id=="036" | enumerator_id=="36" 
replace enum="Amoyea Francis" 			if enumerator_id=="026" | enumerator_id=="26" 
replace enum="Ali Musah" 				if enumerator_id=="046" | enumerator_id=="46" 
replace enum="Basit Yahaya" 			if enumerator_id=="032" | enumerator_id=="32" 
replace enum="Adam Adirikah Yuri" 		if enumerator_id=="027" | enumerator_id=="27" 
replace enum="Anamjongya Gerald" 		if enumerator_id=="042" | enumerator_id=="42"
replace enum="Abunka Alhassan" 			if enumerator_id=="044" | enumerator_id=="44"
replace enum="Amadu I. Atusi" 			if enumerator_id=="043" | enumerator_id=="43"
replace enum="Joseph A. Takora" 		if enumerator_id=="52" | enumerator_id=="052"
replace enum="George A. Atanga" 		if enumerator_id=="051" | enumerator_id=="51" 
replace enum="Godwin Abindabs" 			if enumerator_id=="045" | enumerator_id=="45" 

replace enum="Nathaniel Ankunkura" 		if enumerator_id=="047" | enumerator_id=="47"
replace enum="Amadu Abdul-Razak" 		if enumerator_id=="038" | enumerator_id=="38"
replace enum="A.W.Abdul-Majeed" 		if enumerator_id=="029" | enumerator_id=="29"



***********  STANDARDIZE the MISING VALUES AND OTHERS ************************

*Ensure that text fields are always imported as strings (with "" for missing values)
*(Note that we treat "calculate" fields as text; you can destring later if you wish)
*(the CTO import dofile might cover some of these cleaning)

	tempvar ismissingvar
	quietly: gen `ismissingvar'=.
	forvalues i = 1/100 {
		if "`text_fields`i''" ~= "" {
			foreach svarlist in `text_fields`i'' {
				foreach stringvar of varlist `svarlist' {
					quietly: replace `ismissingvar'=.
					quietly: cap replace `ismissingvar'=1 if `stringvar'==.
					cap tostring `stringvar', format(%100.0g) replace
					cap replace `stringvar'="" if `ismissingvar'==1
				}
			}
		}
	}
	quietly: drop `ismissingvar' /*quietly sans le montrer*/


**SAVE THE RAW DATASET 
save "dataset RAW.dta", replace
	// you want a raw dataset that includes all the mistakes, discrepencies
	// duplicates, just in case. 
	

************************************************************************
**********  PART 1    - ROUTINE AND LOGIC CHECKS         ***************
************************************************************************

	
*1*_________ CHECK ALL INTERVIEWS ARE COMPLETE
	generate incomplete = missing(endtime)
	display "Displaying incomplete interviews:"
	list ${problem} if incomplete == 1

	
	
*2*__________ CHECK THE DUPLICATES ON UNIQUE IDs
	replace respondent_id = upper(respondent_id)
	replace respondent_name = lower(respondent_name)
	
	list ${problem} if respondent_id!=respondent_id_confirm    
			//make sure you have a variable in your programming that ask confirmation of the IDs
			//and check if both are consistent
																			
	list ${problem} if respondent_id!=""
	
**2.1: the duplicates tag way
	duplicates tag respondent_id if respondent_id!="", generate(dup)
	display "Displaying unique ID duplicates:"
	list ${problem} if dup ==1
	duplicates list respondent_id if respondent_id!=""
		

	duplicates tag respondent_name if respondent_id=="", generate(dup2)
	display "Displaying respondent names duplicates:"
	list ${problem} if dup2==1
	duplicates list respondent_name if respondent_id==""
	
	drop dup dup2
	
	**2.2: the cond way
	sort respondent_id
	quietly by respondent_id: gen dup2 = cond(_N==1,0,_n)
	sort importDate
	list ${problem} importDate old_form dup2 dup if dup2>0 & dup2!=. 
	
	tab dup2	
	
	*save the dataset with the dup
	save "dataset with dup_IDs.dta", replace
	
	drop if dup2>0   // remove the duplicates
	
	*another similar check:	
	isid respondent_id 				// if nothing displayed, no duplicates
	duplicates list respondent_id


	
*3*_________ CHECK THE DUPLICATES ON STARTING DATES AND TIME

	  /*Some surveyors might send a form, reopen it and change the respondent ID only
		Use variables that record the starting date and time for each module. 
		in the programming you should have a field calculate_here that record the exact time
		when starting each module of the questionnaire: 
		calculate_here start_mod_b1 : once(format-date-time(now(), '%Y-%b-%e %H:%M:%S'))
		*/
		
		quietly by start_mod_b1 start_mod_b2: gen dup_date = cond(_N==1,0,_n)	
		duplicates tag start_mod_b1, generate(dup_date2)
		sort start_mod_b1
		list ${problem} deviceid importDate respondent_id respondent_name2 if dup_date>0
		
		// Use Kris's code in an other dofile to compare the duplicates forms and discrepencies 
		// The device ID should be the same if dup_date>0
		// Send a report to the team with random similar variables between 2 forms
	
		**You keep the duplicates starting date and time for your checks but once you get the report
		** from the team, you delete the "fake" form(s)
	
	
		*save the dataset with the dup
		save "dataset with dup_date.dta", replace     
		
	
*4*__________ DATES CHECKING

*4.1: check date settings on the tablets are accurate
	list ${problem} if start_year != 2017     // report to the enumerators if the dates
	list ${problem} if start_month!="Mar"	 // are not correct on their tablets

	
	gen startdate = dofc(starttime)   //time format
	format startdate %td
	assert month(startdate) == 3
	*gen startyear = year(starttime)
	gen startyear = year(startdate)


	assert year(startdate) == 2017

	/*
	assert year(starttime) == 2017
	gen startyear = year(starttime)
	*/

*4.2: check the starting date is before ending date
	list ${problem} if starttime<endtime
	display "Displaying interviews before the start of data collection:"
	sort respondent_id
	//another similar code:
	list ${problem} startdate if startdate < mdy(1, 1, 2017)


	
*4.3*: * Within the same enumeration area, interview dates should be 
		*close to the same date.

	bysort enumarea: egen mindate = min(startdate)
	by enumarea: egen maxdate = max(startdate)
	display "Displaying interviews in the same enumeration area more than four days apart:"
	sort enumarea startdate id
	list respondent_id enumarea startdate if maxdate > mindate + 4
	drop mindate maxdate
		
	
/*******************************************  THIS CODE IS TO CREATE THE DATES VARIABLES 
	// Should not be necessary if you run the CTO import dofile while downloading the data
	
	
*spliting the STARTING date
	split starttime, force
	rename starttime1 start_month
	rename starttime3 start_year
	rename starttime2 start_day
	replace start_day= subinstr(start_day, ",", "", .)
	rename starttime4 start_time
	destring start_day, replace
	destring start_year, replace


*spliting the ENDING date
	split endtime
	rename endtime2 end_day
	replace end_day= subinstr(end_day, ",", "", .)
	rename endtime3 end_year
	rename endtime1 end_month
	rename endtime4 end_time
	destring end_day end_year, replace

***************************************************************************************/


*5*_______  TRACK THE PERFORMANCES REGARDING THE TARGET
	
*5.1****performances: nbr of surveys received:
	foreach i in team1-team5{           		// enter the variable that distinguishes the different 
	sort district community						//team/area of the surveys
	tab community typesurvey ///
	if enumarea=="`i'" & dup_date==0
	}
	
*5.2 **** Check that a survey matches other records for its unique ID.	
	  //  Example: For each ID, check that the name in the baseline data matches
      // the one in the master tracking list.
	  // This code won't be necessary if you use preload data in your programming
	  //because the name of the respondent will be displayed in the tablet.
	  // however, make sure you have a yes/no question in your programming to confirm the name

		merge id using master_tracking_list, sort uniqusing
		drop if _merge == 2
		drop _merge
		display "Displaying discrepancies with the master tracking list:"
		sort respondent_id startdate starttime
		list respondent_id name tracking_name startdate starttime enumerator if name != tracking_name
		drop variables*   // enter the variables you don't want from the master tracking list dataset
		
		
		
********************************************************************************************
************** PART 2          ENUMERATORS's checks                           ********************
********************************************************************************************

	*Checks tO run without duplicates in the dataset
	
*5.1*  Check enumerator productivity by number of interviews completed and
		* number of responses entered.
	bysort enumerator_id: generate interviews = _N
	generate nonmiss = 0
	quietly ds, has(type numeric)
	foreach var in `r(varlist)' {
		replace nonmiss = nonmiss + cond(`var' != ., 1, 0)
	}
	quietly ds, has(type string)
	foreach var in `r(varlist)' {
		replace nonmiss = nonmiss + cond(`var' != "", 1, 0)
	}
	bysort enumerator_id: egen responses = total(nonmiss)


	/*5.2___CHeck the interviews productivity*/
	egen tag = tag(enumerator_id)
	foreach stat in interviews{
		egen mean = mean(`stat')
		generate diff = `stat' - mean
		generate percdiff = 100 * diff / mean
		format mean diff percdiff %9.1f
		
		display "Displaying number of `stat' by enumerator:"
		sort enumerator_id
		list enumerator_id enumerator_name `stat' mean diff percdiff if tag
		/*drop mean diff percdiff*/
		
		rename mean mean_interviews
		}
		
	export excel uniqueid enumerator_id enumerator_name interviews mean_interviews diff percdiff using "enumerator_hfc.xls" ///
		if tag, firstrow(varl) sheet("interviews", replace) sheetreplace 
		
	drop interviews tag diff percdiff


	/*5.3___CHeck the responses productivity*/
	egen tag = tag(enumerator_id)
	foreach stat in responses{
		egen mean = mean(`stat')
		generate diff = `stat' - mean
		generate percdiff = 100 * diff / mean
		format mean diff percdiff %9.1f
		
		display "Displaying number of `stat' by enumerator:"
		sort enumerator_id
		list enumerator_id enumerator_name `stat' mean diff percdiff if tag
		/*drop mean diff percdiff*/
		
		rename mean mean_responses
		}
	export excel respondent_id enumerator_id enumerator_name responses mean_responses diff percdiff using "enumerator_hfc.xls" ///
		if tag, firstrow(varl) sheet("responses", replace) sheetreplace 
		
		
	*5.4: check the % of don't know / missing value per surveyors for all the surveys	
		
***********************************************************************************************
************* PART 3:            TIME and DURATION  CHECK                           ***********
***********************************************************************************************

	destring duration dur*, replace

	*gen duration per module:
	gen durationA=duration-dura
	gen durationB=durb-dura
	gen durationC0=durc0-durb
	gen durationC=durc-durc0
	gen durationD1=durd1-durc
	gen durationD2=durd2-durd1
	gen durationE=dure-durd2
	gen durationF=durf-dure
	gen durationG=durg-durf
	gen durationS=durs-durg
	gen durationI=duri-durs
	gen durationJK=durjk-duri
	gen durationL=durl-durjk
	gen durationM=durm-durl
	gen durationT=durt-durm

	*in minutes: 
	foreach i in A C0 C D1 D2 E F G S I JK L M T{
	gen dur_`i'=duration`i'/60
	}

	gen duration_tot= duration/60
	sum duration_tot, d

	*  average time per surveyor:
		display "Displaying average duration per module"

	foreach i in A C0 C D1 D2 E F G S I JK L M T{
	bys enumerator_name: sum dur_`i', d
	}

	*  average time per module
	display "Displaying average duration per module"

	foreach i in A C0 C D1 D2 E F G S I JK L M T{
	sum dur_`i', d
	}
	* generate average time per module per surveyor
		display "Displaying average duration per module per surveyor"

	foreach i in A C0 C D1 D2 E F G S I JK L M T{
	sum dur_`i' enumerator_name, d
	}

	*

*_______________________________________________________________________________
*                                                                              *
*   				HECKS TO RUN ON THE LAST SURVEYS RECEIVED                  *
*______________________________________________________________________________*		
		

***FROM HERE, we need only the latest data, the importDate variable filter the data
*  we already checked:
		
	egen mynewdata=group(importDate)
	tab mynewdata, m
	
	*either one of the 2 codes below
	keep if mynewdata>7
	keep if importDate == "Jun 27th, 2017"  
	
			//NOTE: Make sure you never save this dataset.... !!
			

			
			
			
			
			
***************************************************************************
**************  PART 1 -  DISTRIBUTION CHECKS   *********************
***************************************************************************

 * PART 1.1 *   MISING VALUE - DONT KNOW - REFUSE TO ANSWER - OTHER SPECIFY 

 
// recode the missing values, don't know, not ap, other specify
		**-99 > don't know
		**-88 > other specify
		**-77> Not applicable

		ds, has(type numeric)
			foreach var in `r(varlist)' {
				
				replace `var' = .a if `var' == -77
				replace `var' = .b if `var' == -99
				replace `var' = .c if `var' == -88
			}		
			*
		ds, has(type string)
			foreach var in `r(varlist)' {
				replace `var' = ".a" if `var' == "-77"		
				replace `var' = ".b" if `var' == "-99"
				replace `var' = ".c" if `var' == "-88"
			}		
			*	
			*reminder:   +inf < . < .a <.b <.c <... < .z
	


*A*  Check that no variables have only missing values, where missing indicates
* a skip. This could mean that the routing of the CAI survey program was
* incorrectly programmed.

	quietly ds, has(type numeric)
	foreach var in `r(varlist)' {
		quietly count if `var' == .
		if r(N) == _N {
			display "`var' has only missing values."
			describe `var'
		}
	}
	quietly ds, has(type string)
	foreach var in `r(varlist)' {
		quietly count if `var' == ""
		if r(N) == _N {
			display "`var' has only missing values."
			describe `var'
		}
	}

	*

*B* Check that no variable has only a single distinct value.

	foreach var of varlist _all {
		quietly tabulate `var'
		if r(r) == 1 {
			display "`var' has only one distinct value."
			describe `var'
		}
	}


*C* Check the percentage of missing values for each variable, where missing indicates a skip.

	display "Displaying percent missing..."
	quietly ds, has(type numeric)
	foreach var in `r(varlist)' {
		quietly count if `var' == .
		* See -help format- for what "%5.1f" means.
		display "`var':" _column(35) string(100 * r(N) / _N, "%5.1f") "%"
	}
	quietly ds, has(type string)
	foreach var in `r(varlist)' {
		quietly count if `var' == ""
		display "`var':" _column(35) string(100 * r(N) / _N, "%5.1f") "%"
	}


*D*  Check the percentage of "don't know" (DK) and "refusal" (RF) values for each variable.

* If a dataset's "don't know" and "refusal" values are inconsistently

	display "Displaying percent DK/RF..."
	foreach var of varlist _all {
		display "`var':"
		
		capture confirm numeric variable `var'
		if _rc == 0 {
			quietly count if `var' != .
			local nonmiss = r(N)
			quietly count if `var' == .a
			local dkn = r(N)
			quietly count if `var' == .b
			local rfn = r(N)
		}
		else {
			quietly count if `var' != ""
			local nonmiss = r(N)
			quietly count if `var' == "don't know"
			local dkn = r(N)
			quietly count if `var' == "refusal"
			local rfn = r(N)
		}
		
		display "  DK  " string(100 * `dkn' / `nonmiss', "%5.1f") "%"
		display "  RF  " string(100 * `rfn' / `nonmiss', "%5.1f") "%"
	}
*


	
* PART 1.2 *   CONSISTENCIES IN THE SAMPLING OBJECTIVE OF YOUR SURVEY


  // each survey has specific goals to meet, for example: in each community
  // 10 surveys should be conducted, 2 of them on control respondents
  // 20 communities are treatment, 20 other are control > if random walk, the
  // respondent_id should be missing... 
  // some data collection have short survey and long surveys... 
  
  **EXAMPLE OF CHECKS :
	  
	tab community, m
	list ${problem} community if community==.
	gen PES_c=(12<community & community<23)
	gen SLM_c=(community<13)
	gen control_c=(PES_c==0 & SLM_c==0)

	gen longsurvey=(typesurvey==1)
/*
1*no short surveys in SLM or Control communities
2* Random walk farmer don't do short surveys
3* respondent ID is not missing for short survey and long surveys SLM
4* Variable "apply to the treatment programme" cannot be true is control communities 
*/

*1*no short surveys in SLM or Control communities
	list ${problem} longsurvey SLM_c if longsurvey==0 & SLM_c!=0
	list ${problem} longsurvey control_c if longsurvey==0 & control_c!=0

*2* Random walk farmer don't do short surveys
	list ${problem} longsurvey random_walk if longsurvey==0 & random_walk!=0

*3* respondent ID is not missing for short survey and long surveys SLM
	list ${problem} longsurvey respondent_id SLM_c PES_c if longsurvey==0 & respondent_id=="."
	list ${problem} random_walk respondent_id SLM_c PES_c if random_walk==0 & respondent_id=="" 
	
*4*Ao (apply to SLM cannot be true is controls communities
	list  ${problem} random_walk a0 control_c if control_c==1 &  a0==1 & a0!=0
*a0	a0!=.	slm_communit




***************************************************************************
**************     PART 2 -  PROGRAMMING CHECKS        ********************
***************************************************************************


*2.1*    CHECK NO LOOP HAS BEEN OPENED WHILE THEY SHOULD NOT 
*------------------------------------------


		/*This is an important check to do if you use begin repeat group in your programming.
		*ex: household roster, crops, plots, loan: we repeat the same question for each people
		in the household, each crop cultivated, each plot, each loan the respondent has taken.
		
		we need to ensure the number of time the questions were repeated is consistent with 
		the number of people in the household, crops, etc.
	
	
**EXAMPLE 1 :HOUSEHOLD ROSTER LOOP

		
		Variables are required for this check:
		___1*The count repeat variable, that is the nbr of time the loop should be opened
				hh_mems: "how many people live with you?"
				hh_to_repeat : "Nbr of people in total in the household" (hh_mems +1)
								note: you might want to limit the max nbr of time 
								the questions should be repeated: if hh_mems==20 
								fix the max to 12 for example: In your calculate field:
								hh_to repeat should be = if(12<${hh_mems}+1,12,${hh_mems}+1)

								
		___2*The index in the loop, that is the position of the person in the loop
			   hh_index__*: take value 1 to hh_to_repeat
			   
		___3*The label that correspondent to the position, that is the name that identify 
			the item we are talking about in the loop (name of a crop, name of a household...) 
			    hh_label__*: "what is the name of the person?"
			
		__4* 2 variables inside the loop that should never be missing for each HH member:	
				b1_7__*: "what is the age of this person?"
		        b1_8__*: "what is the highest level of education of this person?"

	*/
	
	
	destring hh_to_repeat, replace
	destring hh_number_orig, replace   // add a calculate_here in your programming
									   // to capture the original number entered by the surveyor


			list ${problem} hh_mems hh_to_repeat if hh_to_repeat!=hh_mems+1    // +1 because we add the respondent
			list ${problem} hh_mems hh_number_orig if hh_number_orig!=hh_mems
			list ${problem} hh_mems hh_number_orig if hh_number_orig>hh_mems
			
			*NOTE: It is not a problem if things are displayed here, make sure 
			*		nothing is displayed below:
		
		
	foreach i in 1 - i {     // you will have to update the number i on daily basis. the first day of data 
							// collection the max number of people in the HH might be 5 but later it could
							// be 17.. 
							
	list ${problem} hh_mems hh_index__`i' hh_label__`i' if hh_index__`i'!="" &  hh_label`i'=="" 
	}   //this command shows where the index has been filled while it shouldn't.
		//as long as the loop is not really opened we are good: this check is done with *2*
				
									
*2*value of hh_label__* not missing implies the variables inside the loop are not missing

 		foreach i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17{
		list ${problem}  hh_index__`i' hh_label__`i' b1_7__`i' ///
		if hh_index__`i'!="" & hh_label__`i'=="" & (b1_7__`i'!=. | b1_8__`i'!="")
		} // important: it should not display anything here! 
		
		foreach i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17{
		list ${problem}  hh_index__`i' hh_label__`i' b1_7__`i' ///
		if hh_index__`i'=="" & (b1_7__`i'!=. | b1_8__`i'!="")
		} // important: it should not display anything here! 

		foreach i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17{
		list ${problem}  hh_index__`i' hh_label__`i' b1_7__`i' ///
		if hh_index__`i'!="" & fname_no__`i'!="" & (b1_7__`i'==. | b1_8__`i'=="")
		} // 
		
	
		
	/*
	NOTE: INDEX WILL BE FILLED WITH EVEN IF THE PLOT/ CROPS / Household member / LOAN  HAS BEEN REMOVED
	label is still missing if it has been changed in the first listing questions, (you untick the crops, 
	you change the number of people in the household afterwards...) but later in questions' loop, the loop is opened for the 
	item that has been unticked. Check the index:
	item concerned	*/
	

	
**EXAMPLE 1 :HOUSEHOLD ROSTER LOOP

	
/*	*e_crop        : the multiple select variable that list all the crops cultivated
	*tot_crop      : nbr of crops cultivated
	*crop_index__* : position of the crop in the loop
	*crop_code__*  : value of the crop in the choice list of the multiple 
	                select variable (see choice sheet in the programming for)
	*crop_label__* : name of the crop 
	*e33_2__*      : this var should never be missing for each crop selected
*/
	
	
	*check for each crop selected in e_crop
	foreach i in 1 2 3 4 5 6 {
	list ${problem} tot_crop crop_index__`i' crop_code__`i' crop_label__`i' ///
	if crop_index__`i'!="" &  crop_code__`i'=="" & crop_label__`i'=="" 
	}   //this command shows where the index has been filled while it shouldn't.
		//as long as the loop is not really opened we are good: this check is done with *2*
		
		
	*2*  index of crop not missing implies the var inside the loop is not missing
 		foreach i in 1 2 3 4 5 6{
		list ${problem} tot_crop crop_index__`i' crop_code__`i' crop_label__`i' e33_2__`i'///
		if crop_index__`i'!="" &  crop_code__`i'=="" & crop_label__`i'=="" & e33_2__`i'!=.
		} 		// important: it should not display anything here! 
		
		foreach i in  1 2 3 4 5 6{
		list ${problem} tot_crop crop_index__`i' crop_code__`i' crop_label__`i' e33_2__`i' ///
		if crop_index__`i'=="" & e33_2__`i'!=.
		}
		// important: it should not display anything here! 
		foreach i in 1 2 3 4 5 6{
		list ${problem} tot_crop crop_index__`i' crop_code__`i' crop_label__`i' e33_2__`i' ///
		if crop_index__`i'!="" &  crop_code__`i'!="" & crop_label__`i'!="" & e33_2__`i'==.
		}
		// a loop has been opened and label, code, index are not missing but the questions are missing so we are fine. 
		
		*label of crop not missing implies the var inside the loop is not missing
		foreach i in 1 2 3 4 5 6{
		list ${problem} tot_crop crop_index__`i' crop_code__`i' crop_label__`i'  e33_2__`i'///
		if crop_label__`i'=="" & e33_2__`i'!=.
		} 

			*same code:
			list ${problem} tot_crop crop_index__1 crop_index__2    if (tot_crop=="1" & crop_index__2!="" & crop_code__2!="" & crop_label__2!="")
			list ${problem} tot_crop crop_index__2 crop_index__3    if (tot_crop=="2" & crop_index__3!="")
			list ${problem} tot_crop crop_index__3  crop_index__4  if (tot_crop=="3" & crop_index__4!="")
			list ${problem} tot_crop crop_index__4  crop_index__5  if (tot_crop=="4" & crop_index__5!="")
			list ${problem} tot_crop crop_index__5  crop_index__6  if (tot_crop=="5" & crop_index__6!="")
			list ${problem} tot_crop crop_index__6  crop_index__7  if (tot_crop=="6" & crop_index__7!="")
			list ${problem} tot_crop crop_index__7  crop_index__8  if (tot_crop=="7" & crop_index__8!="")
			list ${problem} tot_crop crop_index__8  crop_index__9  if (tot_crop=="8" & crop_index__9!="")
			
			



*2.2*   SKIPS LOGIC
*------------------------------------------
		/* Check the skips worked correctly througout the questionnaire 
		 they usually work just fine since we test this before the field
		Make sure you write this code with your programming opened before 
		the field, with a fake dataset to run the stata code.
		This is the perfect way to test your  programming
		*/
		

*EXAMPLE:
	list ${problem} var1 var2 if var2==. & var1!=.      
	list ${problem} var5 var6	if var6<10 & var6<0 & var5!=""                 
	
		
	foreach var in b7_e1 b7_e2 b7_e_555 {
	list ${problem} b7_a `var' if (b7_a==0 & `var' !=.) | (b7_a==1 & `var'==.)
	}
	// b7_a is the main variable that does the relevance for variables in var

	*Questions b23 to b27 
	foreach i in 23 24 25 26 27 {
	foreach var in d e f {
	destring b`i'_a b`i'_`var', replace
	list r1 surveyorname b`i'_a b`i'_`var' if ///
	(b`i'_a==0 & b`i'_`var' != .) | (b`i'_a==1 & b`i'_`var' == .)
	}
	} 

	
	
*2.3*   OTHER SPECIFY CHECKs
*-----------------------------------------------------	
	/*Same type of code as above, but you want to check they are not missing 
	when other specify if selected by the surveyors and that what the surveyor 
	entered makes sense.
		TO DO:
		*1 Check skips bugs
		*2 Check the value of the other
	*/
	
		
*Other specify OUT OF a BEGIN REPEAT
	* DISPLAY CROPS INPUTS TECHNOLOGIES SHOCKS NOT ALREADY LISTED in the multiple select variable
		*input: "What are the inputs you apply on your plots?" (this is a multiple select)
		*input__88: dummy==1 if "other specify" was selected in input
		*input_oth: string entered by surveyor. 
		

	*1* check skip bugs
	list ${problem} input input__88 input_oth 				 if input__88==1 & input_oth=="" 		 //inputs
	list ${problem} technologies technologies__88 tech_oth	 if technologies__88==1 & tech_oth==""    //technologies
	list ${problem} crop crop__88 crop_oth 					 if (crop__88==1 & crop_oth=="") 		//crops
	
	*2* checks others:
	list ${problem} input input__88 input_oth 				 if  input_oth!="" 						  //inputs
	list ${problem} technologies technologies__88 tech_oth	 if  tech_oth!=""    //technologies
	list ${problem} crop crop__88 crop_oth 					 if  (crop_oth!="" | crop_oth!="Beans" |  crop_oth!="Bean") //crops

	**CHECK the surveyors don't select other specify to enter "beans" if beans is already in the option choice.
	* Let's try to reduce the cleaning work

	
*Other specify IN A BEGIN REPEAT (in a loop) 
	*In the code below, we check the other specify in the loop for plots, 
	*we use a foreach for each time the other specify was repeated
	
	*1* check skip bugs
		foreach i in 1 2 3 4 {
			list ${problem} plot_to_repeat c18__88__`i' c18_o__`i' if (c18__88__`i'=="1" & c18_o__`i'=="" & ${longsurv})
			list ${problem} plot_to_repeat c13__`i' c13_o__`i'     if (c13__`i'==-88     & c13_o__`i'=="" & ${longsurv})
			list ${problem} plot_to_repeat c12__88__`i' c12_o__`i' if (c12__88__`i'=="1" & c12_o__`i'=="" & ${longsurv})
     		list ${problem} plot_to_repeat c16_u__`i' c16_uo__`i' if c16_u__`i'==-88 & c16_uo__`i'=="" & ${longsurv}
				}
				
	*display otherspec
		foreach i in 1 2 3 4{
			list ${problem} c18__88__`i' c18_o__`i' if c18_o__`i'!=""
			list ${problem} c13__`i' c13_o__`i'     if c13_o__`i'!=""
			list ${problem} c12__88__`i' c12_o__`i' if c12_o__`i'!=""
			list ${problem} c16_u__`i' c16_uo__`i'  if c16_uo__`i'!=""
				}
*
	

	

*2.4*   LOGIC CHECKS VIOLATION 
*-----------------------------------------------------		
	/* In the programming you limit the integer entered by the surveyors with soft checks
		(allow to swipe if the amount entered doesn't respect the constraint) OR with
		hard check (doesn't allow to swipe)
		Double check if these constraints are respected
		NOTE: this check is DIFFERENT that outliers' checks
		*/
		
***  Hard check violations 
**************************************

		*** Question D1 ***
		preserve
		local qnum secdd1
		local violation "> 168"   //set your condition
		local dec 1
		gen hardcheck_`qnum' = (`qnum' `violation') if `qnum' < .

		replace check = "Hard check violation: Question `qnum' (`violation')" if hardcheck_`qnum' > 0
		replace check_code = 120.`dec' if hardcheck_`qnum' > 0
		keep if hardcheck_`qnum' > 0
		drop hardcheck_`qnum'

		tempfile check120pt`dec'
		save `check120pt`dec''
		restore


		*** Question ## ***
		preserve
		local qnum q#
		local violation "> ##"
		local dec # in sequence
		gen hardcheck_`qnum' = (`qnum' `violation') if `qnum' < .

		replace check = "Hard check violation: Question `qnum' (`violation')" if hardcheck_`qnum' > 0
		replace check_code = 120.`dec' if hardcheck_`qnum' > 0
		keep if hardcheck_`qnum' > 0
		drop hardcheck_`qnum'

		tempfile check120pt`dec'
		save `check120pt`dec''
		restore



***  Soft check violations 
**************************************

		*** Question ## ***
		preserve
		local qnum q#
		local violation "> ##"
		local dec # in sequence
		gen softcheck_`qnum' = (`qnum' `violation') if `qnum' < .

		replace check = "Soft check violation: Question `qnum' (`violation')" if softcheck_`qnum' > 0
		replace check_code = 121.`dec' if softcheck_`qnum' > 0
		keep if softcheck_`qnum' > 0
		drop softcheck_`qnum'

		tempfile check121pt`dec'
		save `check121pt`dec''
		restore


		

***************************************************************************
**************     PART 3 -  COMMENTS OF THE TEAM      ********************
***************************************************************************

	/* Read all the comments of your staff. They tell you about the programming
	issues, inconsistencies in questions, skips issues, respondent not understanding 
	the questions. 
	In your programming: make sure you have a comment field after each module of 
	the questionnaire + one general comment field at the end of the questionnaire
	*/

	*check only relevent comments *
	foreach i in 1 2 3 4 5 6{
	replace comment_`i' = . if comment_`i' == "No Comment"
	replace comment_`i' = . if comment_`i' == "No Comments"
	replace comment_`i' = . if comment_`i' == "NO COMMENT"
	replace comment_`i' = . if comment_`i' == "NO COMMENTS"
	replace comment_`i' = . if comment_`i' == "No comment"
	replace comment_`i' = . if comment_`i' == "No comments"
	replace comment_`i' = . if comment_`i' == "NO comment"
	replace comment_`i' = . if comment_`i' == "NO comments"
	replace comment_`i' = . if comment_`i' == "NO Comment"
	replace comment_`i' = . if comment_`i' == "NO Comments"

	replace comment_`i' = . if comment_`i' == "SUCCESSFUL"
	replace comment_`i' = . if comment_`i' == "Completed"
	replace comment_`i' = . if comment_`i' == "completed"
	replace comment_`i' = . if comment_`i' == "Successful"
	replace comment_`i' = . if comment_`i' == "NO"
	replace comment_`i' = . if comment_`i' == "no"
	replace comment_`i' = . if comment_`i' == " NO"
	}

	foreach i in 1 2 3 4 5 6{
	list ${problem} comment_`i' if comment_`i'!=""
	}

	list ${problem} comment_tot if comment_tot!=""


	*


***************************************************************************
**************     PART 4 -  INCONSISTENCIES CHECKS      ********************
***************************************************************************

*PART 4.1: *check the general consistency of the data (content of the questions)
*--------------------------------------	

*1* CROP GIVEN AWAY
	foreach i in 1 2 3 4 5 6{
	display "Displaying interviews with higher crop quantity given to landlord(c37) than harvested (c31)"
	list ${problem} c37__`i' c31__`i' if c37__`i'> c31__`i' & c37__`i'>=0 & c37__`i'!=. & c31__`i'>=0 & c31__`i'!=. & c37_u__`i'==c31_u__`i'
}



*2*  **SIZES CONSISTENCY
	*Total area devoted to any one crop should not be bigger than the total area of all plots
	
	*CROP AREA 
		//3 4 5 6 7 
		foreach i in 1 2 3 4 5 {      //change the value to 0 if mising
		replace c29__`i'=0 if c29__`i'!=. & c29__`i'>=0
		}
			//+c29__3+c29__4+c29__5+c29__6
		gen totarea_crop=c29__1+c29__2 +c29__3+c29__4+c29__5 if typesurvey==1
		//& c29__1!=c29__2

		*drop totarea_crop totarea_plot

	*PLOT AREA
			// 2 3 4 5 6
		foreach i in 1 2 3 4 {      //change the value to 0 if mising
		replace c16__`i'=0 if c16__`i'!=. & c16__`i'>=0
		}
		//+
		gen totarea_plot=c16__1+c16__2+c16__3+c16__4+c16__5
		
	*COMPAR 
		//the unit must be the same: c16_u__1==c16_u__2==c16_u__3==c16_u__4==c16_u__5==c29_u__1==c29_u__2==c29_u__3==c29_u__4==c29_u__5
			list ${problem} totarea_plot totarea_crop if (totarea_crop>totarea_plot) & ///
			(c16_u__1==c29_u__1==c29_u__2==c16_u__5==c16_u__4==c16_u__3==c16_u__2==c29_u__3==c29_u__4)
				display "Displaying interviews where total harvested area> size of the land"

			
*---- total size PLOT ---------

		gen size1=.
		replace size1=c16__1 if typesurvey==1 & c16__2==. & c16_u__1==2   //farmer has 1 plot only
		gen size2=.
		replace size2=c16__1+c16__2 if typesurvey==1 & c16__2!=. & c16__3==. & c16_u__1==2   		//farmer has 2 plot only
		gen size3=.
		replace size3=c16__1+c16__2+c16__3 if typesurvey==1 & c16__2!=. & c16__3!=. & c16__4==. & c16_u__1==2
		gen size4=.
		replace size4=c16__1+c16__2+c16__3+c16__4 if typesurvey==1 & c16__2!=. & c16__3!=. & c16__4!=. & c16__5==. & c16_u__1==2
		gen size5=.
		replace size5=c16__1+c16__2+c16__3+c16__4+c16__5 if typesurvey==1 & c16__2!=. & c16__3!=. & c16__4!=. & c16__5!=. & c16__6==. & c16_u__1==2
		gen size6=.
		replace size6=c16__1+c16__2+c16__3+c16__4+c16__5+c16__6 if typesurvey==1 & c16__2!=. & c16__3!=. & c16__4!=. & c16__5!=. & c16__6!=. & c16_u__1==2
	
		
	
*c29__i: total area for cultivting the crop
*c16__i: total area of all the land
*

*------ SIZE CROPS----------
	
	rename c29__* cropsize__*

	*FOR LONG SURVEY
	
*1 plot:
	foreach i in 1 2 3 4 5 6{
	list ${problem} tot_plot size1 cropsize__`i' c29_u__`i' c16_u__1 crop_label__`i' if (cropsize__`i'>size1 & size1!=. & cropsize__`i'!=. & c29_u__`i'==2)
	}
	 order tot_plot size1 c16_u__1 size2 c16_u__2 size3 c16_u__3 size4 c16_u__4  cropsize__1 c29_u__1 cropsize__2 c29_u__2 cropsize__3 c29_u__3 cropsize__4 c29_u__4
	br respondent_name enumerator_id community tot_plot size1 c16_u__1 size2 c16_u__2 size3 c16_u__3 size4 c16_u__4  cropsize__1 c29_u__1 cropsize__2 c29_u__2 cropsize__3 c29_u__3 cropsize__4 c29_u__4

*2 plots
	foreach i in 1 2 3 4 5 6{
	list ${problem} size2 cropsize__`i' c29_u__`i' c16_u__2 crop_label__`i' if (cropsize__`i'>size2 & size2!=. & cropsize__`i'!=. & c29_u__`i'==2)
	}
**3 plots
	foreach i in 1 2 3 4 5 6{
	list ${problem} size3 cropsize__`i' c29_u__`i' c16_u__3 crop_label__`i' if (cropsize__`i'>size3 & size3!=. & cropsize__`i'!=. & c29_u__`i'==2)
	}
*4 plots
	foreach i in 1 2 3 4 5 6{
	list ${problem} size4 cropsize__`i' c29_u__`i' c16_u__4 crop_label__`i' if (cropsize__`i'>size4 & size4!=. & cropsize__`i'!=. & c29_u__`i'==2)
	}
*5 plots
	foreach i in 1 2 3 4 5 6{
	list ${problem} size5 cropsize__`i' c29_u__`i' c16_u__5 crop_label__`i' tot_plot if (cropsize__`i'>size5 & size5!=. & cropsize__`i'!=. & c29_u__`i'==2)
	}
	*
				  
*3*  **MONEY CONSISTENCY			   
  	 *check consistency in money receive from selling:
		*c34 quantity sold
		*c35 money earned in total
		*c36 price per unit (max)
	
	//3 4 5
	foreach i in 1 2 3 4 5 6 7 {
	display "Displaying interviews with higher price per unit(c36) than total money earned(c35)"
	list ${problem} c36__`i' c35__`i'  c34__`i' if c36__`i'> c35__`i' & c34__`i'>0 & c35__`i'>0 & c34__`i'!=.
	}	
		*
		
*PART 4.2:  Check for outliers.
*--------------------------------------	

** You probably do not need to check for outliers for variables that have
* hard range limits in the CAI survey program. In most cases, any response
* in this range is already considered reasonable.

* However, in this survey we didn't use any hard range limits for weekly
* income, probably a mistake. We'll check for outliers by looking for
* incomes that are 3 standard deviations from the mean.

* In general, you should not drop outliers from the data. Variation is
* exactly what we're hoping to measure, and there will likely be some
* outliers just naturally. Contact your PI for further guidance on how to
* manage outliers.

	egen mean = mean(wklyinc)
	egen sd = sd(wklyinc)
	generate sds = (wklyinc - mean) / sd
	format mean sd sds %9.2f
	display "Displaying wklyinc outliers:"
	sort id
	list id wklyinc mean sd sds if abs(sds) > 3 & !missing(sds)
	drop mean sd sds
			
		
*******************************************************OTHER TEMPLATE CODE		
		
		
local outliers wklyinc age    // list the variables to check the outliers
foreach var of local outliers {
	quietly egen mean = mean(`var') 		   if `var'!=.c & `var'!=.b
	quietly egen sd = sd(`var') 			   if `var'!=.c & `var'!=.b
	quietly generate sds = (`var' - mean) / sd if `var'!=.c & `var'!=.b
	format mean sd sds %9.2f
	display "Displaying `var' outliers:"
	sort id
	list id `var' mean sd sds if abs(sds) > 3 & !missing(sds)
	drop mean sd sds
}
		
*****************************************************************************

		
*PART 4.2: CHECK THE INTERVENTION IS WELL IMPLEMENTED 
*--------------------------------------	

		
	/**checks consistencies regarding the treatment intervention:
	In this example, the treatment intervention is called SLM
     This is a good check for contamination, spillovers, make sure
	 the controls are still controls, etc.
	 */
	
	
	foreach i in 1 2 3 4 5 {
	list ${problem} d2__`i' respondent_slwmp if d2__`i'==0 & respondent_slwmp==0
	display "Displaying interviews where respondent is not SLM but knows input from the slm the project"
	}

	foreach i in 1 2 3 4 5 {
	list ${problem} d4_0__`i' respondent_slwmp if d4_0__`i'=="1" & respondent_slwmp==0
	display "Displaying interviews where respondent is not SLM but knows input from the slm the project"
	}

	foreach i in 1 2 3 4 5 {
	list ${problem} d9_2_0__`i' respondent_slwmp if d9_2_0__1`i'=="1" & respondent_slwmp==0
	display "Displaying interviews where respondent is not SLM but knows input from the slm the project"
	}

	foreach i in 1 2 3 4 5 {
	list ${problem} d33_0__`i' respondent_slwmp if d33_0__`i'=="1" & respondent_slwmp==0
	display "Displaying interviews where respondent is not SLM but receive input from the slm the project"
	}
	
	foreach i in 1 2 3 4 5 {
	list ${problem} c30__`i' respondent_slwmp if c30__`i'==0 & respondent_slwmp==0
	display "Displaying interviews where respondent is not SLM but receive input from the slm the project"
	}

	
	
	
	







