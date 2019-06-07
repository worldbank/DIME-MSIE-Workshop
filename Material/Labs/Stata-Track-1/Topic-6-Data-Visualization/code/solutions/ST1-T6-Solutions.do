
    * Load data after topic 4
    use "${ST1_dtInt}/endline_data_post_topic4.dta",  clear


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

    ********************************************************************************
    * 							Task 1: Histograms
    ********************************************************************************

	* Create a simple histogram
		histogram ag_16_x_16_1

    * Remove outliers from the histogram
        histogram ag_16_x_16_1 if (ag_16_x_16_1 < 10000)
        histogram ag_16_x_16_1 if (ag_16_x_16_1 < 200)

	* Let y axis depict frequency instead of density and set the width of bins to 5
		histogram ag_16_x_16_1 if (ag_16_x_16_1 < 200) & (ag_16_x_16_1 > 0), freq w(5)

	* Make a final histogram and save it
        histogram ag_16_x_16_1 if (ag_16_x_16_1 < 200) & (ag_16_x_16_1 > 0) ///
          , ${graph_opts} freq w(5) ytit("Number of households")            ///
            lc(black) lw(thin) fc(maroon) xtitle("Days spent on land preparation")

        graph save "${ST1_outRaw}/task1.gph" , replace


    ********************************************************************************
    * 							Task 2: Bar graphs
    ********************************************************************************

	* Investigate outcome

		tab gr_16 ag_17_x_16_1 , row m

	* Bar graph

        graph bar ag_17_x_16_1, title("Use of hired labor")               ///
            ytitle("Proportion of households that hired labor to assist")

        graph bar ag_17_x_16_1, over(gr_16)                               ///
            title("Use of hired labor by LWH cooperative")                ///
            ytitle("Proportion of households that hired labor to assist")

	* Make a final bar graph and save it

        graph bar ag_17_x_16_1, ${graph_opts1} over(gr_16) horizontal     ///
            ylabel(0 "0%" .25 "25%" .5 "50%" .75 "75%" 1 "100%")          ///
            ytitle("Proportion of households that hired labor to assist") ///
            title("Use of hired labor by LWH cooperative")                ///
            bar(1 , lw(thin) lc(black) fc(navy) fi(50))

        graph save  "${ST1_outRaw}/task2.gph" , replace

    ********************************************************************************
    * 							Task 3: Scatter Plots
    ********************************************************************************

	* Only control, only scatter
        tw (scatter ag_18_x_16_1 ag_16_x_16_1 if (treatment == 0), mc(navy) ms(Oh)) ///
            if (ag_16_x_16_1 < 200) & (ag_16_x_16_1 > 0) & (ag_18_x_16_1 < 20000 )  ///
          , xtitle("Days spent on land preparation {&rarr}")                        ///
            ytitle("Amount spent on hired labor")                                   ///
            legend(order(1 "Control" 2 "Treatment") c(1) ring(0) pos(1))

	* Only control, also lowess
        tw  (scatter ag_18_x_16_1 ag_16_x_16_1 if (treatment == 0), mc(navy) ms(Oh))     ///
            (lowess  ag_18_x_16_1 ag_16_x_16_1 if (treatment == 0), lc(navy) lw(medium)) ///
            if (ag_16_x_16_1 < 200) & (ag_16_x_16_1 > 0) & (ag_18_x_16_1 < 20000)        ///
          , xtitle("Days spent on land preparation {&rarr}")                             ///
            ytitle("Amount spent on hired labor")                                        ///
            legend(order(1 "Control" 2 "Treatment") c(1) ring(0) pos(1))


	* Make a final scatter and lowess plot with both treatment and control and save it
        tw  (scatter ag_18_x_16_1 ag_16_x_16_1 if (treatment == 0), mc(navy) ms(Oh))       ///
            (scatter ag_18_x_16_1 ag_16_x_16_1 if (treatment == 1), mc(maroon) ms(T))      ///
            (lowess  ag_18_x_16_1 ag_16_x_16_1 if (treatment == 0), lc(navy) lw(medium))   ///
            (lowess  ag_18_x_16_1 ag_16_x_16_1 if (treatment == 1), lc(maroon) lw(medium)) ///
            if (ag_16_x_16_1 < 200) & (ag_16_x_16_1 > 0) & (ag_18_x_16_1 < 20000)          ///
          , ${graph_opts} xtitle("Days spent on land preparation {&rarr}")                 ///
            ytitle("Amount spent on hired labor")                                          ///
            legend(order(1 "Control" 2 "Treatment") c(1) ring(0) pos(1))

        graph save "${ST1_outRaw}/task3.gph" , replace

    ********************************************************************************
    * 							Task 2: Combine Graphs
    ********************************************************************************

    * Combine the final graph in each section ot a single graph
        graph combine                 ///
            "${ST1_outRaw}/task1.gph" ///
            "${ST1_outRaw}/task2.gph" ///
            "${ST1_outRaw}/task3.gph" ///
          , graphregion(color(white))

        graph export "${ST1_outRaw}/combine_graphs_topic6.png" , replace width(1000)
