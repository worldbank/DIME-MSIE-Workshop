/* *************************************************************************** *
*						Lab Session 2							  			   *												   
*																 			   *
*  PURPOSE:  			This solution file is a suggested solution 			   *
						for how the file might look in the end of 			   *	
						the excercise. 										   *
																			   *
						Some lines of code (for example setting up             *
						the global) is in the top of thuis file, 			   *
					    although you are not asked to do that until			   *
						in one of the last tasks. 							   *  
																			   *
																			   *
*  WRITEN BY:  			Michael	Orevba	  									   *
*  Last time modified:  June 2018											   *
*																			   *
********************************************************************************


********************************************************************************
* 							PART 1: SETTINGS
*******************************************************************************/

*-------------------------------------------------------------------------------
* 						1.1 Initial settings
*-------------------------------------------------------------------------------

	* Install required packages
   local user_commands ietoolkit       //Fill this list will all commands this project requires
   foreach command of local user_commands {
       cap which `command'
       if _rc == 111 {
           cap ssc install `command'
       }
   }
	
	*Standardize settings accross users
    ieboilstart, version(12.0)      											
    `r(version)'   
	
	*set maxvar 32767, perm
	   
*-------------------------------------------------------------------------------
* 						1.2 Create file path globals
*-------------------------------------------------------------------------------

   * Users																		
   * -----
    if c(username) == "kbrkb" {
       global projectfolder "C:\Users\kbrkb\Documents\GitHub\RwandaSummerSchool\Labs"
	}

   if c(username) == "wb506743" {
		global projectfolder "C:\Users\wb506743\Dropbox\FC Training\June 2018"
   }
   *
   
   * Project folder globals
   * ---------------------
   global dataWorkFolder        "$projectfolder\SummerSchoolData"

   	
*-------------------------------------------------------------------------------
* 						2.1 Lab Task 1
*-------------------------------------------------------------------------------	
	
	*Open the data set
	use "$dataWorkFolder\endline_data_raw.dta", clear 	
	
	
	*Open the second data set
	use "$dataWorkFolder\panel_data.dta", clear	
	
*-------------------------------------------------------------------------------
* 						2.2 Lab Task 2
*-------------------------------------------------------------------------------	
	
	*Open the data set
	use "$dataWorkFolder\endline_data_raw.dta", clear 
 	
	*Browse the data
	browse
	
	*Describe the data
	describe 	 
	
	*Summarize the data
	summarize lwh_group			// Variable is wheher HH is part of a LWH group is a string variable
	
	tabulate lwh_group
	
	tabulate hhh_confirm
	
	browse exist why_dropped note_dropped consent_general hhh_confirm

*-------------------------------------------------------------------------------
* 			Code included in slides between task 2 and 3
*-------------------------------------------------------------------------------		
	
	*Generate a variable that is HH total income by size
	generate inc_per_hh_member = inc_t / pl_hhsize

	*Label variables clearly
	label variable inc_per_hh_member "HH total income by HH size"

	*Summarize
	summarize inc_per_hh_member

	*Generate a dummy that 1 if per capita income is
	*is greater than than 500,000 francs.
	generate high_income = 0 
	replace  high_income = 1 if inc_per_hh_member > 500000

	*Tabulate the result
	tabulate high_income
	
	*Create the label
	label define high_income_lab 1 "Per Capita Income >500K" 0 "Per Capita Income <500K"
	
	*Appy the label to the variable
	label value high_income high_income_lab

	*Tabulate the variable again, then
	*browse it together with HH income by HH size
	tabulate high_income
	browse	 high_income inc_per_hh_member

*-------------------------------------------------------------------------------
* 				Code for slides between task 4 and 5
*-------------------------------------------------------------------------------		
	
	*Define locals
	local numberA 3
	local numberB 5

	*Use locals
	gen restult_var = (`numberA' * `numberB') - `numberA'

	*Define global
	global project GAFSP

	*Use globals
	gen country_${project} 	= "Kenya"
	gen donor_${project} 	= "World Bank"
	
	
*-------------------------------------------------------------------------------
* 						2.3 Lab Task 3
*-------------------------------------------------------------------------------	
	
	*Set currency exchange rate
	local RWFtoUSD 0.0011
	
	*Create a new variable that exchanges HH farm enterprise income to USD
	generate inc_per_hh_member_USD = inc_per_hh_member * `RWFtoUSD'
	
	*Label variables maize_tons_annual
	label variable inc_per_hh_member_USD	"HH total income by HH size (USD, EX `RWFtoUSD')"
	

	
*-------------------------------------------------------------------------------
* 				2.8 Lab Task 8
*-------------------------------------------------------------------------------	
	
	*Importing excel (if you are using and older version of Stata this code might look different)
	import excel "$folder_lab1\data\village_codes.xls", sheet("Sheet1") firstrow clear
	
	
************************ End of do-file *************************************	
