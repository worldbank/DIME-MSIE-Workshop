* Suggested solution for Lab 5

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

	* Randomize a new treatment at the individual level

		gen random = runiform(0,1)
		xtile group = random , n(2)

		recode group (1=0 "Control")(2=1 "Treatment") , gen(treatment)

		gen n = _n
		ranksum n , by(treatment)

	* Save it

		saveold "${Lab5_dtFin}/hh_roster.dta", replace v(12)
			use "${Lab5_dtFin}/hh_roster.dta" , clear

* Do it again!

	set seed 580917
	use "${Lab5_dtInt}/hh_roster.dta", clear
		isid hh_id mem_id , sort
		drop hh_treatment

	gen random = runiform(0,1)
		xtile group = random , n(2)
		recode group (1=0 "Control")(2=1 "Treatment") , gen(treatment)

	cf _all using "${Lab5_dtFin}/hh_roster.dta"

* Have a lovely day!
