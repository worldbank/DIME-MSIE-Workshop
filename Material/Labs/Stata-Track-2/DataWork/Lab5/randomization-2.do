* Suggested solution for Lab 5

	* Setup

		clear all
		ieboilstart, v(12.0)
		`r(version)'

		 di `c(version)'

		 set seed 580916 // <- generated on Random.org at Timestamp: 2018-06-09 22:20:43 UTC

	* Load the data

		use "${Lab5_dtInt}/hh_roster.dta", clear

			isid hh_id mem_id , sort

		* Drop the existing treatment assignment

			drop hh_treatment

	* Randomize a new treatment at the individual level

		gen random = runiform(0,1)
		xtile group = random , n(5)

		recode group (1=0 "Control") ///
			(2=1 "Treatment A")(3=2 "Treatment B")(4=3 "Treatment C")(5=4 "Treatment D") ///
		, gen(treatment)

	* Save it

		saveold "${Lab5_dtFin}/hh_roster.dta", replace v(12)
			use "${Lab5_dtFin}/hh_roster.dta" , clear

* With [randtreat]

	ssc install randtreat

	* No misfits

		set seed 580916
		use "${Lab5_dtInt}/hh_roster.dta", clear
			isid hh_id mem_id , sort
			drop hh_treatment

		randtreat , generate(treatment) multiple(5)

	* Misfits

		set seed 580916
		use "${Lab5_dtInt}/hh_roster.dta", clear
			isid hh_id mem_id , sort
			drop hh_treatment

		randtreat ///
		, generate(treatment) ///
			multiple(5) ///
			misfits(global)

* Have a lovely day!
