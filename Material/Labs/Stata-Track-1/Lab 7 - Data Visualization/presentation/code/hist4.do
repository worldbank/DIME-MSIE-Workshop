histogram ag_16_x_16_1 ///
	if ag_16_x_16_1 < 200 & ag_16_x_16_1 > 0, ///
	$graph_opts freq w(5) ytit("Number of households") ///
	lc(black) lw(thin) fc(maroon) ///
	xtitle("Days spent on land preparation")

graph save "${output}/task1.gph" , replace
