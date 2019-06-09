// Suggested solution for Lab 5

  // Install programs
    ssc install sumstats, replace

  // Use data
    use "${Lab5}/hh_roster.dta" , clear

  // Create variable locals
    local controls hh_fs_01 hh_fs_03 hh_fs_05 hh_inc_01 hh_inc_02
    local outcome1 hh_inc_08 // Livestock sales
    local outcome2 hh_inc_12 // LWH terracing

// Task 1: [sumstats]

  // Summarize food security
  sumstats ///
    ( `controls' `outcome1' `outcome2' ) ///
  using "${Lab5}/summary-statistics-1.xlsx" ///
  , replace stats(N mean median sd min max)

  // Summarize by treatment/control
  sumstats ///
    (`controls' `outcome1' `outcome2' if hh_treatment == 0) ///
    (`controls' `outcome1' `outcome2' if hh_treatment == 1) ///
    (`controls' `outcome1' `outcome2' if tag_hh == 1) ///
  using "${Lab5}/summary-statistics-2.xlsx" ///
  , replace stats(N mean median sd min max)

// Using [tabstat] and [putexcel]

  tabstat `controls' `outcome1' `outcome2' ///
    , save stats(N mean median sd min max)
  mat results = r(StatTotal)' // Reformat results matrix

  putexcel set "${Lab5}/summary-statistics-3.xlsx" , replace
  putexcel A1 = mat(results , names)

// End of dofile
