** This command harmonizes settings among users. One of those settings is setting the version
*  of Stata. That is the FIRST RULE for a replicable randomization
ieboilstart , version(12.0)
`r(version)'

* Update this global to where you stored the data set for this exercise
global folder "C:/Users/username/Docuemnts/myProject"

*Load the data. School and district
use "${folder}/data/Test Scores.dta", clear

** Setting seed. This is the SECOND RULE for a replicable randomization. Any random number
*  between 0 and 2^31. Use random.org to create a unique number. Use at least 6 digits
set seed 615618615

* Stable sort this is the THIRD RULE for a replicable randomization.
isid student_id, sort // This also checks that IDs are unique
