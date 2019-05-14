* Construct Household Master Data

* Start by using the dataset we created in Lab 2.
* We are going to turn this into a "Household Master Dataset"

	use "${Lab3_dtInt}/Lab2_endline_data_final.dta" , clear

	* One problem is that we kept roster variables from person #1 as head of household.
	* Let's clean that up and rename *all* our variables as "household" variables.

		rename id_05 id

		label var inc_t "Total Income"
		label var pl_age_1 "Household Head Age"
			rename pl_age_1 head_age
		label var pl_sex_1 "Household Head Gender"
			rename pl_sex_1 head_gender

		rename * hh_* 			// <- [rename] has a powerful syntax for mass renames. Do [h rename] for details!
		rename *pl_* *[1]*[2] 	// <- Here, we use it to remove the "preload" code from variable names.

	* Save this data as a master dataset.

		isid hh_id , sort			// Master data must be 100% clean in IDs
		order * , sequential		// It should also be logically structured...
			order hh_id* , first	// ...with the ID variable first.
		compress					// [compress] makes sure you are not wasting space.

		saveold "${mastData}/master_households.dta" , replace v(12) // <- be kind to your teams. [saveold].
			use "${mastData}/master_households.dta" , clear			// <- really, you'll use this a lot.

* Have a lovely day! <- Stata needs a blank line at the end of code. I like affirmations.
