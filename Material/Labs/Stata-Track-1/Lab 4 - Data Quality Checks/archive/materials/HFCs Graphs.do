/*******************************************************************************	
*		Project: GAFSP Liberia
*		Midline Pilot Follow Up Survey (May 2017): Pilot Study
********************************************************************************
** PURPOSE: 	This do-file runs the HFCs Graphs on the survey datasets  
				as they roll in daily. 		
				
** ID VARS:		key

** CREATES:			
		Output files:
				This do-file creates flags that signals certain enumerator performance
				issues. Exports these flags into summary sheets in Dropbox paper
				to display enumerator performance.
								
**Written by:	Michael Orevba
******************************************************************************/

noi di "Set default settings, set root folders & prepare locals"

*	SET DEFAULT STATA SETTINGS
	clear all
	set more off , perm
	pause on

	version 12.1
	
*	SET ROOT FOLDER & PREPARE locals

	//Michael's Path - MAC
	if c(username) == "michaelorevba" {
		global box "/Users/michaelorevba/Box Sync/"
		}	

	//Aurelie's path	
	if c(username) == "________" {		
		global box "C:\Users\_______\Box Sync\"
		}	
	
	//Paul's path
	if c(username) == "wb________" {		
		global box "C:\Users\wb________\Box Sync\"
		}	
	
	global project		"$box/GAFSP Liberia/Baseline"
	global data 		"$project/Data"
	global graph		"/Users/michaelorevba/Dropbox/DATA RSA LIBERIA GAFPS/Documentation/HFCs ouputs/Graphs"
	global graph2 		"$project/Documentation/HFCs outputs"
	global do 			"$project/Do-files/"
	local date			"14August17"
	local identifier 	"enum_id enum_name county district area HFC_eligible"
	
*Open raw dataset from Box
*use "$data/Liberia baseline RETRAINING-07.05.dta", clear
use "$data/Intermediate data/temp_liberia.dta", clear 


duplicates tag respondent_name, gen(dup_name2)
drop if dup_name2>0
*drop if dup2>0			
*drop if old_form==1 & dup2==0
	
	
*Create a HH consent variable 
gen consent_yes = 1 if consent==1 
gen consent_no =  1 if consent==0  
 
*Households that consented to participate in the survey
graph bar (sum) consent_yes (sum) consent_no, bargap(67) blabel(total) ///
		ytitle(Number of HHs that Consent) title(Survey Consent)  ///
		ytitle(, size(medium) margin(small)) ///
	    legend(order(1 "HHs That Said Yes" 2 "HHs That Said No") size(small) region(lcolor(white))) ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		caption("`c(current_date)' `c(current_time)'") 		  
graph export "$graph/HH_consent.png", replace
graph export "$graph2/Graphs/HH_consent.png", replace

*Create a HH found variable 
gen HH_found_yes = 1 if resp_found==1 
gen HH_found_no =  1 if resp_found==0  

*Households that consented to participate in the survey
graph bar (sum) HH_found_yes (sum) HH_found_no, bargap(67) blabel(total) ///
		ytitle(Number of HHs That Were Found) title(Households Are Present at Time of Interview)  ///
		ytitle(, size(medium) margin(small)) ///
	    legend(order(1 "HHs Were Present" 2 "HHs Were Not Present") size(small) region(lcolor(white))) ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		caption("`c(current_date)' `c(current_time)'") 		  
graph export "$graph/HH_present.png", replace
graph export "$graph2/Graphs/HH_present.png", replace

*Export the target survey count and completed survey count for community 
*preserve
	recode	consent(.=0)
	label 	define consentlab 1 "Surveys Completed" 0 "Surverys Not Completed"
	label	values consent consentlab
	
	estpost tabulate area consent  
	esttab	using 	"$graph2/Tables/Target_survey_county.doc", replace 	///
			cell(b)  ///
            collabels(none) unstack noobs nonumber  modelwidth(23 18)        ///
            eqlabels(, lhs("Community"))                           ///
			title("Survey Count Tracking Table: Area/Community") ///
			varlabels(, blist(Survey Target Count)) compress

	estpost tabulate county consent  
	esttab	using 	"$graph2/Tables/Target_survey_county.doc", append 	///
			cell(b) ///
            collabels(none) unstack noobs nonumber nomtitle  modelwidth(23 18)        ///
            eqlabels(, lhs("County"))                           ///
			title("Survey Count Tracking Table: County")				///
			varlabels(, blist(Total)) compress
