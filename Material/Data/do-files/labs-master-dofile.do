
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
	local track_1_data_needed endline_data_raw panel_data

	foreach file of local track_1_data_needed {
		di "Copying file ${data2use}/`file'.dta to Stata Track 1 Data folder"
		copy "${data2use}/`file'.dta" "${stata_track_1}/Data/`file'.dta", replace
	}




    ***********************
    * Topic 1
    ***********************

	*Start with data copied above and do solutions track 1 and save data

    ***********************
    * Topic 2
    ***********************

	*Start with data saved in end of topic 1 and do solutions track 2 and save data

    ***********************
    * Topic 3
    ***********************

	*Start with data saved in end of topic 2 and do solutions track 3 and save data

    ***********************
    * Topic 4
    ***********************

	*Start with data saved in end of topic 3 and do solutions track 4 and save data

    ***********************
    * Topic 5
    ***********************

	*Start with data saved in end of topic 4 and do solutions track 5 and save data

    ***********************
    * Topic 6
    ***********************

	*Start with data saved in end of topic 5 and do solutions track 6 and save data


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

	*Start with data copied above and do solutions track 1 and save data

    ***********************
    * Topic 2
    ***********************

	*Start with data saved in end of topic 1 and do solutions track 2 and save data

    ***********************
    * Topic 3
    ***********************

	*Start with data saved in end of topic 2 and do solutions track 3 and save data

    ***********************
    * Topic 4
    ***********************

	*Start with data saved in end of topic 3 and do solutions track 4 and save data

    ***********************
    * Topic 5
    ***********************

	*Start with data saved in end of topic 4 and do solutions track 5 and save data

    ***********************
    * Topic 6
    ***********************

	*Start with data saved in end of topic 5 and do solutions track 6 and save data
