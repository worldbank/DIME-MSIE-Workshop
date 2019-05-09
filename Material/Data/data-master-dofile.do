
******
* Back Check
****

use "back_check_2019.dta", clear



save "back_check.dta" // , replace?


******
* Endline Raw
****

use "endline_data_raw_2019.dta", clear




save "endline_data_raw.dta" //, replace?

*creating nodup

save "endline_data_raw_nodup.dta"


******
* Panel
****
use "panel_data_2019.dta", clear



save "panel_data.dta" //, replace?
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

