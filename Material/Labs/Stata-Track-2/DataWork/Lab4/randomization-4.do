// Suggested solution for Lab 4

  // Setup
    version 12.1
    di c(version)
    set seed 580917 // <- generated on Random.org at Timestamp: 2018-06-09 22:20:43 UTC

  // Load the data at the household level
    use "${Lab4}/hh_roster.dta", clear
      isid hh_id mem_id , sort // Confirm unique sort
      drop hh_treatment // Drop the existing treatment assignment
      keep if (tag_hh == 1) // Randomize at household level

  // Randomize a new treatment at the individual level
    gen random = runiform(0,1)
    xtile group = random , n(2)
    recode group (1=0 "Control")(2=1 "Treatment") , gen(treatment)

  // Apply to the whole dataset
    tempfile hh_treatment
      save `hh_treatment'

    use "${Lab4}/hh_roster.dta", clear
    merge m:1 hh_id using `hh_treatment' ///
      , keepusing(treatment) nogen // Merge only the treament assignment

  // Verify
    ta treatment
    ta treatment if (tag_hh == 1)

  // Save
  saveold "${Lab4}/hh_roster_randomized.dta", replace v(12)
      use "${Lab4}/hh_roster_randomized.dta" , clear

// Clusters and strata

  // Setup
    version 12.1
    di c(version)
    set seed 580917 // <- generated on Random.org at Timestamp: 2018-06-09 22:20:43 UTC

  // Load the data
    use "${Lab4}/hh_roster.dta", clear
      isid hh_id mem_id , sort // Confirm unique sort
      drop hh_treatment // Drop the existing treatment assignment

  // Randomize a new treatment at the [household] level, stratified by [hh_id_09]
    keep if tag_hh == 1
    encode hh_id_09 , gen(strata)

    randtreat ///
    , generate(treatment) ///
      strata(strata) ///
      misfits(global)

  // Apply to the whole dataset
    tempfile hh_treatment
      save `hh_treatment'

    use "${Lab4}/hh_roster.dta", clear
    merge m:1 hh_id using `hh_treatment' ///
      , keepusing(treatment strata) nogen // Merge only the treament assignment vars

  // Verify
  ta strata treatment if (tag_hh == 1), row

  // Save
  saveold "${Lab4}/hh_roster_randomized.dta", replace v(12)
      use "${Lab4}/hh_roster_randomized.dta" , clear

* Have a lovely day!
