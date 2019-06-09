// Check Agricultural Equipment rent upper limit

  // Setup flags file
  putexcel  set `"${Lab3}/hfc-checks.xls"', sheet("High Costs") modify
    putexcel  A1 = ("pl_id_09")     /// District name
      B1 = ("id_05")                /// HHID
      C1 = ("key")                  /// Unique submission ID
      D1 = ("submissiondate")       /// Submission date
      E1 = ("enumerator_ID")        /// ID of the enumerator
      F1 = ("question")             /// Question number in questionnaire
      G1 = ("variable")             /// Name of the variable in the data set
      H1 = ("value")                /// Original value of variable
      I1 = ("issue")                /// Description of the issue with the observation
      J1 = ("correction")           /// Column for field teams to add correct values
      K1 = ("initials")              // ID of people who added corrections

  // Load data
  use "${Lab3}/endline_data_raw_nodup.dta", clear

  // Check if there are any such observations
  drop if exp_18==. | exp_18 < 0  // restrict to HH that rent agriculture equipment
  qui count if exp_18 > 100000

  // If there are, export them
  if r(N) > 0 {
    keep if exp_18 > 100000

    // Add information about this issue
    gen question = "exp_18"
    gen variable = "Rent or purchase agricultural equipment"
    gen issue    = "Rent or purchase of equipment greater than 100,000 Francs"
    gen value    = exp_18                   // Value

    // Outputs the new set of flags to the HH flags excel sheet
    export excel ///
      pl_id_09 id_05 key submissiondate enumerator_ID ///
      question variable value issue   ///
      using `"${Lab3}/hfc-checks.xls"' ///
    , sheet("High Costs", modify) cell("A2")
  }

// Have a lovely day!
