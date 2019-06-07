* Generate a variable that is HH total income by size
generate inc_per_hh_member = inc_t / pl_hhsize

* Label variables clearly
label variable inc_per_hh_member "HH total income by HH size"

* Summarize
summarize inc_per_hh_member

* Generate a dummy that 1 if per capita income is greater than than 500,000 francs.
generate high_income = 0
replace  high_income = 1 if (inc_per_hh_member > 500000) & !missing(inc_per_hh_member)

* Tabulate the result
tabulate high_income
