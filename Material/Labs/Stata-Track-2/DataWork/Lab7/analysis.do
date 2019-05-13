* Lab 7: Visualization

* Easy graph defaults (milage varies by version)

	global graph_opts ///
		title(, justification(left) color(black) span pos(11)) ///
		graphregion(color(white) lc(white) lw(med) la(center)) /// <- Delete la(center) for version < 15
		ylab(,angle(0) nogrid) xtit(,placement(left) justification(left)) ///
		yscale(noline) xscale(noline) legend(region(lc(none) fc(none)))

	global graph_opts1 ///
		title(, justification(left) color(black) span pos(11)) ///
		graphregion(color(white) lc(white) lw(med) la(center)) /// <- Delete la(center) for version < 15
		ylab(,angle(0) nogrid)  ///
		yscale(noline) legend(region(lc(none) fc(none)))

* Task 1: Histogram

	* Load data

		use "${Lab7_dtFin}/hh_roster.dta" ///
			if tag_hh == 1 , clear

	* Find a reasonable viewing range.

		histogram hh_ag_16_x_16_1
		histogram hh_ag_16_x_16_1 if hh_ag_16_x_16_1 < 10000
		histogram hh_ag_16_x_16_1 if hh_ag_16_x_16_1 < 200

		histogram hh_ag_16_x_16_1 ///
				if hh_ag_16_x_16_1 < 200 & hh_ag_16_x_16_1 > 0 ///
			, freq w(5)

	* Make a final histogram and save it

		histogram ///
			hh_ag_16_x_16_1 ///
				if hh_ag_16_x_16_1 < 200 & hh_ag_16_x_16_1 > 0 ///
			, $graph_opts freq w(5) ytit("Number of households") ///
				lc(black) lw(thin) fc(maroon) ///
				xtitle("Days spent on land preparation {&rarr}")

			graph save "${Lab7_outRaw}/task1.gph" , replace

* Task 2: Bar chart

	* Load data

		use "${Lab7_dtFin}/hh_roster.dta" ///
			if tag_hh == 1 , clear

	* Investigate outcome

		ta hh_gr_16 hh_ag_17_x_16_1 , row m

	* Bar graph

		graph bar hh_ag_17_x_16_1 ///
			, over(hh_gr_16) horizontal ///
				${graph_opts1} ylabel(0 "0%" .25 "25%" .5 "50%" .75 "75%" 1 "100%") ///
				ytitle("Proportion of households that hired labor to assist {&rarr}") ///
				title("Use of hired labor by LWH cooperative") ///
				bar(1 ,	lw(thin) lc(black) fc(navy) fi(50))

			graph save  "${Lab7_outRaw}/task2.gph" , replace

* Task 3: Scatter plot

	* Load data

		use "${Lab7_dtFin}/hh_roster.dta" , clear

	* Scatter plot

		tw ///
			(scatter hh_ag_18_x_16_1 hh_ag_16_x_16_1 ///
				if hh_treatment == 0 ///
				, mc(navy) ms(Oh)) ///
			(scatter hh_ag_18_x_16_1 hh_ag_16_x_16_1 ///
				if hh_treatment == 1 ///
				, mc(maroon) ms(T)) ///
			(lowess hh_ag_18_x_16_1 hh_ag_16_x_16_1 ///
				if hh_treatment == 0 ///
				, lc(navy) lw(thick)) ///
			(lowess hh_ag_18_x_16_1 hh_ag_16_x_16_1 ///
				if hh_treatment == 1 ///
				, lc(maroon) lw(thick)) ///
		if hh_ag_16_x_16_1 < 200 & hh_ag_16_x_16_1 > 0 & hh_ag_18_x_16_1 < 20000 ///
		, ${graph_opts} ///
			xtitle("Days spent on land preparation {&rarr}") ///
			ytitle("Amount spent on hired labor") ///
			legend(order(1 "Control" 2 "Treatment") c(1) ring(0) pos(1))

			graph save "${Lab7_outRaw}/task3.gph" , replace

* Combine

	graph combine ///
		"${Lab7_outRaw}/task1.gph" ///
		"${Lab7_outRaw}/task2.gph" ///
		"${Lab7_outRaw}/task3.gph" ///
	, graphregion(color(white))

		graph export "${Lab7_outRaw}/lab7.png" , replace width(1000)

* Have a lovely day!
