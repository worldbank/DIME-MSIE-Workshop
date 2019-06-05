graph bar ag_17_x_16_1, ///
	over(gr_16) ///
	horizontal ///
	${graph_opts1} ///
	ylabel(0 "0%" .25 "25%" .5 "50%" .75 "75%" 1 "100%") ///
	ytitle("Proportion of households that hired labor to assist") ///
	title("Use of hired labor by LWH cooperative") ///
	bar(1 ,	lw(thin) lc(black) fc(navy) fi(50))

graph save  "${output}/task2.gph" , replace
