// Suggested solution for Lab 4

  // Setup
    version 12.1
    di c(version)
    set seed 580917 // <- generated on Random.org at Timestamp: 2018-06-09 22:20:43 UTC

  // Load the data
    use "${Lab4}/hh_roster.dta", clear
      isid hh_id mem_id , sort // Confirm unique sort
      drop hh_treatment // Drop the existing treatment assignment

  // Randomize a new treatment at the individual level
    gen random = runiform(0,1)
    xtile group = random , n(5)

    recode group (1/2=0 "Control")(3/5=1 "Treatment") , gen(treatment)

  // Save
  saveold "${Lab4}/hh_roster_randomized.dta", replace v(12)
      use "${Lab4}/hh_roster_randomized.dta" , clear


// With [randtreat]

  set seed 580916
  use "${Lab4}/hh_roster.dta", clear
    isid hh_id mem_id , sort
    drop hh_treatment

  randtreat ///
  , generate(treatment) ///
    unequal(40/100 60/100) ///
      misfits(global)

// End of dofile
