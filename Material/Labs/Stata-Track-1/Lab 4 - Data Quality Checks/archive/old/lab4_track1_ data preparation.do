/*******************************************************************************
*		
*		Project:
*			DIME Field Coordinator Training 2018
*			Lab 4 - Track 1
*			PREPARATION OF THE RAW DATA
*
********************************************************************************			
In this dofile, we create the variables we need for the lab*/


	
	clear 
	set more off
	
   * User
   * -----------
   *User Number:
   * Kris	               1  
   * Aurelie               2

   global user 2

	*set globals
   if $user == 1 {
       global lab4 "XXXX"
   }
   if $user == 2 {
       global lab4 "D:\Dropbox\FC Training\June 2018\data"   
   }
   
   *allow more variables
	set maxvar 30000
	   
   *open the dataset
	use "$lab4/Rwanda_LWH_Raw_12.dta", clear

***********************************************************************************

/* to generate:
- enumerator ID
- enumerator team ID
- importdate
- gen duplicates forms using respondent ID 
- gen duplicates forms using starting dates and time (but repsondent ID are different)
	--> 2 similiar forms but respondent ID is different
- reduce the nbr of variables ? (to run codes faster)



Note: id_05 = respondent unique ID
	  area_1 pl_id_09 pl_id_10 pl_id_08 are districts, sectors, villages variables. 

*/


	*gen importdate:
	egen  importdate=group(pl_id_08)
	label var importdate "Date the observation was imported- month of June"
	codebook importdate
		* data downloaded 26 times
	

	*
