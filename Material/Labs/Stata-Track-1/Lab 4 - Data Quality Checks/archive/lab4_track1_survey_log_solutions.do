/*******************************************************************************
*			DIME Field Coordinator Training
*			Lab 4 - Track 1 - Data Quality Checks
*			Exercise 2
*																 			   *
*  PURPOSE:  			This solution file is a suggested solution 			   *
						for how the file might look in the end of 			   *	
						the excercise. 										   *
												
*
********************************************************************************			
	Written by:	Aurelie Rigaud, DECIE
********************************************************************************/
	
		

*-------------------------------------------------------------------------------
* 						1.1 Initial settings
*-------------------------------------------------------------------------------
	clear 
	set more off
	
	
* Install required packages
	if 0 {																		
		ssc install ietoolkit, replace
	}
   *allow more variables
	set maxvar 30000
	
	*version?
	   
	
*-------------------------------------------------------------------------------
* 						1.2 Create file path globals
*-------------------------------------------------------------------------------
	
	
   * User
   * -----------
   *User Number:
   * Kris	               1  
   * Aurelie               2

   *Set this value to the user currently using this file
   global user 2

	*set globals
   if $user == 1 {
       global lab4 "XXXX"
   }

   if $user == 2 {
       global lab4 "D:\Dropbox\FC Training\June 2018"   
   }
   
   *allow more variables
	set maxvar 30000
	
	
	
	*subfolder
	global output "$lab4\Session Materials\Stata Track 1\Lab 4 - Data Quality Checks\Outputs"
 
   *open the dataset
	use "$lab4\data\endline_data_raw", clear

*-------------------------------------------------------------------------------
* 						1.2 Create file path globals
*-------------------------------------------------------------------------------

*TO COMPLETE

*-------------------------------------------------------------------------------
* 						2.1 HFC
*-------------------------------------------------------------------------------
	
*1* How many surveys were downloaded on June 26th?
	tab importdate  
	count if importdate==26
	
		/* NOTE: Always check new data coming after dopping duplicates surveys.*/
		
		
*2* Create the global "issue" 
	global issue "importdate pl_id_08 id_05 supervisor_ID enumerator_ID starttime"
	
		//Note: variables such as location and respondent's phone number are useful 
		// to add in this global but for confidentiality purpose they have been removed for the exercice
	

*3* Check all the surveys are completed. 
	generate incomplete = missing(endtime)
	display "Displaying incomplete interviews:"
	list ${issue} if incomplete == 1
		
		//Note: tab incomplete works too, but "list" gives you information 
		*  about what are the discrepencies forms
	

*4* NO MISS: Variables that contain ONLY MISSING VALUES
	*code 1 (display form if at least 1 observation is missing)
	local stringvars "pl_id_08 pl_id_09 pl_id_10 endtime "  
	local numvars " supervisor_ID enumerator_ID id_05 survey_history" 
	foreach var in `stringvars' `numvars' {
		quietly count if missing(`var')
		if r(N) != 0 {
			display "Share of missing values in variable `var': " _column(35) string(100 * r(N) / _N, "%5.1f") "%"
		}
	}

*5* ALL MISS (display form if all observations are missing)
	//quietly ds, has(type numeric)
	//local numvars `r(varlist)' 	
	local numvars "hhh_new_sex gr_aa stored_bamboobasket_2 amount_dry_loss_6_3_3 amount_loss_1_1_1" 
	foreach var in `numvars' {
		quietly count if `var' == .
		if r(N) == _N {
			di ""
			display "`var' has only missing values."
			ta `var',m
		}
	}
	
/**NOTE: FROM HERE, checks below can be run on the latest data downloaded, however 
		we don't run this code today to practice on the whole dataset  */

		*keep if importdate==26
		
		
		
*6* Check dates consistency			
	split starttime, force
	rename starttime1 start_month
	rename starttime3 start_year
	rename starttime2 start_day
	replace start_day= subinstr(start_day, ",", "", .)
	rename starttime4 start_time
	destring start_day, replace
	destring start_year, replace		
			
	*check dates settings are accurate on the tablets		
	assert year(start_year) == 2018		
		//Note: Assertion is false, so some tablets don't have the correct date
		
	list ${issue} start_year if start_year!=2018

		
*7* LOOPS
*code that check consistency:
	global var1  "calc_index_new_1 name_new_1  relationship_1 calc_index_new_2 name_new_2  relationship_2 calc_index_new_3 name_new_3  relationship_3 calc_index_new_4 name_new_4 relationship_4 calc_index_new_5 name_new_5 relationship_5"
	list ${issue} importdate calc_repeat_new $var1  ///
					if (calc_repeat_new==1 & calc_index_new_2!=.) ///
					| (calc_repeat_new==2 & calc_index_new_3!=.) ///
					| (calc_repeat_new==3 & calc_index_new_4!=.) ///
					| (calc_repeat_new==4 & calc_index_new_5!=.) ///
					| (calc_repeat_new==5 & calc_index_new_6!=.) ///
					| (calc_repeat_new==1 & name_new_2!="") ///
					| (calc_repeat_new==2 & name_new_3!="") ///
					| (calc_repeat_new==3 & name_new_4!="") ///
					| (calc_repeat_new==3 & name_new_5!="") ///
					| (calc_repeat_new==5 & name_new_6!="") 
										
****Additional codes for same CHECKS ****							
	foreach i in 1 2 3 4 5 6 7 8 9 {
		local j = `i' + 1
	list $issue calc_index_new_1 name_new_1  relationship_1 calc_index_new_2 ///
	name_new_2  relationship_2 calc_index_new_3 name_new_3  relationship_3 ///
	calc_index_new_4 name_new_4 relationship_4 calc_index_new_5 name_new_5 relationship_5	///
	if calc_repeat_new==`i' &  calc_index_new_`j'!=.
			}	

	
	/*Notes on inconsistencies:
	*Survey 7026:
	1 new member in the household (calc_repeat_new=2) but questions answered 2 times
	(calc_index_new_2 and relationship_2 are not missing
	*Survey 7114:
	2 new members in the household (calc_repeat_new=2) but questions answered 3 times
	(calc_index_new_3 and relationship_3, are not missing
	*Survey 21586:
	3 new members in the household (calc_repeat_new=3) but questions answered 5 times
	(calc_index_new_4, calc_index_new_5, relationship_4, relationship_5 are not missing
	*/
	
	

