/*******************************************************************************
*		
*		Project:
*			DIME Field Coordinator Training
*			Lab 4 - Track 1
*			Exercise 1
*
********************************************************************************			
**Written by: Kristoffer Bjärkefur	
******************************************************************************/

	clear 
	
	qui do "C:\Users\kbrkb\Documents\GitHub\ietoolkit\src\ado_files\ieduplicates2.do"
	
	/* BEST PRACICE:
	global root				"/Users/laura"
	global labsession		"$root/Downloads"
	global lab4  			"$labsession/Lab4-Track1 Material"
	global dup_report		"$lab4/duplicates_report"
	*/
	
	*global lab4  			"C:\Users\<<ENTER YOUR COMPUTERS USERNAME>>"
	
	global dropbox 			"C:\Users\kbrkb\Dropbox"
	
	global data  			"$dropbox\FC Training\June 2018\data"
	global lab4				"$dropbox\FC Training\June 2018\Session Materials\Stata Track 1\Lab 4 - Data Quality Checks"
	
	global dup_report		"$lab4\"
	
/*=================================================================
	Load compiled data downloaded from server
=================================================================*/

	use "$endline_dtRaw/endline_data.dta" , clear


/*=================================================================
	Explore the raw data here			
=================================================================*/	
	
	
	count
	
	iecompdup id_05 ,id(21495) didiff
	iecompdup id_05 ,id(4099)  didiff
	iecompdup id_05 ,id(2116)  didiff


/*=================================================================
	Run ieduplicates		
=================================================================*/		
	
	ieduplicates id_05 , folder("$dup_report") uniquevars(key ) keepvars( text_audit submissiondate)

	sad

	count
