
********************************************************************************
* 							PART 1: FilePaths
*******************************************************************************/

   * Users
   * -----
   if c(username) == "kbrkb" {
		global track_1_folder "C:/Users/kbrkb/Dropbox/FC Training/June 2018/Manage Successful Impact Evaluations - 2018 Course Materials (public)/Stata Lab Track 1"
	}

   if c(username) == "wb506743" {
		global track_1_folder "C:/Users/wb506743/Dropbox/FC Training/June 2018/Manage Successful Impact Evaluations - 2018 Course Materials (public)/Stata Lab Track 1"
   }
   
   * Project folder globals
   * ---------------------
	global track_1_data        "$track_1_folder/data"
	global track_1_lab_5       "$track_1_folder/labs/Lab 5 - Randomization"
	global track_1_lab_6       "$track_1_folder/labs/Lab 6 - Descriptive Analysis"
	global output		       "$track_1_lab_6/output"

********************************************************************************
* 							PART 2: Descriptive 
*******************************************************************************/
	
	* Load the data. If you managed to save the data set with the duplicates removed in lab 5, use that data set, otherwise use the data set we prepared for you
	use "${track_1_data}/endline_data_rand.dta",  clear
	use "${track_1_lab_5}/endline_data_post_lab5.dta",  clear
	
	
	*-------------------------------------------------------------------------------
	* 						2.1 Task 1 - Summarize & tabulate
	*-------------------------------------------------------------------------------
	
	* Summarize
	* ---------
		* Create variable locals

			local income_vars 
		
		* Summarize 
			
			summarize /* add more variables here or use the local above */
		
		* Summarize with detailed descriptive statistics
			
			/* add commmand here */

	* Tabulate
	* --------	
		*Tabulate the gender of the first person listed in the household
		
			tab /* add the variable name here */
		
	*-------------------------------------------------------------------------------
	* 						2.2 Task 2 - Tabstat
	*-------------------------------------------------------------------------------
		* Tabstat with mean
			
			tabstat /* add more variables here or use the local above */
		
		* Tabstat with multiple statistics
			
			/* add commmand here */
			
		* Tabstat for groups
			
			/* add commmand here */
			
	*-------------------------------------------------------------------------------
	* 						2.3 Task 3 - sumStats
	*-------------------------------------------------------------------------------
	
	* Summarize food security

		* Install programs

			net install ///
				"https://raw.githubusercontent.com/worldbank/stata/master/wb_git_install/wb_git_install.pkg"

			wb_git_install sumStats
			wb_git_install xml_tab
			
		* Create variable locals
		
			local controls fs_01 fs_03 fs_05 inc_01 inc_02
			local outcome1 inc_08 // Livestock sales
			local outcome2 inc_12 // LWH terracing		

	* Task 3a
	* -------
	
		sumStats ///
			( `controls' /*add the other locals here*/ ) ///
			using "${output}/task1_1.xls" ///
		, replace stats(mean /*add more stats here*/)
	
  	* Task 3b
	* -------
	
		* Summarize by treatment/control

		sumStats ///
			(`controls' /*add the other locals here*/  if /*restrict to control here*/ ) ///
			(`controls' /*add the other locals here*/  if /*restrict to control here*/ ) ///
			using "${output}/task1_2.xls" ///
		, replace stats(mean /*add more stats here*/)
   
	*-------------------------------------------------------------------------------
	* 						2.4 Task 4 - Balance Tables
	*-------------------------------------------------------------------------------
		
		* Create variable locals		
			
			local balancevars inc_01 inc_02 /* add more variables here */
		
		* Create balance table 
			* Testing difference between treatment & control for all the income variables
			
			iebaltab  `balancevars' if !missing(inc_t) , grpvar(hh_treatment) ///
			save("$output/balance_1") replace	
		
		* Update balance table 
			* Using variable labels instead of variable names as row names
			* Adding a column for total sample 

			iebaltab  `balancevars' if !missing(inc_t), grpvar(hh_treatment) total 	///
			save("$output/balance_2") replace rowvarlabel
		
		* Update balance table 
			* Manually entering row labels for hh_hhsize and hh_head_gender 
			* Treating missing values as 0s instead of dropping them
			* Adding an F-test for joint difference 
			
			iebaltab `balancevars' if !missing(inc_t), grpvar(hh_treatment) total 	///
				balmiss(zero) ftest													///
				save("$output/balance_3") replace rowvarlabel						///
				rowlabels("inc_01 Enterprise Income from Farm Activities @ inc_02 Enterprise Income from Non-Farm Activities" /* add more label descriptions here */ )


	*-------------------------------------------------------------------------------
	* 						2.5 Task 5 - Analysis Tables
	*-------------------------------------------------------------------------------
		
		* Create variable locals		
			
			local depvar	inc_08
			local indepvar	pl_hhsize numplots /* add more variables here */
						
		* Run regression
			
			eststo: reg `depvar' `indepvar'
			
		* Export regression tables
			esttab using "$output/analysis_1.csv", replace
			
			eststo clear
			
		* Update regression
			* Using variable labels instead of variable names as row names
			esttab using "$output/analysis_1.csv", replace label
			
			