*8* Consistency checks on quantity sold and harvested
		*m: plot, 1 to 6
		*j: seasons, 1 to 3
		*i: crop, 1 to 3
	
	foreach i in 1 2 3	{
	foreach j in 1 2 3	{
	foreach m in 1 2 3 4 5 6	{ 
	list $issue amount_harvest_`m'_`j'_`i' amount_sell_`m'_`j'_`i' ///
	if amount_harvest_`m'_`j'_`i'<amount_sell_`m'_`j'_`i'
			}
		}
	}
	
		//Notes on inconsistencies:
		//Survey 21314 has one inconsistency (quantity sold is higher than harvested)

*9* Check your surveyors' comments:
	list $issue comment if comment!=""
	
		//Note: comments are always useful to check, they give you information on
		//potential programming issue, IE or sample issue, inconsistency, etc.
		
	
	
*-------------------------------------------------------------------------------
* 						2.2 SURVEY LOG
*-------------------------------------------------------------------------------



*10* Check:
	*a)  the number of surveys received and completed so far
	tab importdate if incomplete==0
	count if incomplete!=1
	*b)  the number of surveys received and completed by enumerator
	tab enumerator_ID importdate if incomplete==0
	*c)  the number of surveys received and completed by team
	tab importdate supervisor_ID  if incomplete==0	
	
*11* Connectivity issue:	
	tab supervisor_ID importdate  if importdate>=22



*12* Export tracking sheet n°26.
	sort pl_id_09 pl_id_10 pl_id_08 starttime importdate enumerator_ID  id_05 incomplete  
	
foreach i in Burera Gicumbi Kayonza Rulindo Rwamagana{
cap export excel pl_id_09 pl_id_10 pl_id_08 starttime importdate enumerator_ID id_05  ///
 if (pl_id_09=="`i'") using "${output}\Tracking Sheet_26.xls", sheet("`i'")first(varl) sheetreplace
}
*

	
*-------------------------------------------------------------------------------
* 						ADDITIONAL IDEAS OF CODES
*-------------------------------------------------------------------------------


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


		
	
*********************************MICHAEL's code***********************************

	
	/*4     Check frequency don't know per surveyors*/

 * Flag "dont knows" score -- Checks for frequency of "dont knows" per enumerator // Michael's code!

 
ds, has(type numeric)
gen score_dontknow = 0
	foreach var of varlist `r(varlist)' {
		gen x = (`var' == -99 & `var'!=.) 
			replace score_dontknow = score_dontknow + x if (`var' == -99) //& (HFC_eligible == 1)
drop x
}	

 ds, has(type numeric)

gen not_applicable = 0
	foreach var of varlist `r(varlist)' {
		gen x = (`var' == -66 & `var'!=.) 
			replace not_applicable = not_applicable + x if (`var' == -66) //& (HFC_eligible == 1)
drop x
}
*


*Export the target survey count and completed survey count for community 
*preserve
	recode	consent(.=0)
	label 	define consentlab 1 "Surveys Completed" 0 "Surverys Not Completed"
	label	values consent consentlab
	
	estpost tabulate area consent  
	esttab	using 	"$graph2/Tables/Target_survey_county.doc", replace 	///
			cell(b)  ///
            collabels(none) unstack noobs nonumber  modelwidth(23 18)        ///
            eqlabels(, lhs("Community"))                           ///
			title("Survey Count Tracking Table: Area/Community") ///
			varlabels(, blist(Survey Target Count)) compress

	estpost tabulate county consent  
	esttab	using 	"$graph2/Tables/Target_survey_county.doc", append 	///
			cell(b) ///
            collabels(none) unstack noobs nonumber nomtitle  modelwidth(23 18)        ///
            eqlabels(, lhs("County"))                           ///
			title("Survey Count Tracking Table: County")				///
			varlabels(, blist(Total)) compress
