// Suggested solution for Lab 5 balance tables

  // Use data
    use "${Lab5}/hh_roster.dta" , clear

  // Test differences between treatment and control
  // for household head gender, household size and all the income variables
  iebaltab  ///
    hh_head_gender hh_hhsize hh_inc_* ///
  , grpvar(hh_treatment) ///
    save("${Lab5}/balance-1") replace

  // The same balance table as above but the variable labels are used as row
  // names instead of the variable names. A column for the total sample
  // (treatment and control combined) is also added
  iebaltab  ///
    hh_head_gender hh_hhsize hh_inc_* ///
  , grpvar(hh_treatment) total   ///
    save("${Lab5}/balance-2") ///
      replace rowvarlabel

  // The same balance table as above but row labels for hh_hhsize and hh_head_gender
  // are entered manually. rowvarlabels is still used so the variable label is used
  // for all other variables. Some observations has missing values in the income
  // variables. balmiss(zero) treats those missing values as zero instead of dropping
  // the observation from the table. An ftest for joint difference is also added at
  // the bottom of the table.
  iebaltab ///
     hh_head_gender hh_hhsize hh_inc_* ///
  , grpvar(hh_treatment) total   ///
    balmiss(zero) ftest        ///
    save("${Lab5}/balance-3") ///
      replace rowvarlabel ///
    rowlabels("hh_hhsize Household Size @ hh_head_gender Share of male household heads")

// End of dofile
