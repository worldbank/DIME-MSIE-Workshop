global Dropbox "C:\Users\WB462869\Dropbox\"
*global Dropbox "C:\Users\Kristoffer\Dropbox\"

global folder		"$Dropbox\FC Training\June 2017\Session Materials\Lab 6 - Descriptive Analysis\Lab 6 - Track 1 - Descriptive Analysis" 


*******
* Task1
*******

	use "$folder\Test Scores.dta" , clear

	summarize english gender female_headed_hh 

	tabulate income
	tabulate school 

	tabstat english science math, statistics(mean sd median max) by(gender)

***********
* Task2 -  There is no need to 
***********

	*Summarize egnlish, gender and female headed household
	estpost summarize english gender female_headed_hh 
	esttab using "$folder/raw/sum_output.csv", cells("mean sd max min")  replace

	*Tabulate the number of observations from each school
	estpost tabulate school 
	esttab using "$folder/raw/tab_school.csv", cells("b pct")  replace

	*Output a tables of the test scores in all topics, for boys and for girls
	estpost tabstat english science math, statistics(mean sd median max) by(gender)
	esttab using "$folder/raw/test_scores.csv", cells("english science math") replace


***********
* Task4
***********


	iebaltab english math science female_headed_hh gender income, grpvar(school) save("$folderKris/raw/balance_table") replace

	
***********
* Task5
***********	
	
	*Generate a graph with the mean of the test scores
	graph bar english math science

	*Generate a graph with the distribution of income
	histogram income

	*Create a scatter plot showing the relation between math and science scores.
	twoway scatter math science

	
***********
* Task6
***********	
	
	*Generate a graph with the mean of the test scores
	*Manually set the legend labels
	graph bar english math science, legend(lab(1 "English") lab(2 "Mathematics") lab(3 "Science" ))

	*Generate a graph with the distribution of income
	*Add a title to the graph
	histogram income, title("Distribution of Income")

	*Create a scatter plot showing the relation between math and science scores.
	*Add a linear prediction line showing the realtion ship of math and science scores 
	twoway (scatter math science) (lfit math science) 

	
***********
* Task7
***********	

	*Create a scatter plot showing the relation between math and science scores.
	twoway (scatter math science) (lfit math science) 
	graph export "$folder/raw/graph_math_science.png", replace
	