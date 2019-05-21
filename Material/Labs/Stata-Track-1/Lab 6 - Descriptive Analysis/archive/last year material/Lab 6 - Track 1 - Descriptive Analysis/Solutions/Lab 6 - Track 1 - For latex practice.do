
global Dropbox "C:\Users\Kristoffer\Dropbox\"

global folder		"$Dropbox\FC Training\June 2017\Session Materials\Lab 6 - Descriptive Analysis\Lab 6 - Track 1 - Descriptive Analysis" 
global folderKris	"$Dropbox\FC Training - Kris\Lab 6 - test output"


*******
* Task1
*******

use "$folder\Test Scores.dta" , clear

*******
* Task2 
*******

estpost summarize english gender female_headed_hh 
esttab using "$folder/raw/sum_output.csv", cells("mean sd max min")  replace

esttab using "$folderKris/raw/sum_output.tex", cells("mean sd max min")  replace

estpost tabulate school 
esttab using "$folderKris/raw/tab_school.csv", cells("b pct")  replace
esttab using "$folderKris/raw/tab_school.tex", cells("b pct")  replace

esttab using "$folderKris/raw/school2.tex",  replace 	///
	cells   ("b(label(Frequency)) pct(fmt(%9.2f)label(Share))")		///	
	nomtitle nonumbers 		noobs									///	
		

estpost tabstat english science math, statistics(mean sd median max) by(gender)
esttab using "$folderKris/raw/test_scores.csv", cells("english science math") replace
esttab using "$folderKris/raw/test_scores.tex", cells("english science math") replace


*******
* Task3 - balance table
*******

iebaltab english math science female_headed_hh gender income, grpvar(school) save("$folderKris/raw/balance_table") 		replace
iebaltab english math science female_headed_hh gender income, grpvar(school) savetex("$folderKris/raw/balance_table") 	replace
