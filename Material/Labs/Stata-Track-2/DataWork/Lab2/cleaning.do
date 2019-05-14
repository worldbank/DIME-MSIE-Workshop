* Lab 3 cleaning dofile

* Open the Lab3 dataset.

		use "${Lab3_dtInt}/endline_data_raw.dta" , clear

	* We are going to keep only variables from the household roster.

		keep id_05 age_* pl_sex_* education_*
			drop *str* *new*

	* Investigation

		codebook, compact

		duplicates report id_05
		duplicates list id_05

		codebook education_1

		summarize education_1, detail

		histogram education_1

	* Reshaping the household roster data

		duplicates drop id_05 , force

		rename edu*_* edu*[2]
		rename *sex_* sex*[2]
		rename age_* age*

		rename id_05 hh_id

		reshape long age sex edu, i(hh_id) j(mem_id)

	* Cleaning

		drop if sex == .
		label var mem_id "Member ID"

		label var age "Age"
		label var sex "Sex"
			label def sex 1 "Male" 2 "Female" , modify
			label val sex sex
		label var edu "Education"

		numlabel ed_level , add

		tab edu, missing plot
			replace edu = .a if edu == -88
			replace edu = .b if edu == -66

		label def ed_level .a "Don't Know" .b "Refused" , modify
		numlabel ed_level , remove force

	* Save this.

		saveold "${Lab3_dtInt}/hh_roster_clean.dta" , replace v(12)
			use "${Lab3_dtInt}/hh_roster_clean.dta" , clear

* Have a lovely day! <- Stata needs a blank line at the end of code. I like affirmations.
