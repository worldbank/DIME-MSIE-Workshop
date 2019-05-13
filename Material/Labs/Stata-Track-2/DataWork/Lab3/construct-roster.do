
* Merging the household master dataset onto the roster data.

	use "${Lab3_dtInt}/hh_roster_clean.dta" , clear // <- [use] shoud be used a lot, so that code is modular.

	merge m:1 hh_id /// <- why is is m:1 and not 1:m? which is the "using" dataset and which is the "master"?
		using "${mastData}/master_households.dta"

		tab 	_merge // <- always!
		drop 	_merge // <- always!

	egen tag_hh = tag(hh_id)
		label var tag_hh "Household Tag"
		ta tag_hh // <- how many households are there?

* Save

	drop if mem_id == .			// <- It looks like these households did not complete surveys at all.
	isid hh_id mem_id , sort

	saveold "${Lab3_dtFin}/hh_roster.dta" , replace v(12)
		use "${Lab3_dtFin}/hh_roster.dta" , clear

* Have a lovely day! <- Stata needs a blank line at the end of code. I like affirmations.
