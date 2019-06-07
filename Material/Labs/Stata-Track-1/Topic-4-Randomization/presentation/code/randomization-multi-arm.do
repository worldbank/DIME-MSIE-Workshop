* Start identical to the binary randomization above.
gen  rand_multi = runiform()
sort rand_multi

*Create the rank and tot_obs var. See above for exlinations.
gen rank_multi    = _n
gen tot_obs_multi = _N

** Create a the treatment variable and assign a third
*  of the observations to each treatment.
generate treatment_multi = 0                                        //Set all to 0
replace  treatment_multi = 1 if (rank_multi > 1 * tot_obs_multi/3)  //Set the upper two thirds to 1
replace  treatment_multi = 2 if (rank_multi > 2 * tot_obs_multi/3)  //Set the upper third to 2

*Create a label docuementing the treatment variable
label define                 treat_lab_multi 0 "Ctrl" 1 "Tmt1" 2 "Tmt2"
label values treatment_multi treat_lab_multi

tab treatment_multi // Display the assignment
