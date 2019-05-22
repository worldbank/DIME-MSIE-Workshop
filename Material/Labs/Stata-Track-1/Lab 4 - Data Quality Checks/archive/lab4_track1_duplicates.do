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
	
	ieduplicates id_05 , folder("C:\Users\kbrkb\Dropbox\FC Training\June 2018\Session Materials\Stata Track 1\Lab 4 - Data Quality Checks") uniquevars(key ) keepvars( text_audit submissiondate  enumerator_ID supervisor_ID pl_id_09)

	count
	

