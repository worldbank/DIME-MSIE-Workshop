* Project folder and Stata Track 1 Folder
global MSIE          "C:/Users/kbrkb/Dropbox/MSIE-workshop"
global folder_topic1 "${MSIE}/Material/Labs/Stata-Track-1"

* Load original data
use "${folder_topic1}/Data/endline_data_raw_nodup.dta", clear
    //  ... Work on your data here ...
* Save final data
save "${folder_topic1}/Data/endline_data_post_topic1.dta", clear
