******
* Global
****
*Set directory
gl directory "C:\Users\Saori\Documents\Github\DIME-MSIE-Workshop\Material\Data\2018-data" 
cd "C:\Users\Saori\Documents\Github\DIME-MSIE-Workshop\Material\Data"

******
* Creating copy for 2019
****
copy "$directory/back_check_2018.dta" "back_check_2019.dta", replace
copy "$directory/endline_data_raw_2018.dta" "endline_data_raw_2019.dta", replace
copy "$directory/panel_data_2018.dta" "panel_data_2019.dta", replace

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
