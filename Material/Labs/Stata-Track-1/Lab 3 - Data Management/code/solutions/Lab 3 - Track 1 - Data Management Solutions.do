
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

    *Open that data
    use "${ST1_dtInt}/endline_data_post_lab2.dta",  clear

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
*    Task 5: Missing values
********************************************************************************

	*Summarize compost use
		summarize ag_08_1_1

	*Replace -99 with missing value .a
		replace ag_08_1_1 = .a if ag_08_1_1 == -99

	*Summarize again
		summarize ag_08_1_1

********************************************************************************
*    Task 6: Missing values
********************************************************************************

	*Summarize the following four variables
		summarize aa_02_1 aa_02_2 aa_02_3 aa_02_4 aa_02_5 aa_02_6 aa_02_7 aa_02_8 aa_02_9 aa_02_10, detail
		summarize aa_02_? aa_02_10, detail

********************************************************************************
*    Task 7: Winsorization
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
*    Task 8: Save data
********************************************************************************

    * Save data after topic 3
    save "${ST1_dtInt}/endline_data_post_topic3.dta",  clear
