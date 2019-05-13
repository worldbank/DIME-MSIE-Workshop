* Suggested solution for Lab 5

* Clusters

	* Setup

		clear all
		ieboilstart, v(12.0)
		`r(version)'

		 di `c(version)'

		 set seed 580917 // <- generated on Random.org at Timestamp: 2018-06-09 22:20:43 UTC

	* Load the data

		use "${Lab5_dtInt}/hh_roster.dta", clear

			isid hh_id mem_id , sort

		* Drop the existing treatment assignment

			drop hh_treatment

	* Randomize a new treatment at the *household* level

		keep if tag_hh == 1

		gen random = runiform(0,1)
		xtile group = random , n(2)

		recode group (1=0 "Control")(2=1 "Treatment") , gen(treatment)

		gen n = _n
		ranksum n , by(treatment)

	* Apply to the whole dataset

		tempfile hh_treatment
			save `hh_treatment'

		use "${Lab5_dtInt}/hh_roster.dta", clear

		merge m:1 hh_id using `hh_treatment' , keepusing(treatment) nogen

	* Verify

		ta treatment
		ta treatment if tag_hh == 1

	* Save it

		saveold "${Lab5_dtFin}/hh_roster.dta", replace v(12)
			use "${Lab5_dtFin}/hh_roster.dta" , clear

* Clusters and strata

	* Setup

		clear all
		ieboilstart, v(12.0)
		`r(version)'

		 di `c(version)'

		 set seed 580917 // <- generated on Random.org at Timestamp: 2018-06-09 22:20:43 UTC

	* Load the data

		use "${Lab5_dtInt}/hh_roster.dta", clear

			isid hh_id mem_id , sort

		* Drop the existing treatment assignment

			drop hh_treatment

	* Randomize a new treatment at the *household* level

		keep if tag_hh == 1

		encode hh_id_09 , gen(strata)

		randtreat ///
		, generate(treatment) ///
			strata(strata) ///
			misfits(global)

	* Apply to the whole dataset

		tempfile hh_treatment
			save `hh_treatment'

		use "${Lab5_dtInt}/hh_roster.dta", clear

		merge m:1 hh_id using `hh_treatment' , keepusing(treatment strata) nogen

	* Verify

		ta strata treatment if tag_hh == 1, row

	* Save it

		saveold "${Lab5_dtFin}/hh_roster.dta", replace v(12)
			use "${Lab5_dtFin}/hh_roster.dta" , clear

* Have a lovely day!
