* Project folder and Stata Track 1 Folder
global MSIE     "C:/Users/kbrkb/Dropbox/MSIE-workshop"
global track_1  "${MSIE}/Material/Labs/Stata-Track-1"

* Load original data
use "${track_1}/Data/endline_data_raw.dta", clear
    //  ... Work on your data here ...
* Save final data
use "${track_1}/Data/endline_modified.dta", clear