*restore

*Run time stamps do-file 
qui do "$do/Cleaning do-files/time_stamps"

//Tracking the number of surveys received each day & deciding which entries to run HFCs on today
count
local received_total = r(N)
di `received_total'
gen	  survey_total = r(N)
label var survey_total "Total Number of Surveys"

/*
Enter as comments the number of surveys you have downloaded each day:
June 15th  - 15
June 16th  - 0
June 17th  - 0
June 18th  - 17
June 19th  - 16
June 20th  - 12
June 21th  - 19
June 22th  - 30
June 23th  - 53
June 24th  - 38
June 25th  - 51
June 26th  - 16 
June 27th  - 48
June 28th  - 37
June 29th  - 39
June 30th  - 40
July 1st   - 67
July 2nd   - 19
July 3rd   - 19
July 4th   - 15
July 5th   - 13
July 6th   - 13
July 7th   - 14
July 8th   - 36
July 10th  - 40
July 11th  - 43
July 12th  - 42
July 13th  - 44
July 14th  - 31
July 15th  - 27
July 17th  - 14
July 18th  - 02
July 19th  - 14
July 20th  - 33
July 21st  - 59
July 22nd  - 05
July 23rd  - 10
July 24th  - 22
July 25th  - 05
July 26th  - 15
July 27th  - 09
July 28th  - 27
July 29th  - 18
July 31th  - 30
August 1st - 11
August 2nd - 16
Total So Far - 1084
*/

//Set this to whatever the count was from yesterday i.e. the Received_total minus Total-So-Far 
local received_yesterday = 1084

gen survey_yesteday = `received_yesterday'
label var survey_yesteday "Number of surveys yesterday"

//A counter for number of surveys received
gen survey_count = _n

//A counter for number of surveys received today 
gen survey_receieved = r(N) - `received_yesterday'
label var survey_receieved "Number of surveys received today"

//These are the households that we want to run HFCs on today
gen HFC_eligible = 1 if survey_count>`received_yesterday'

*Create a binary variable for yesterday/today 
gen 	day = 0 if survey_yesteday > 0 
replace day = 1 if HFC_eligible ==1
label define day_lab 0 "Yesterday" 1 "Today"
label values day day_lab

/**********************
Household Duplicates
**********************/

*
preserve 
	* Checks for duplicates in household ID 
	bysort respondent_id2: gen hh_id_dup 	= cond(_N==1,0,_n)	

	*Drop unwanted variables
	*drop survey_count
 
	*Checks if the paper to tablet survey entries are identical - Output for Aurelie 
	levelsof respondent_id2 if hh_id_dup>0
	 
	foreach ID in `r(levels)' {           
	iecompdup respondent_id2, id(`ID') didi keepdiff keepother(text_audit key)
	compress
cap	export excel using "$graph2/Tables/Discrepancy_hhid", sheet ("diff_`ID'")  first(varl) sheetreplace

	 }
restore 


/**********************
Survey Progress Tracker
**********************/

*total suvey collected
graph bar (max) survey_total, blabel(total) ///
		ytitle(Number of Surveys) title(Surveys Collected) ///
		ytitle(, size(medium) margin(small)) ///
		legend(order(1 "Total Number of Surveys Received") region(lcolor(white))) ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		caption("`c(current_date)' `c(current_time)'") 		  
graph export "$graph/Survey_total.png", replace
graph export "$graph2/Graphs/Survey_total.png", replace

*Surveys collected yesterday and today
graph bar (max) survey_yesteday (max) survey_receieved, bargap(67) blabel(total) ///
		ytitle(Number of Surveys) title(Surveys Collected)  ///
		ytitle(, size(medium) margin(small)) ///
	    legend(order(1 "Number of Surveys Received Yesterday" 2 "Number of Surveys Recieved Today") size(small) region(lcolor(white))) ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		caption("`c(current_date)' `c(current_time)'") 		  
