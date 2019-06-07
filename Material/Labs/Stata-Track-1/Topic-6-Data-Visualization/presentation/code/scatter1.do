tw (scatter ag_18_x_16_1 ag_16_x_16_1 if (hh_treatment == 0), mc(navy) ms(Oh)) ///
    if (ag_16_x_16_1 < 200) & (ag_16_x_16_1 > 0) & (ag_18_x_16_1 < 20000 )     ///
  , xtitle("Days spent on land preparation {&rarr}")                           ///
    ytitle("Amount spent on hired labor")                                      ///
    legend(order(1 "Control" 2 "Treatment") c(1) ring(0) pos(1))
