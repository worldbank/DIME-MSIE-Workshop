
	/* ******************************************************************* *
	* ******************************************************************** *

		This master do-file sets up the data needed for the Managing 
		Successful Impact Evaluations workshop (also known as the FC training).

		To replicate all files, set up your root folder in the 
		\DIME-MSIE-Workshop\Material\master-dofile.do file and then run
		this file.

	* ******************************************************************** *
	* ******************************************************************* */

	*Create globals for the data work folder
	global data2use 		"${mtrl_fldr}/Data/data-to-use"
	
	global stata_track_1 	"${mtrl_fldr}/Labs/Stata-Track-1"
	global stata_track_2 	"${mtrl_fldr}/Labs/Stata-Track-2"


	/* ******************************************************************* *
	*  ******************************************************************* *	
	
		Stata Track 1
	
	* ******************************************************************** *
	* ******************************************************************** */
	
	*Add the files needed to be copies to 
	local track_1_data_needed endline_data_raw

	foreach file of local track_1_data_needed {
		di "Copying file ${data2use}/`file'.dta to Stata Track 1 Data folder"
		copy "${data2use}/`file'.dta" "${stata_track_1}/Data/`file'.dta", replace
	}
	
	
	
	
    ***********************
    * Topic 1
    ***********************
	
	
	
    ***********************
    * Topic 2
    ***********************	

    ***********************
    * Topic 3
    ***********************
	
    ***********************
    * Topic 4
    ***********************
	
    ***********************
    * Topic 5
    ***********************
	
    ***********************
    * Topic 6
    ***********************
	
	
	

	/* ******************************************************************* *
	*  ******************************************************************* *	
	
		Stata Track 2
	
	* ******************************************************************** *
	* ******************************************************************** */
	
	*Add the files needed to be copies to 
	local track_2_data_needed endline_data_raw

	foreach file of local track_1_data_needed {
		di "Copying file ${data2use}/`file'.dta to Stata Track 2 Data folder"
		copy "${data2use}/`file'.dta" "${stata_track_2}/Data/`file'.dta", replace
	}
	
	
	
	
    ***********************
    * Topic 1
    ***********************
	
	
	
    ***********************
    * Topic 2
    ***********************	

    ***********************
    * Topic 3
    ***********************
	
    ***********************
    * Topic 4
    ***********************
	
    ***********************
    * Topic 5
    ***********************
	
    ***********************
    * Topic 6
    ***********************
