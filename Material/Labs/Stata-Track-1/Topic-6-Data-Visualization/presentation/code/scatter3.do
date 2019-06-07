tw  (scatter ag_18_x_16_1 ag_16_x_16_1 if (treatment == 0), mc(navy) ms(Oh))       ///
    (scatter ag_18_x_16_1 ag_16_x_16_1 if (treatment == 1), mc(maroon) ms(T))      ///
    (lowess  ag_18_x_16_1 ag_16_x_16_1 if (treatment == 0), lc(navy) lw(medium))   ///
    (lowess  ag_18_x_16_1 ag_16_x_16_1 if (treatment == 1), lc(maroon) lw(medium)) ///
    if (ag_16_x_16_1 < 200) & (ag_16_x_16_1 > 0) & (ag_18_x_16_1 < 20000)          ///
  , ${graph_opts} xtitle("Days spent on land preparation {&rarr}")                 ///
    ytitle("Amount spent on hired labor")                                          ///
    legend(order(1 "Control" 2 "Treatment") c(1) ring(0) pos(1))

graph save "${ST1_outRaw}/task3.gph" , replace