graph export "$graph/Survey_count.png", replace
graph export "$graph2/Graphs/Survey_count.png", replace

/**************
Survey Time
****************/

gen totsectionsum_today = totsectionsum if HFC_eligible==1
gen totsectionsum_yeste = totsectionsum if survey_yesteday>0

*Average survey time (all surveys)
graph bar (mean) totsectionsum, blabel(total) ///
		ytitle(Duration of Survey (minutes)) ///
		ytitle(, margin(small)) title(Average Survey time) blabel(bar, format(%9.1f)) ///
	    legend(order(1 "Average Survey Time (All Surveys)") region(lcolor(white))) ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		caption("`c(current_date)' `c(current_time)'")	
graph export "$graph/survey_time_total.png", replace		   
graph export "$graph2/Graphs/survey_time_total.png", replace

*Average survey time : Yesterday and Today
graph bar (mean) totsectionsum_yeste (mean) totsectionsum_today, bargap(67) blabel(total) ///
		ytitle(Duration of Survey (minutes)) ///
		ytitle(, margin(small)) title(Average Survey time) blabel(bar, format(%9.1f)) ///
	    legend(order(1 "Average Survey Time (Yesterday)" 2 "Average Survey Time (Today)") size(small) region(lcolor(white))) ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		caption("`c(current_date)' `c(current_time)'")	
graph export "$graph/survey_time.png", replace	
graph export "$graph2/Graphs/survey_time.png", replace

/******************
Survey Time - Modules
*******************/	
	
graph bar (mean) section1 (mean) section2 (mean) section3 (mean) section4 (mean) section5 ///
		  (mean) section6 (mean) section7 (mean) section8 (mean) section9 (mean) section10 ///
		  (mean) section11 (mean) section12 (mean) section13 (mean) section14 (mean) section15 ///
		  (mean) section16 (mean) section17 (mean) section18 (mean) section19 (mean) section20 ///
		  (mean) section21, bargap(67) blabel(total) blabel(bar, format(%9.1f)) ///
	      ytitle(Duration of Survey (minutes)) title(Average Survey Time of Modules) ///
	      legend(order(1 "Household roster" 2 "Personality traits" 3 "extension" 4 "farm roster" 5 "crop production" 6 "Input use" ///
		  7 "technology use" 8 "labor on basic agricultural" 9 "storage and marketing" 10 "crop prod cycle" 11 "Farmer Org" ///
		  12 "livestock" 13 "housing" 14 "kitchen" 15 "income & expenditure" 16 "assets" 17 "informal savings" 18 "bank account" ///
		  19 "credit" 20 "dietary diversity" 21 "food insecurity") region(lcolor(white))) ///
		  graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		  caption("`c(current_date)' `c(current_time)'")	
graph export "$graph/survey_time_modules.png", replace
graph export "$graph2/Graphs/survey_time_modules.png", replace	

/*****************************************
Crop frequncy of main crops - Total Survey
*****************************************/

recode e_upland e_lowland e_cassava (-66 -99=.)

graph hbar (mean) e_upland (mean) e_lowland (mean) e_cassava, showyvars ///
			yvaroptions(relabel(1 "Upland Rice" 2 "Lowland Rice" 3 "Cassava") descending) ///
			bargap(67) blabel(total) ytitle(Crop Grown Percentage) legend(off) ///
			graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
			caption("`c(current_date)' `c(current_time)'") blabel(bar, format(%9.2f)) ///
			title(Percentage of Households That Grew Main Crops)
graph export "$graph/main_crops_freq.png", replace	
graph export "$graph2/Graphs/main_crops_freq.png", replace	

/*****************************************
Crop frequncy of main crops - Yesterday/Today
*****************************************/

