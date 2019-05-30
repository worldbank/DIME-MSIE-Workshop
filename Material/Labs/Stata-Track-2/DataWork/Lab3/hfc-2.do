// Check When no plots were selected

  // Setup flags file
  putexcel  set `"${Lab3}/hfc-checks.xls"', sheet("Zero Plots") modify
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
  qui count if numplots == 0
  sum numplots, d

  // If there are, export them
  if r(N) > 0 {

    // Keep these observations
    keep if numplots == 0

    // Add information about this issue
    gen question   = "Number of Plots"          // Question
    gen variable   = "numplots"                 // Name of the variable
    gen value      = numplots                   // Value
    gen issue      = "Zero plots selected"      // Describe the issue

    *This outputs the new set of flags to the HH flags excel sheet
    export excel  ///
      pl_id_09 id_05 key submissiondate enumerator_ID ///
      question variable value issue   ///
    using `"${Lab3}/hfc-checks.xls"' ///
    , sheet("Zero Plots", modify) cell("A2")
  }

// End of dofile
