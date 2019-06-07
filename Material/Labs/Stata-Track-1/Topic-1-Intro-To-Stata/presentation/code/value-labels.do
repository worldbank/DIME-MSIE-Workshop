* Create the label
label define high_income_lab 1 "Per Capita Income >500K" 0 "Per Capita Income <=500K"

* Appy the label to the variable
label value high_income high_income_lab

* Tabulate the variable again, then browse it together with HH income by HH size
tabulate high_income
browse   high_income inc_per_hh_member
