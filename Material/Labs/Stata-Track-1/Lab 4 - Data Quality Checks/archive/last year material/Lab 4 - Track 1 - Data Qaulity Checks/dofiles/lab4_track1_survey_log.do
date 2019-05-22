/*******************************************************************************
*		
*		Project:
*			DIME Field Coordinator Training
*			Lab 4 - Track 1
*			Exercise 2
*
********************************************************************************			
	Written by:	Laura Costica, DECIE
********************************************************************************/
	
	clear 
	set more off

	/* BEST PRACICE:
	global root				"/Users/laura"
	global labsession		"$root/Downloads"
	global lab4  			"$labsession/Lab4-Track1 Material"
	*/
	
	global lab4  		"C:\Users\wb503680\Downloads\MyThes-1\Lab 4 - Real-time Data Quality Checks\Lab 4 - Real-time Data Quality Checks\Track 1\data" 
	
	use "$lab4/baseline.dta", clear

	/* 1.	Check the number of surveys by: 
	•	team, enumerator
	•	team and gender
	•	team and type of respondent
	•	by gender of respondent: team 
	*/

	tab hhidteam
	tab enum_name
	

	/* 2.	Calculate survey duration and check which enumerators have surveys that are in the 1%, 5% and 10% percentiles of survey durations */
			
	gen survey_duration = round((endtime - starttime) / 1000 / 60)
	sum survey_duration, d


