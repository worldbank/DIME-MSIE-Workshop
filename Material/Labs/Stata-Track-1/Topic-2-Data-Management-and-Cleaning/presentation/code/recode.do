* Create variable locals
local income_vars inc_0? inc_1?

* Remove missing codes, and replace by missing values
recode `income_vars' (-99 = .a) (-88 = .b) (-66 = .c)
