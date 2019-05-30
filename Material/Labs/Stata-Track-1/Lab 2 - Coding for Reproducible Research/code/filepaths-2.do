* Set folder global
global folder_Lab1  "C:/Users/WB462869/FCtraining/Lab1"

* Load original data
use "${folder_Lab1}/endline_data_raw.dta", clear
    //  ... Work on your data here ...
* Save final data
save "${folder_Lab1}/endline_data_raw.dta", replace
