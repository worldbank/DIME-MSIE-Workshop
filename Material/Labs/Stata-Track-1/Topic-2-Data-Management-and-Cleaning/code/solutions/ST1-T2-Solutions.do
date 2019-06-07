
********************************************************************************
*    Task 1: Set up master do-file
********************************************************************************

    * done in the master do-file

********************************************************************************
*    Task 2: Done in the do-file for previous topic
********************************************************************************

    * done in the master do-file

********************************************************************************
*    Task 3: Test unit of ovbservation
********************************************************************************

    *Alwasys start
    ieboilstart , version(12.0) noclear
    `r(version)'

    *Open data from last topic
    use "${ST1_dtInt}/endline_data_post_topic1.dta",  clear

    *Use codebook to explore ID variable candidate
        codebook id_05

    *Test that variable is a valid ID variable - if not it will break
        isid id_05

********************************************************************************
*    Task 4: Destring and encode
********************************************************************************

	*Define the label with codes already in use
		label define dist 44 "Burera" 41 "Gicumbi" 54 "Kayonza" 55 "Rulindo" 51 "Rwamagana"

	*Encode the varaible using that label
		encode  pl_id_09,  gen(pl_id_09_code) label(dist) noextend

	*Move the new variable next to the old one
		order pl_id_09_code, after(pl_id_09)

********************************************************************************
*    Task 5: Replace survey codes for missing values
********************************************************************************

	*Summarize compost use
		summarize ag_08_1_1

	*Replace -99 with missing value .a
		replace ag_08_1_1 = .a if (ag_08_1_1 == -99)

	*Summarize again
		summarize ag_08_1_1

********************************************************************************
*    Task 6: Peplace survey codes at bulk
********************************************************************************

    * Create variable locals
         local income_vars inc_0? inc_1?

    * Remove missing codes, and replace by missing values
         recode `income_vars' (-99 = .a) (-88 = .b) (-66 = .c)

********************************************************************************
*    Task 7: Find outliers
********************************************************************************

	*Summarize the following four variables
	    summarize `income_vars', detail

********************************************************************************
*    Task 8: Winsorization
********************************************************************************

    * Summarize and look at means
        sum inc_01

	*Install winsor command
		ssc install winsor

	*Winsorixe INC_01
		winsor inc_01 , gen(inc_01_w) high p(.05)

	*Compare the original variable with the winsorized one
		sum inc_01 inc_01_w
		sum inc_01 inc_01_w, d

********************************************************************************
*    Task 9: Save data
********************************************************************************

    * Save data after topic 2
    compress
    save "${ST1_dtInt}/endline_data_post_topic2.dta",  replace
