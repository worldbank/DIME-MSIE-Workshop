* Suggested solution for Lab 6 regression table

  // Use data
    use "${Lab5}/hh_roster.dta" , clear

  // Create variable locals
    local controls hh_fs_01 hh_fs_03 hh_fs_05 hh_inc_01 hh_inc_02
    local outcome1 hh_inc_08 // Livestock sales
    local outcome2 hh_inc_12 // LWH terracing

  // Run simple regressions

    reg `outcome1' ///
      `controls' ///
    , cl(hh_id)
      est sto reg1

    reg `outcome2' ///
      `controls' ///
    , cl(hh_id)
      est sto reg2

    reg `outcome1' ///
      hh_treatment ///
      `controls' ///
    , cl(hh_id)
      est sto reg3

    reg `outcome1' ///
      hh_treatment ///
      `controls' ///
    , cl(hh_id)
      est sto reg4

    global regressions reg1 reg2 reg3 reg4

  // Export basic tables in Excel

    // outreg2
    outreg2 [${regressions}] ///
    using "${Lab5}/regressions-outreg.xls" ///
    , replace excel

    // estout
    estout ${regressions} ///
    using "${Lab5}/regressions-estout.xls" ///
    , replace c(b & _star se)

  // Export basic tables in TeX

    // outreg2
    outreg2 [${regressions}] ///
    using "${Lab5}/regressions-outreg.tex" ///
    , replace excel

    // estout
    esttab ${regressions} ///
    using "${Lab5}/regressions-estout.tex" ///
    , replace c(b & _star se)


// End of dofile
