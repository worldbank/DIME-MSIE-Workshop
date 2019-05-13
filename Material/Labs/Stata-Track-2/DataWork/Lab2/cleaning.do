// Cleaning dofile for Lab 2

  // Load the dataset
  use "${Lab2}/endline_data_raw.dta", clear

  // Check ID variable
  duplicates report id_05
    duplicates drop id_05, force // Don't do this in reality, this is just a demo!
    isid id_05 , sort

  // Set up macros for desired variables
  local id id_05 gr_16
  local treatment oi_assign
  local baseline numplots pl_hhsize pl_id_10 pl_id_09 pl_id_08
  local hhh pl_age_1 pl_sex_1
  local fs fs_01 fs_02 fs_03 fs_04 fs_05
  local inc inc_01 inc_02 inc_03 inc_06 inc_08 inc_09 inc_12 ///
    inc_13 inc_14 inc_15 inc_16 inc_17 inc_t
  local ag ag_16_x_16_1 ag_16_y_16_1 ag_16_z_16_1 ag_17_x_16_1 ///
    ag_17_y_16_1 ag_17_z_16_1 ag_18_x_16_1 ag_18_y_16_1 ag_18_z_16_1

  // Keep only the selected variables
  keep            ///
    `id'          /// ID variables
    `treatment'   /// Treatment variables
    `baseline'    /// Baseline data
    `hhh'         /// Household head data
    `fs'          /// Food security data
    `inc'         /// Income data
    `ag'           // Ag data for Plot A

  // Clean up -88 survey codes
  foreach var of varlist * {
    cap replace `var' = .a if (`var'==-88)
  }

  // Generate binary treatment variable
  gen treatment = (oi_assign=="Treatment")
    lab var treatment "Treatment"
    lab def treatment ///
      0 "Control"     ///
      1 "Treatment"
    lab val treatment treatment

  // Save the dataset
  saveold "${Lab2}/endline_data_final.dta", replace v(12)
    use "${Lab2}/endline_data_final.dta", clear

// Have a lovely day! // Stata needs a blank line at the end of code. I like affirmations.
