********************************************************************************
*    Task 1 and 2: Load data set and set the three rules of randomization
********************************************************************************

	*Alwasys start
	ieboilstart , version(12.0)
	`r(version)'

	* Save data after topic 3
    save "${ST1_dtInt}/endline_data_post_topic3.dta",  clear

	** Setting seed. This is the second rule for a
	*  replicable randomization. Can be any random number
	*  between 0 and 2^31, use random.org to create a unique
	*  number for you. Use at least 6 digits
	set seed 615618615

	** Stable sort. This is the third rule for a
	*  replicable randomization.
	isid id_05, sort

	********************************************************************************
	*    Task 1 : Basic binary randomization
	********************************************************************************

	** Generate a variable with a random number for all
	*  observations and sort the observations after that
	*  number.
	generate 	rand = runiform()
	sort 		rand

	** Create one variable with the rank on the random
	*  number. And a varaible with the total number of
	*  observations.
	generate rank 	 = _n
	generate tot_obs = _N

	** Create the treatment variable. Change the value
	*  to 1 if the rank is more than half the number
	*  of total observations in the data set.
	generate 	treatment = 0
	replace 	treatment = 1 (if rank > tot_obs/2)

	*Create a label docuementing the treatment variable
	label define 			treat_lab 0 "Control" 1 "Treatment"
	label values treatment 	treat_lab

	*Test the randomization
	tabulate treatment

	*********
	** This is the same as the code above but does not
	*  require you creating the variables rank and
	*  tot_obs. This is shorter but might be more diffcult
	*  to read for someone following your code.
	generate 	 treatment_2 = (_n > _N/2)
	label values treatment_2 treat_lab

	*Test that both randomizations indeed are identical
	tabulate treatment_2 treatment

	********************************************************************************
	*    Task 2 : Multi arm randomization
	********************************************************************************

	** Redo the stable sort. This is the third rule
	*  for a replicable randomization. (We do not need to
	*  set verion and seed again as long as we always run
	*  the do-file from the very top)
	isid id_05, sort

	** Start identical to the randomization above. Create
	*  a random varaible and sort the observations on it.
	generate 	rand_multi = runiform()
	sort 		rand_multi

	*Create the rank and tot_obs var. See above for exlinations.
	generate rank_multi 	= _n
	generate tot_obs_multi 	= _N

	** Create a the treatment variable and assign a third
	*  of the observations to each treatment.
	generate 	treatment_multi = 0											//Set all to 0
	replace 	treatment_multi = 1 if (rank_multi > 1 * tot_obs_multi/3)		//Set the upper two thirds to 1
	replace 	treatment_multi = 2 if (rank_multi > 2 * tot_obs_multi/3)		//Set the upper third to 2

	*Create a label docuementing the treatment variable
	label define 				 treat_lab_multi 0 "Ctrl" 1 "Tmt1" 2 "Tmt2"
	label values treatment_multi treat_lab_multi

	** Compare the result from the two random treatment
	*  assignments. Even though we used the same seed
	*  there is no relation between the two randomizations.
	*  Depending on your the seed you used you might
	*  get some correlation, but that is by random,
	*  test with a different seed. However, never change
	*  the seed in a real life randomization due to this.
	tabulate treatment_multi treatment

	** Sort the data set after its initial sort and browse
	*  the treatment vars we generated
	sort 	id_05
	browse 	id_05 treatment treatment_multi
