******
* Back Check
****

use "2018-data/back_check_2018.dta"



save "back_check.dta"


******
* Endline Raw
****

use "2018-data/endline_data_raw_2018.dta"




save "endline_data_raw.dta"

*Drop nodup

save "endline_data_raw_nodup.dta"


******
* Panel
****
use "2018-data/panel_data_2018.dta"



save "panel_data.dta"