graph hbar	(mean) e_upland e_lowland e_cassava, showyvars ///
			yvaroptions(relabel(1 "Upland Rice"2 " Lowland Rice" 3 "Cassava") descending) ///
			bargap(67) blabel(bar, format(%9.2f)) ytitle(Crop Grown Percentage) ///
			by(, legend(off)) by(, graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))) ///
			by(day, note("")) subtitle(, fcolor(white) lcolor(white)) ///
		    by(, title("Percentage of Households That Grew Main Crops"))
graph export "$graph/main_crops_freq_day.png", replace	
graph export "$graph2/Graphs/main_crops_freq_day.png", replace	

/*****************************************
Grew one of main crops - Yesterday/Today
*****************************************/

gen 	grew_crop = 0
replace grew_crop = 1 if e_upland==1 | e_lowland==1 | e_cassava==1 

gen		grew_crop_no = 0
replace	grew_crop_no = 1 if grew_crop==0
 
graph bar	(sum) grew_crop grew_crop_no, showyvars ///
			yvaroptions(relabel(1 "HHs Grew Crop" 2 "HHs Did not Grow Crop")) ///
			bargap(67) blabel(bar) ytitle(Number of HHs) by(, legend(off)) ///
			by(, graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))) ///
			by(day, note("")) subtitle(, fcolor(white) lcolor(white))  subtitle(, margin(zero) nobox)
graph export "$graph/main_crops_grew_day.png", replace	
graph export "$graph2/Graphs/main_crops_grew_day.png", replace	
					
/**************
Farmer group 
***************/
gen		farmer_group = 0
replace farmer_group = 1 if g1_1==1 | g1_1==2

gen		farmer_group_not = 0
replace farmer_group_not = 1 if farmer_group==0

graph bar (sum) farmer_group (sum) farmer_group_not if HFC_eligible==1, bargap(67) blabel(total) ///
		ytitle(Joined Farmer Group) title(Households in Farmer Groups) ///
	    legend(order(1 "In a Farmer Group" 2 "Not in a Farmer Group") region(lcolor(white))) ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		caption("`c(current_date)' `c(current_time)'")		  
graph export "$graph/farmer_group.png", replace
graph export "$graph2/Graphs/farmer_group.png", replace

/*******************
Access to Extension
**********************/
gen		extension_access = 0 
replace extension_access = 1 if module_d1==1

gen		extension_access_no = 0 
replace extension_access_no = 1 if extension_access==0

graph bar (sum) extension_access (sum) extension_access_no if HFC_eligible==1, bargap(67) blabel(total) ///
		ytitle(Extension Access) title(Households With Access to Extension Services) ///
	    legend(order(1 "Households Have Access" 2 "Households Do Not Have Access") region(lcolor(white))) ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		caption("`c(current_date)' `c(current_time)'")		  
graph export "$graph/extension_access.png", replace
graph export "$graph2/Graphs/extension_access.png", replace

/******************
Number of plots
*******************/

egen number_plots = rownonmiss(farm1 farm2 farm3 farm4 farm5 farm6), strok
gen number_plots_today = number_plots if HFC_eligible==1

graph bar (mean) number_plots (mean) number_plots_today, bargap(67) blabel(total) ///
	    ytitle(Number of Plots) ytitle(, margin(small)) ///
		title(Average Number of Plots) blabel(bar, format(%9.1f)) ///
	    legend(order(1 "Average Number of Plots (All HHs)" 2 "Average Number of Plots (Today)") size(small) region(lcolor(white))) ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		caption("`c(current_date)' `c(current_time)'")
graph export "$graph/number_plots.png", replace	
graph export "$graph2/Graphs/number_plots.png", replace
		  
/******************
Number of crops
*******************/

egen number_crops_main = rowtotal(e_upland e_lowland e_cassava), m

split e_crop, gen(e_crop_other) destring 
egen number_crops_main_other = rownonmiss(e_crop_other*)

egen number_crops_total = rowtotal(number_crops_main number_crops_main_other), m
egen number_crops_total_today = rowtotal(number_crops_main number_crops_main_other) if HFC_eligible==1, m

