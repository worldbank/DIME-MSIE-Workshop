
********************************************************************************
*    Task 1: Open file and file paths
********************************************************************************

	*Alwasys start
	ieboilstart , version(12.0) noclear
	`r(version)'

	*Open the data set
	use "C:/Users/kbrkb/Dropbox/MSIE-workshop/Material/Labs/Stata-Track-1/Data/endline_data_raw_nodup.dta", clear
	*Open the second data set
	use "C:/Users/kbrkb/Dropbox/MSIE-workshop/Material/Labs/Stata-Track-1/Data/panel_data.dta", clear

	* After task 6, replace the code above with the code below

	* Project folder and Stata Track 1 Folder
    global MSIE 	"C:/Users/kbrkb/Dropbox/MSIE-workshop"
    global track_1  "${MSIE}/Material/Labs/Stata-Track-1"

	*Open the data set
	use "${track_1}/Data/endline_data_raw_nodup.dta", clear
	*Open the second data set
	use "${track_1}/Data/panel_data.dta", clear

********************************************************************************
*    Task 2: Explore the data
********************************************************************************


	*Open the data set - In task 2
	use "C:/Users/kbrkb/Dropbox/MSIE-workshop/Material/Labs/Stata-Track-1/Data/endline_data_raw_nodup.dta", clear

	*Open the data set - After updated in task 6
	global folder_Lab1 "C:/Users/kbrkb/Dropbox/MSIE-workshop/Material/Labs/Stata-Track-1"
	use "${folder_Lab1}/Data/endline_data_raw_nodup.dta", clear

	* After updated in task 2 in topic 3
	use "${ST1_dtDeID}/endline_data_raw_nodup.dta", clear

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

********************************************************************************
*    Code included in slides between task 2 and 3
********************************************************************************

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

********************************************************************************
*    Task 3: Generate new variables
********************************************************************************

	*Create a new variable that exchanges HH farm enterprise income to USD
	generate inc_01_USD = inc_01 * 0.0012

	*Create a new variable that measures
	*the maize yield in pounds
	generate inc_01_EURO = inc_01 *  0.0001

	*Label variables maize_tons_annual
	label variable inc_01_USD	"On-Farm Enterprise Income (USD)"
	label variable inc_01_EURO	"On-Farm Enterprise Income (EURO)"

	*Generate a dummy that 1 if the harvest
	*yeild is more than 4,000lbs.
	generate high_farm_income_EURO = 0
	replace  high_farm_income_EURO = 1 if (inc_01_EURO > 5000)

	*Tabulate the result
	tabulate high_farm_income_EURO

	*Label variables clearly
	label variable high_farm_income_EURO	"On-Farm Enterprise Income (EURO) "

	*Create the label
	label define high_farm_EURO_lab 1 "Income  >5000 Euros" 0 "Income  <5000 Euros"

	*Apply the label to the variable
	label value high_farm_income_EURO high_farm_EURO_lab

********************************************************************************
*    Task 4: Start using do-files
********************************************************************************

	*Done in code above

********************************************************************************
*    Task 5: Comments
********************************************************************************

	*Done in code above

********************************************************************************
*    Code for slides between task 5 & 6
********************************************************************************

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

********************************************************************************
*    Task 6: Comments
********************************************************************************

	* See edits to Task 2

********************************************************************************
*    Task 7: Missing Values
********************************************************************************

	*Summarize the data
	summarize inc_*

	*Produce a table over variables with missing values
	misstable summarize   inc_*

	*Tabulate missing values
	tabulate inc_zero
	tabulate inc_zero, missing

********************************************************************************
*    Task 8: Saving data sets
********************************************************************************

	*Save final data
    save "${folder_Lab1}/Data/endline_data_post_topic2.dta", replace

	* After updated in task 2 in topic 3
	save "${ST1_dtInt}/endline_data_post_topic2.dta", replace

********************************************************************************
*    Task 9: Open data from other sources
********************************************************************************

	*Importing excel (if you are using and older version of Stata this code might look different)
	import excel "${folder_Lab1}/Data/village_codes.xls", sheet("Sheet1") firstrow clear


************************ End of do-file *************************************
