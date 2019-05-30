// Check Duration of survey (minutes)

  // Setup flags file
  putexcel  set `"${Lab3}/hfc-checks.xls"', sheet("Survey Duration") replace
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

  // Clean up time variables

    gen start = trim( ///
      subinstr( ///
        subinstr( ///
          substr(starttime,strpos(starttime,"2018")+4,.) ///
        ,"AM","",.) ///
      ,"PM","",.) ///
    )

    gen end = trim( ///
      subinstr( ///
        subinstr( ///
          substr(endtime,strpos(endtime,"2018")+4,.) ///
        ,"AM","",.) ///
      ,"PM","",.) ///
    )

    gen start_clock = clock(start,"hms")
    gen end_clock = clock(end,"hms")
    replace end_clock = end_clock + 12*60*60*1000 if end_clock < start_clock

  // Calculate survey time length and 5th percentile, and export flags
  gen survey_time = (end_clock-start_clock)/(1000*60) // Time is in minutes

    sum survey_time, d
      local theMean = `r(p5)'

    // Keep these observations
    keep if survey_time < `theMean'

    // Add information about this issue
    local theMean : di %3.2f `theMean'  // restrict mean to 2 decimal places
    gen question   = "Duration"         // Question number
    gen variable   = "survey_time"      // Name of the variable
    gen value      = survey_time        // Value
    gen issue      = "Below 5th percentile survey duration"  // Describe the issue

    // Export flagged observations with details
    export excel  ///
      pl_id_09 id_05 key submissiondate enumerator_ID ///
      question variable value issue ///
    using `"${Lab3}/hfc-checks.xls"' ///
    , sheet("Survey Duration", modify) cell("A2")

// End of dofile