graph bar (mean) number_crops_total (mean) number_crops_total_today, bargap(67) blabel(total) ///
	    ytitle(Number of Crops) ytitle(, margin(small)) ///
		title(Average Number of Crops) blabel(bar, format(%9.1f)) ///
	    legend(order(1 "Average Number of Crops (All HHs)" 2 "Average Number of Crops (Today)") size(small) region(lcolor(white))) ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		caption("`c(current_date)' `c(current_time)'")
graph export "$graph/number_crops.png", replace	
graph export "$graph2/Graphs/number_crops.png", replace

/*****************************
Input Use - tracking enumerators
*****************************/
recode 	e4_1__1 e4_1__2 e4_1__3 e4_1__4 (-99 =0)

gen		e4_1__1_no = 0 
replace	e4_1__1_no = 1 if e4_1__1==0

gen		e4_1__2_no = 0 
replace	e4_1__2_no = 1 if e4_1__2==0

gen		e4_1__3_no = 0 
replace	e4_1__3_no = 1 if e4_1__3==0

gen		e4_1__4_no = 0 
replace	e4_1__4_no = 1 if e4_1__4==0

graph bar	(sum) e4_1__1_no (sum) e4_1__2_no (sum) e4_1__3_no (sum) e4_1__4_no, ///
			bargap(67) blabel(total) blabel(bar, format(%9.0f)) ///
			ytitle(Number of HHs That Did not Know Input) title(Household Input Use) ///
			legend(order(1 "Improved Seeds" 2 "Organic/Nat. Fertilizer" 3 "Chemical/Inor. Fertilizer" ///
			4 "Pesticide/Herbicide") region(lcolor(white))) ///
			graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
			caption("`c(current_date)' `c(current_time)'")
graph export "$graph/input_use_each.png", replace	
graph export "$graph2/Graphs/input_use_each.png", replace

/**********************************
Input Use - No input was heard off
***********************************/	
gen 	input_use_no = 0 
replace	input_use_no = 1 if e4_1__1==0 & e4_1__2==0 & e4_1__3==0 & e4_1__4==0

graph bar	(sum) input_use_no, ///
			bargap(67) blabel(total) blabel(bar, format(%9.0f)) ///
			ytitle(Number of HHs That Did not Know Input) title(Household Input Use) ///
			legend(order(1 "HHs Did Not Know All 4 Inputs") region(lcolor(white))) ///
			graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
			caption("`c(current_date)' `c(current_time)'") by(day, note(""))
graph export "$graph/input_use_all.png", replace
graph export "$graph2/Graphs/input_use_all.png", replace	

/*****************************
Technology Use - tracking enumerators
*****************************/

recode 	e5_1__1 e5_1__2 e5_1__3 e5_1__4 e5_1__5 e5_1__6 e5_1__7 (-99 =0)

gen		e5_1__1_no = 0 
replace	e5_1__1_no = 1 if e5_1__1==0

gen		e5_1__2_no = 0 
replace	e5_1__2_no = 1 if e5_1__2==0

gen		e5_1__3_no = 0 
replace	e5_1__3_no = 1 if e5_1__3==0

gen		e5_1__4_no = 0 
replace	e5_1__4_no = 1 if e5_1__4==0

gen		e5_1__5_no = 0 
replace	e5_1__5_no = 1 if e5_1__5==0

gen		e5_1__6_no = 0 
replace	e5_1__6_no = 1 if e5_1__6==0

gen		e5_1__7_no = 0 
replace	e5_1__7_no = 1 if e5_1__7==0

graph bar	(sum) e5_1__1_no (sum) e5_1__2_no (sum) e5_1__3_no (sum) e5_1__4_no ///
			(sum) e5_1__5_no (sum) e5_1__6_no (sum) e5_1__7_no, ///
			bargap(67) blabel(total) blabel(bar, format(%9.0f)) ///
			ytitle(Number of HHs That Did not Know Tech) title(Household Technology Use) ///
			legend(order(1 "Plant Cover" 2 "IPM" 3 "Plant Nursery" 4 "Soil Mounds/Ridges" ///
			5 "Compost Making" 6 "Mulching" 7 "Green Manure") region(lcolor(white))) ///
			graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
			caption("`c(current_date)' `c(current_time)'")
