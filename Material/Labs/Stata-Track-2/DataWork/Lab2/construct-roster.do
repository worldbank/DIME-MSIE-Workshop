// Merge the household master dataset onto the roster data

	use "${Lab2}/hh_roster_clean.dta" , clear

	merge m:1 hh_id ///
		using "${mastData}/master_households.dta"

		tab 	_merge // <- always!
		drop 	_merge // <- always!

	egen tag_hh = tag(hh_id)
		label var tag_hh "Household Tag"
		ta tag_hh // <- how many households are there?

// Save
	drop if mem_id == .	// <- It looks like these households did not complete surveys at all.
	isid hh_id mem_id , sort

	saveold "${Lab2}/hh_roster.dta" , replace v(12)
		use "${Lab2}/hh_roster.dta" , clear

// Have a lovely day!
