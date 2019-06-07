** Generate a variable with a random number for all observations and sort
* the observations after that number.
gen   rand = runiform()
sort  rand

** Create one variable with the rank on the random number. And a varaible
*  with the total number of observations.
gen rank    = _n
gen tot_obs = _N

** Create the treatment variable. Change the value to 1 for observations where the rank
*  is more than half the number of total number of observations in the data set.
gen     treatment = 0
replace treatment = 1 if (rank > tot_obs/2)

* Create a label docuementing the treatment variable
label define           treat_lab 0 "Control" 1 "Treatment"
label values treatment treat_lab

tab treatment // Display the assignment
