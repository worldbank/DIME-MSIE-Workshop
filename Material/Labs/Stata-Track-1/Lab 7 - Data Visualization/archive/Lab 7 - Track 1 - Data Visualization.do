********************************************************************************
* 							PART 1: SETTINGS
*******************************************************************************/

*-------------------------------------------------------------------------------
* 						1.1 Initial settings
*-------------------------------------------------------------------------------

	* Install required packages
   local user_commands ietoolkit       //Fill this list will all commands this project requires
   foreach command of local user_commands {
       cap which `command'
       if _rc == 111 {
           cap ssc install `command'
       }
   }

	*Standardize settings accross users
    ieboilstart, version(12.0)      											
    `r(version)'   

*-------------------------------------------------------------------------------
* 						1.2 Create file path globals
*-------------------------------------------------------------------------------

   * Users																		
   * -----
    if c(username) == "kbrkb" {
       global projectfolder "C:\Users\kbrkb\Dropbox\FC Training\June 2018"
	}

   if c(username) == "wb506743" {
		global projectfolder "C:\Users\wb506743\Dropbox\FC Training\June 2018"
   }
   *
   
   * Project folder globals
   * ---------------------
	global folder	"$projectfolder/Session Materials/Stata Track 1/Lab 6 - Descriptive Analysis"
	global output	"$folder/Output"

	* Use data

		use "${projectfolder}/data/endline_data_raw.dta" , clear

		gen hh_treatment = ( uniform() < .5)
		label define tmt_status 0 "Control" 1 "Treatment"
		label val hh_treatment tmt_status	
		
* Lab 7: Visualization

* Easy graph defaults (milage varies by version)

	global graph_opts ///
		title(, justification(left) color(black) span pos(11)) ///
		graphregion(color(white) lc(white) lw(med) ) /// la(center)
		ylab(,angle(0) nogrid) xtit(,placement(left) justification(left)) ///
		yscale(noline) xscale(noline) legend(region(lc(none) fc(none)))

	global graph_opts1 ///
		title(, justification(left) color(black) span pos(11)) ///
		graphregion(color(white) lc(white) lw(med) ) /// la(center)
		ylab(,angle(0) nogrid)  ///
		yscale(noline) legend(region(lc(none) fc(none)))

* Task 1: Histogram

	* Find a reasonable viewing range.

		histogram ag_16_x_16_1
		histogram ag_16_x_16_1 if ag_16_x_16_1 < 10000
		histogram ag_16_x_16_1 if ag_16_x_16_1 < 200

		histogram ag_16_x_16_1 							///
			if ag_16_x_16_1 < 200 & ag_16_x_16_1 > 0 	///
			, freq w(5)

	* Make a final histogram and save it

		histogram ///
			ag_16_x_16_1 ///
				if ag_16_x_16_1 < 200 & ag_16_x_16_1 > 0 ///
			, $graph_opts freq w(5) ytit("Number of households") ///
				lc(black) lw(thin) fc(maroon) ///
				xtitle("Days spent on land preparation")

			graph save "${output}/task1.gph" , replace

* Task 2: Bar chart

	* Investigate outcome

		ta gr_16 ag_17_x_16_1 , row m

	* Bar graph
	
		graph bar ag_17_x_16_1 , title("Use of hired labor") ytitle("Proportion of households that hired labor to assist")
		graph bar ag_17_x_16_1 , over(gr_16) title("Use of hired labor by LWH cooperative") ///
			ytitle("Proportion of households that hired labor to assist")

		graph bar ag_17_x_16_1 ///
			, over(gr_16) horizontal ///
				${graph_opts1} ylabel(0 "0%" .25 "25%" .5 "50%" .75 "75%" 1 "100%") ///
				ytitle("Proportion of households that hired labor to assist") ///
				title("Use of hired labor by LWH cooperative") ///
				bar(1 ,	lw(thin) lc(black) fc(navy) fi(50))

			graph save  "${output}/task2.gph" , replace

* Task 3: Scatter plot


	* Scatter plot

		//Only control, only values
		tw ///
			(scatter ag_18_x_16_1 ag_16_x_16_1 if hh_treatment == 0, mc(navy) ms(Oh)) ///
			if ag_16_x_16_1 < 200 & ag_16_x_16_1 > 0 & ag_18_x_16_1 < 20000 ///
		, ///
			xtitle("Days spent on land preparation {&rarr}") ///
			ytitle("Amount spent on hired labor") ///
			legend(order(1 "Control" 2 "Treatment") c(1) ring(0) pos(1))

		//Only control, also lowess
		tw ///
			(scatter ag_18_x_16_1 ag_16_x_16_1 if hh_treatment == 0, mc(navy) ms(Oh)) ///
			(lowess  ag_18_x_16_1 ag_16_x_16_1 if hh_treatment == 0, lc(navy) lw(medium)) ///
			if ag_16_x_16_1 < 200 & ag_16_x_16_1 > 0 & ag_18_x_16_1 < 20000 ///
		, ///
			xtitle("Days spent on land preparation {&rarr}") ///
			ytitle("Amount spent on hired labor") ///
			legend(order(1 "Control" 2 "Treatment") c(1) ring(0) pos(1))
	
		//Only control, also lowess
		tw ///
			(scatter ag_18_x_16_1 ag_16_x_16_1 if hh_treatment == 1, mc(maroon) ms(T)) ///
			(lowess  ag_18_x_16_1 ag_16_x_16_1 if hh_treatment == 1, lc(maroon) lw(medium)) ///
			if ag_16_x_16_1 < 200 & ag_16_x_16_1 > 0 & ag_18_x_16_1 < 20000 ///
		, ///
			xtitle("Days spent on land preparation {&rarr}") ///
			ytitle("Amount spent on hired labor") ///
			legend(order(1 "Control" 2 "Treatment") c(1) ring(0) pos(1))
	
			
	
		tw ///
			(scatter ag_18_x_16_1 ag_16_x_16_1 if hh_treatment == 0, mc(navy) ms(Oh)) ///
			(scatter ag_18_x_16_1 ag_16_x_16_1 if hh_treatment == 1, mc(maroon) ms(T)) ///
			(lowess  ag_18_x_16_1 ag_16_x_16_1 if hh_treatment == 0, lc(navy) lw(medium)) ///
			(lowess  ag_18_x_16_1 ag_16_x_16_1 if hh_treatment == 1, lc(maroon) lw(medium)) ///
			if ag_16_x_16_1 < 200 & ag_16_x_16_1 > 0 & ag_18_x_16_1 < 20000 ///
		, ${graph_opts} ///
			xtitle("Days spent on land preparation {&rarr}") ///
			ytitle("Amount spent on hired labor") ///
			legend(order(1 "Control" 2 "Treatment") c(1) ring(0) pos(1))

			graph save "${output}/task3.gph" , replace

* Combine

	graph combine ///
		"${output}/task1.gph" ///
		"${output}/task2.gph" ///
		"${output}/task3.gph" ///
	, graphregion(color(white))

		graph export "${output}/lab7.png" , replace width(1000)

* Have a lovely day!
