
********************************************************************************
* 							PART 1: FilePaths
*******************************************************************************/

   * Users
   * -----
   if c(username) == "kbrkb" {
		global track_1_folder "C:\Users\kbrkb\Dropbox\FC Training\June 2018\Manage Successful Impact Evaluations - 2018 Course Materials (public)\Stata Lab Track 1"
	}

   if c(username) == "wb506743" {
		global track_1_folder "C:\Users\wb506743\Dropbox\FC Training\June 2018\Manage Successful Impact Evaluations - 2018 Course Materials (public)\Stata Lab Track 1"
   }
   *

   * Project folder globals
   * ---------------------
   global track_1_data        "$track_1_folder\data"
   global track_1_lab_2       "$track_1_folder\labs\Lab 2 - Coding for Reproducible Research"


*-------------------------------------------------------------------------------
* 						2.1 Lab Task 1
*-------------------------------------------------------------------------------

	*Open the data set
	use "$track_1_data\endline_data_raw.dta", clear


	*Open the second data set
	use "$track_1_data\panel_data.dta", clear

*-------------------------------------------------------------------------------
* 						2.2 Lab Task 2
*-------------------------------------------------------------------------------

	*Open the data set
	use "$track_1_data\endline_data_raw.dta", clear

	*Browse the data
	browse

	*Describe the data
	describe

	*Summarize the data
	summarize lwh_group			// Variable is wheher HH is part of a LWH group is a string variable


	**Variable Crop type at follow up

	*Tabulate Crop type
	tabulate numplots 			// Tabulations works but are note great with continous variables

	*Summarize Crop type
	summarize numplots, detail // See max and min and mean in the output

	*Codebook for Crop type
	codebook numplots 			// There are 0 missing values

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
* 						2.3 Lab Task 3
*-------------------------------------------------------------------------------

	*Create a new variable that exchanges HH farm enterprise income to USD
	generate inc_01_USD = inc_01 * 0.0012

	*Create a new variable that measures
	*the maize yield in pounds
	generate inc_01_EURO = inc_01 *  0.0010

	*Label variables maize_tons_annual
	label variable inc_01_USD	"On-Farm Enterprise Income (USD)"
	label variable inc_01_EURO	"On-Farm Enterprise Income (EURO)"

	*Generate a dummy that 1 if the harvest
	*yeild is more than 4,000lbs.
	generate high_farm_income_EURO = 0
	replace  high_farm_income_EURO = 1 if inc_01_EURO > 100  // This will be changed to 3500 in Task 4

	*Tabulate the result
	tabulate high_farm_income_EURO

	*Label variables clearly
	label variable high_farm_income_EURO	"On-Farm Enterprise Income (EURO) "

	*Create the label
	label define high_farm_EURO_lab 1 "Income  >100 Euros" 0 "Income  <100 Euros"

	*Apply the label to the variable
	label value high_farm_income_EURO high_farm_EURO_lab

*-------------------------------------------------------------------------------
* 						2.4 Lab Task 4
*-------------------------------------------------------------------------------

	*change the code above

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

	/*
	*Load original data
	use "C:\Users\wb506743\Dropbox\FC Training\June 2018\Manage Successful Impact Evaluations - 2018 Course Materials (public)\Stata Lab Track 1\data\endline_data_raw.dta", clear

		*Work on your data here

	*Save final data
	save "C:\Users\wb506743\Dropbox\FC Training\June 2018\Manage Successful Impact Evaluations - 2018 Course Materials (public)\Stata Lab Track 1\labs\Lab 2 - Coding for Reproducible Research\endline_data_post_lab2.dta", replace


	*Set folder global
	global training_folder	"C:\Users\wb506743\Dropbox\FC Training\June 2018"
	global public_folder	"${training_folder}\Manage Successful Impact Evaluations - 2018 Course Materials (public)"
	global track_1_folder 	"${public_folder}\Stata Lab Track 1"
	global lab_2		 	"${track_1_folder}\labs\Lab 2 - Coding for Reproducible Research"

	*Load original data
	use "$track_1_folder\data\endline_data_raw.dta", clear

		*Work on your data here

	save "$lab_2\endline_data_post_lab2.dta", replace
	*/

*-------------------------------------------------------------------------------
* 				2.6 Lab Task 5
*-------------------------------------------------------------------------------

	di "${track_1_data}"

	*Load original data
	use "${track_1_data}\endline_data_raw.dta", clear

*-------------------------------------------------------------------------------
* 				2.7 Lab Task 6
*-------------------------------------------------------------------------------

	*Open the data set
	use "${track_1_data}\endline_data_raw.dta", clear

	*Summarize the data
	summarize inc_*

	*Produce a table over variables with missing values
	misstable summarize   inc_*

	*Tabulate missing values
	tabulate inc_zero
	tabulate inc_zero, missing

*-------------------------------------------------------------------------------
* 				2.5 Lab Task 7
*-------------------------------------------------------------------------------

	*Save final data
   save "$track_1_lab_2\endline_data_post_lab2.dta", replace


*-------------------------------------------------------------------------------
* 				2.8 Lab Task 8
*-------------------------------------------------------------------------------

	*Importing excel (if you are using and older version of Stata this code might look different)
	import excel "${track_1_data}\village_codes.xls", sheet("Sheet1") firstrow clear


************************ End of do-file *************************************
