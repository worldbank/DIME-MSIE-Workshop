// Lab 2 cleaning dofile

// Open the raw dataset.
use "${Lab2}/endline_data_raw_nodup.dta" , clear

  // Keep only variables from the household roster.
  keep id_05 age_* pl_sex_* education_*
    drop *str* *new*

  // Investigate for irregulatiries in data
  codebook, compact

    duplicates report id_05
    duplicates list id_05

    codebook education_1
    summarize education_1, detail
    histogram education_1

  // Reshape the household roster data
  rename id_05 hh_id

    // Put indices at end for [reshape]
    rename edu*_* edu*[2]
    rename *sex_* sex*[2]
    rename age_* age*

    reshape long ///
      age sex edu ///
    , i(hh_id) j(mem_id)

  // Cleaning

    drop if sex == . // Drop empty spaces after [reshape]
    label var mem_id "Member ID"

    label var age "Age"
    label var sex "Sex"
      label def sex 1 "Male" 2 "Female" , modify
      label val sex sex
    label var edu "Education"

  // Label education levels when missing
    numlabel ed_level , add

    tab edu, missing plot
      replace edu = .a if edu == -88
      replace edu = .b if edu == -66

    label def ed_level .a "Don't Know" .b "Refused" , modify
    numlabel ed_level , remove force

  // Save as roster dataset

    saveold "${Lab2}/hh_roster_clean.dta" , replace v(12)
      use "${Lab2}/hh_roster_clean.dta" , clear

// End of dofile
