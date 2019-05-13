* Cleaning dofile for Lab 2

duplicates report id_05
duplicates drop id_05, force // <- Don't do this in reality, this is just a demo!
isid id_05 , sort
local id id_05 gr_16
local treatment oi_assign
local baseline numplots pl_hhsize pl_id_10 pl_id_09 pl_id_08
local hhh pl_age_1 pl_sex_1
local fs fs_??
local inc inc_01-inc_17 /// 🙄
local ag ag_16_x_16_1 ag_16_y_16_1 ag_16_z_16_1 ag_17_x_16_1 ag_17_y_16_1 ag_17_z_16_1 ag_18_x_16_1 ag_18_y_16_1 ag_18_z_16_1
keep `id' /// ID variables
`treatment' /// Treatment variables
`baseline' /// Baseline data
`hhh' /// Household head data
`fs' /// Food security data
`inc' /// Income data
`ag' /// Ag data for Plot A
foreach var of varlist * {
replace `var' = 0 if `var' == -88
}
save "${Lab2_dtFin}/endline_data_raw.dta", replace
use "${Lab2_dtFin}/endline_data_final.dta", clear

* Have a lovely day! <- Stata needs a blank line at the end of code. I like affirmations.
