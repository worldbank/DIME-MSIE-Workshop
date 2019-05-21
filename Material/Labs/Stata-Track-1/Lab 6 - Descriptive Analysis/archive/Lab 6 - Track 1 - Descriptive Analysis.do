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

*-------------------------------------------------------------------------------
* 						1.2 Create file path globals
*-------------------------------------------------------------------------------

   * Users																		
   * -----
    if c(username) == "kbrkb" {
       global projectfolder "C:\Users\kbrkb\Dropbox\FC Training\June 2018"
	}

   if c(username) == "wb506743" {
		global projectfolder "C:\Users\wb506743\Dropbox\FC Training\June 2018"
   }
   *
   
   * Project folder globals
   * ---------------------
	global folder	"$projectfolder/Session Materials/Stata Track 1/Lab 6 - Descriptive Analysis"
	global output	"$folder/Output"

	* Use data

		use "${projectfolder}/data/endline_data_raw.dta" , clear

	* Create variable locals

		local income_vars inc_01 inc_02 inc_03 inc_06 inc_08 inc_09 inc_12 inc_13 inc_14 inc_15 inc_16 inc_17
	
	* Summarize 
		
		*Remove these comments one by one and re-run summarize until there are no more negative values in the summarize
		recode `income_vars' (-88 = .b)
		recode `income_vars' (-66 = .c)
		
		summarize `income_vars'
		
	*Tab
	
		*Tabulate the gneder of the first person listed in the household
		tab pl_sex_1
		tab pl_sex_1, m
		
* Task 2: Summary statistics

		gen hh_treatment = ( uniform() < .5)
		label define tmt_status 0 "Control" 1 "Treatment"
		label val hh_treatment tmt_status

	* Summarize food security

		* Install programs

		net install ///
			"https://raw.githubusercontent.com/worldbank/stata/master/wb_git_install/wb_git_install.pkg"

		wb_git_install sumStats
		wb_git_install xml_tab
		
		local controls fs_01 fs_03 fs_05 inc_01 inc_02
		local outcome1 inc_08 // Livestock sales
		local outcome2 inc_12 // LWH terracing		
	
		sumStats ///
			( `controls' `outcome1' `outcome2' ) ///
			using "${output}/task1_1.xls" ///
		, replace stats(N mean median sd min max)

	* Summarize by treatment/control

		sumStats ///
			(`controls' `outcome1' `outcome2' if hh_treatment == 0) ///
			(`controls' `outcome1' `outcome2' if hh_treatment == 1) ///
			using "${output}/task1_2.xls" ///
		, replace stats(N mean median sd min max)

* Task 3: Balance table
	
	* Balance tables
	
		local balancevars inc_01 inc_02 
		
		**This is a balance table testing differences between treatment and control 
		* for all the income variables
		iebaltab  `balancevars' if !missing(inc_t) , grpvar(hh_treatment) ///
			save("$output/balance_1") replace	
		
		**The same balance table as above but sthe variable labels are used as row 
		* names instead of the variable names. A column for the total sample 
		* (treatment and control combined) is also added
		iebaltab  `balancevars' if !missing(inc_t), grpvar(hh_treatment) total 	///
			save("$output/balance_2") replace rowvarlabel
		
		**The same balance table as above but row labels for hh_hhsize and hh_head_gender 
		* are entered manually. rowvarlabels is still used so the variable label is used
		* for all other variables. Some observations has missing values in the income 
		* variables. balmiss(zero) treats those missing values as zero instead of dropping 
		* the observation from the table. An ftest for joint difference is also added at 
		* the bottom of the table.
		iebaltab `balancevars' if !missing(inc_t), grpvar(hh_treatment) total 	///
			balmiss(zero) ftest														///
			save("$output/balance_3") replace rowvarlabel						///
			rowlabels("inc_01 Enterprise Income from Farm Activities @ inc_02 Enterprise Income from Non-Farm Activities")