graph export "$graph/tech_use_each.png", replace
graph export "$graph2/Graphs/tech_use_each.png", replace	

/*****************************
Tech Use - No tecnology was heard of
*****************************/	
gen 	tech_use_no = 0 
replace	tech_use_no = 1 if e5_1__1==0 & e5_1__2==0 & e5_1__3==0 & e5_1__4==0 & e5_1__5==0 & e5_1__6==0 & e5_1__7==0

graph bar	(sum) tech_use_no, ///
			bargap(67) blabel(total) blabel(bar, format(%9.0f)) ///
			ytitle(Number of HHs That Did not Know Tech) title(Household Technology Use) ///
			legend(order(1 "HHs Did Not Know All 7 Techs") region(lcolor(white))) ///
			graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
			caption("`c(current_date)' `c(current_time)'")
graph export "$graph/tech_use_all.png", replace	
graph export "$graph2/Graphs/tech_use_all.png", replace	

/*****************
Frequency of "dont knows" * run this on final merged data
****************/	
	
 * Flag "dont knows" score -- Checks for frequency of "dont knows" per enumerator 

 ds, has(type numeric)

gen score_dontknow = 0
	foreach var of varlist `r(varlist)' {
		gen x = (`var' == -99 & `var'!=.) 
			replace score_dontknow = score_dontknow + x if (`var' == -99) //& (HFC_eligible == 1)
drop x
}	

 ds, has(type numeric)

gen not_applicable = 0
	foreach var of varlist `r(varlist)' {
		gen x = (`var' == -66 & `var'!=.) 
			replace not_applicable = not_applicable + x if (`var' == -66) //& (HFC_eligible == 1)
drop x
}


/******************************
Outsheet tracking errors by enumerator 
****************************/

bysort  enum_id: egen dont_know_total = sum(score_dontknow)
bysort  enum_id: egen not_applicable_total = sum(not_applicable)
bysort  enum_id: gen survey_count_enum = _N
bysort  enum_id: gen enum_dup 	= cond(_N==1,0,_n)
gen 	avg_dontknow = (dont_know_total/survey_count_enum)
gen 	avg_notappli = (not_applicable_total/survey_count_enum)


preserve
	keep `identifier'  dont_know_total not_applicable_total survey_count_enum enum_dup avg_dontknow avg_notappli
	drop if enum_dup>1
	drop HFC_eligible enum_dup
	gsort enum_id enum_name
	count
	if r(N) > 0 {
	export excel using "$graph2/Tables/HFCs_outputs_summary_`date'", sheet ("dontknows_summary") first(varl) sheetreplace
	}
restore 

exit
/********************
Hunger scale measures 
***********************/	
*** HFIAS scale score

fs2_1 fs2_2 fs2_3 fs2_4 fs2_5 fs2_6 fs2_7 fs2_8 

 
gen		hfias_category = 1 if fs2_1==0 & fs2_2==0 & fs2_3==0 & fs2_4==0 & fs2_5==0 & fs2_6==0 & fs2_7==0 & fs2_8==0 
replace hfias_category = 2 if fs2_1==2 | fs2_2==3 | fs2_3==1 | fs2_4==2 | fs2_5==3 | fs2_6==1 | fs2_7==1) & fs2_8==0 & l18a==0 & l19a==0
replace hfias_category = 3 if fs2_1==2 | fs2_2==3 | fs2_3==2 | fs2_4==3 | fs2_5==1 | fs2_6==2 | fs2_7==1 | fs2_8==2) 
replace hfias_category = 4 if fs2_1==1 & fs2_2==1 & fs2_3==1 & fs2_4==1 & fs2_5==1 & fs2_6==1 & fs2_7==1 & fs2_8==1 

lab var hfias_category "HH HFIAS category indicator" 
lab def hfias_category_l 1 "Food secure" 2 "Middly food insecure access" 3 "Moderately food insecure access" 4 "Severely food insecure access", modify 
lab val hfias_category hfias_category_l  
 

***********End of do-file**********
