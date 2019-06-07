
	*Standardize settings accross users
    ieboilstart, version(12.0)
    `r(version)'

    * USe data saved in topic 5
	use "${ST1_dtInt}/endline_data_post_topic5.dta",  clear

    ********************************************************************************
	*    Task 1 : Repeat ways to explore data
	********************************************************************************

	* Create variable locals
    local income_vars

	* Remove missing codes, and replace by missing values
	recode `income_vars' (-88 = .b)
	recode `income_vars' (-66 = .c)

    * Summarize incomce vars


	*Tabulate the gemder of the first person listed in the household

    ********************************************************************************
    *    Task 2 : tabstat
    ********************************************************************************

    * Show the mean of all income variables
    tabstat

    * Show the mean, the standard deviation and the median of all income variables
    tabstat

    ********************************************************************************
    *    Task 3 : sumstat
    ********************************************************************************

	* Summarize food security

	* Install programs
	net install "https://raw.githubusercontent.com/worldbank/stata/master/wb_git_install/wb_git_install.pkg"
	wb_git_install sumStats
	wb_git_install xml_tab

    * Create locals of varlists to use
	local controls fs_01 fs_03 fs_05 inc_01 inc_02
	local outcome1 inc_08 // Livestock sales
	local outcome2 inc_12 // LWH terracing

    * Task 3a : regular sumstat
	sumStats ( `controls' `outcome1' `outcome2' ) ///
		using "${ST1_outRaw}/sumstats_1.xls"         ///
	  , replace stats(N mean median sd min max)

    * Task 3b : sumstat by treatment/control
	sumStats ///
            ///
		using "${ST1_outRaw}/sumstats_2.xls"                       ///
	  , replace stats(N mean median sd min max)

    ********************************************************************************
    *    Task 4 : Balance tables
    ********************************************************************************

	* Balance tables

		local balancevars inc_01 inc_02

		**This is a balance table testing differences between treatment and control
		* for all the income variables
		iebaltab  `balancevars' if !missing(inc_t) , grpvar(treatment) ///
			save("${ST1_outRaw}/balance_1") replace

		**The same balance table as above but sthe variable labels are used as row
		* names instead of the variable names. A column for the total sample
		* (treatment and control combined) is also added
		iebaltab  `balancevars' if !missing(inc_t), grpvar(treatment) total 	///
			save("${ST1_outRaw}/balance_2") replace rowvarlabel

        **The same balance table as above but row labels for inc_01 and inc_02
		* are entered manually. rowvarlabels is still used so the variable label would be used
		* for all any other variable added. Some observations has missing values in the income
		* variables. balmiss(zero) treats those missing values as zero instead of dropping
		* the observation from the table. An ftest for joint difference is also added at
		* the bottom of the table.
		iebaltab `balancevars' if !missing(inc_t), grpvar(treatment) total 	///
			balmiss(zero) ftest														///
			save("${ST1_outRaw}/balance_3") replace rowvarlabel						///
			rowlabels("inc_01 Enterprise Income from Farm Activities @ inc_02 Enterprise Income from Non-Farm Activities")

    ********************************************************************************
    *    Task 5 : Simple regression output
    ********************************************************************************

    * install the package
        ssc install estout

    * Create variable locals
        local depvar	inc_08
        local indepvar	pl_hhsize numplots /* add more variables here */

    * Run regression
        eststo: reg `depvar' `indepvar'

    * Export regression tables
        esttab using "${ST1_outRaw}/regress_1.csv", replace
        eststo clear

    * Update regression
        * Using variable labels instead of variable names as row names
        esttab using "${ST1_outRaw}/regress_2.csv", replace

    ********************************************************************************
    *    Task 6 : Save data
    ********************************************************************************

    * Save data after topic 6
    compress
	save "${ST1_dtInt}/endline_data_post_topic6.dta",  replace
