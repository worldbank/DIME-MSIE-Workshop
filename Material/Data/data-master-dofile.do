
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
	global datafolder "${mtrl_fldr}/Data"
	global data2018 "${datafolder}/2018-data"
	global data2use "${datafolder}/data-to-use"


    ***********************
    * Back Check
    ***********************
	
	************************
	*Load data set from 2018
    use "${data2018}/back_check_2018.dta", clear

	
	************************
	*Make changes to the back_check data set here
	
	
	
	************************
	*Save data set to use
    save "${data2use}/back_check.dta", replace


    ***********************
    * Endline Raw
    ***********************

    use "${data2018}/endline_data_raw_2018.dta", clear

	************************
	*Make changes to the endline data set here
	
	
	
	************************
	*Save data set to use
    save "${data2use}/endline_data_raw.dta" ,replace
	
	************************
	*Save data set to use
    save "${data2use}/endline_data_raw_nodup.dta" ,replace


    ***********************
    * Panel
    ***********************

	************************
	*Load data set from 2018	
    use "${data2018}/panel_data_2018.dta", clear

	************************
	*Make changes to the panel data data set here
	
	
	
	************************
	*Save data set to use
    save "${data2use}/panel_data.dta", replace
