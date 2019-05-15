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
      xtile group = random , n(2)
      recode group (1=0 "Control")(2=1 "Treatment") , gen(treatment)

    // Check randomness of randomization
    gen n = _n
    ranksum n , by(treatment)
    drop random group n

  // Save the randomization
  saveold "${Lab4}/hh_roster_randomized.dta", replace v(12)
      use "${Lab4}/hh_roster_randomized.dta" , clear

// Confirm replicability
  version 12.1 // Same version
  set seed 580917 // Same seed
  use "${Lab4}/hh_roster.dta", clear // Same data
    isid hh_id mem_id , sort // Same sort order
    drop hh_treatment

  // Idendical randomization process
  gen random = runiform(0,1)
    xtile group = random , n(2)
    recode group (1=0 "Control")(2=1 "Treatment") , gen(treatment)
    drop random group

  // Check against first randomization
  cf _all using "${Lab4}/hh_roster_randomized.dta"

// End of dofile
