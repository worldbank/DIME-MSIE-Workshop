/* *************************************************************************** *
*						Lab Session 2							  			   *												   
*																 			   *
*  PURPOSE:  			This solution file is a suggested solution 			   *
						for how the file might look in the end of 			   *	
						the excercise. 										   *
																			   *
						Some lines of code (for example setting up             *
						the global) is in the top of thuis file, 			   *
					    although you are not asked to do that until			   *
						in one of the last tasks. 							   *  
																			   *
																			   *
*  WRITEN BY:  			Michael	Orevba	  									   *
*  Last time modified:  June 2018											   *
*																			   *
********************************************************************************


********************************************************************************
* 							PART 1: SETTINGS
*******************************************************************************/

*-------------------------------------------------------------------------------
* 						1.1 Initial settings
*-------------------------------------------------------------------------------

	* Install required packages
	if 0 {																		
		ssc install ietoolkit, replace
	}

	*Standardize settings accross users
    ieboilstart, version(13.0)      											
    `r(version)'   
	
	*set maxvar 32767, perm
	   
*-------------------------------------------------------------------------------
* 						1.2 Create file path globals
*-------------------------------------------------------------------------------

   * Users																		
   * -----
    if c(username) == "kbjarkefur" {
       global projectfolder "\Users\kbjarkefur\Dropbox\FC Training\June 2018"
	}

   if c(username) == "wb506743" {
		global projectfolder "C:\Users\wb506743\Dropbox\FC Training\June 2018"
   }
   *
   
   * Project folder globals
   * ---------------------
   global dataWorkFolder        "$projectfolder\data"

   	
*-------------------------------------------------------------------------------
* 						2.1 Lab Task 1
*-------------------------------------------------------------------------------	
	
	*Open the data set
	use "$dataWorkFolder\Rwanda_LWH_OI_Panel", clear 	
	
	
	*Open the second data set
	use "$dataWorkFolder\Rwanda_LWH_OI_Panel_12", clear	
	
	
	
	
	exit
	
	
	
	
	
	
	
	
	************
	*Task 2
	************
	
	*Open the data set
	use "$folder_lab1\data\practice_data.dta", clear

	
	*Browse the data
	browse
	
	*Describe the data
	describe
	
	*Summarize the data
	summarize 				//Variable make has no mean as it is a string variable
	
	
	**Variable price
	
	*Tabulate price
	tabulate price 			//Tabulations works but are note great with continous variables
	
	*Summarize price
	summarize price, detail //See max and min and mean in the output
	
	*Codebook for price
	codebook price 			//All 74 values are unique

	************
	*Code included in slides between task 2 and 3
	************	
	
	*Generate a variable that is the price
	*per mile per gallon (mpg)
	generate price_per_mpg = price / mpg

	*Summarize 
	summarize price_per_mpg 

	*Generate a dummy that 1 if the car 
	*cost more than 10,000 USD.
	generate expensive = 0
	replace  expensive = 1 if price > 10000

	*Tabulate the result
	tabulate expensive

	*Label variables clearly
	label variable price_per_mpg "Price per miles per gallon"
	label variable expensive 	 "Dummy for cars costing more than 10,000"

	*Create the label
	label define exp 1 "Expensive >10K" 0 "Not Expensive <10K"
	*Apply the label to the variable
	label value expensive exp

	*Tabulate the variable again, then
	*browse it together with price
	tabulate expensive
	browse 	 expensive price

	************
	*Task 3
	************
	
	*Create a new variable that measures
	*the turn radius in inches
	generate turn_inches = turn * 12
	
	*Create a new variable that measures
	*the turn radius in centimeters
	generate turn_centimeter = turn * 30.48

	*Label variables clearly
	label variable turn_inches 		"Turn Circle (in.)"
	label variable turn_centimeter 	"Turn Circle (cm)"
	
	*Generate a dummy that 1 if the car 
	*weighs more than 4,000lbs.
	generate heavy = 0
	replace  heavy = 1 if weight > 4000  //This will be changes in a later exercise to 3500

	*Tabulate the result
	tabulate heavy

	*Label variables clearly
	label variable heavy_lbl 	 "Dummy for cars weighing more than 4,000 lbs"
	
	*Create the label
	label define heavy 1 "heavy >4000 lbs" 0 "Not heavy <4000 lbs"
	*Apply the label to the variable
	label value heavy heavy_lbl

	
	************
	*Task 4
	************
	
	*change the code above

	************
	*Task 5
	************	
	
	*Save final data 
	save "$folder_lab1\Solutions\practice_data_final.dta", replace
	
	
	************
	*Code for slides between task 5 and 6
	************		
	
	*Define locals
	local numberA 3
	local numberB 5

	*Use locals
	gen restult_var = (`numberA' * `numberB') - `numberA'

	*Define global
	global project GAFSP

	*Use globals
	gen country_${project} 	= "Kenya"
	gen donor_${project} 	= "World Bank"

	************
	*Task 6
	************
	
	*already entered in the code above
	
	************
	*Task 7
	************	
	
	*Open the data set
	use "$folder_lab1\data\practice_data.dta", clear
	
	*Summarize the data
	summarize
	
	*Produce a table over variables with missing values
	misstable summarize
	
	*Tabulate missing values
	tabulate rep78
	tabulate rep78, missing
	
	************
	*Task 8
	************
	
	*Importing excel (if you are using and older version of Stat this code might look different)
	import excel "$folder_lab1\data\village_codes.xls", sheet("Sheet1") firstrow clear
	

