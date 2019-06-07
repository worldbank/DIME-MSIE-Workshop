** This command harmonizes settings among users. One of those settings is setting the version
*  of Stata. This is the FIRST RULE for a replicable randomization
ieboilstart , version(12.0)
`r(version)'

*Load the data from topic 2, we did not save data in topic 3
use "${ST1_dtInt}/endline_data_post_topic2.dta", clear

** Setting seed. This is the SECOND RULE for a replicable randomization. Any random number
*  between 0 and 2^31. Use random.org to create a unique number. Use at least 6 digits
set seed 615618615

* Stable sort this is the THIRD RULE for a replicable randomization.
isid id_05, sort // isid also checks that IDs are unique
