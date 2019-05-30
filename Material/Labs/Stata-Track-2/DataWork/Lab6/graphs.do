// Suggested solution for Lab 7

// Histogram
use "${Lab6}/hh_roster.dta" if tag_hh == 1 , clear

  // Find a reasonable viewing range.

    histogram hh_ag_16_x_16_1
    histogram hh_ag_16_x_16_1 if hh_ag_16_x_16_1 < 10000
    histogram hh_ag_16_x_16_1 if hh_ag_16_x_16_1 < 200

  // Make a final histogram and save it
  histogram ///
    hh_ag_16_x_16_1 ///
      if hh_ag_16_x_16_1 < 200 ///
    , freq start(0) w(5) ///
      ytit("Number of households") yscale(noline) ///
      lc(white) lw(thin) fc(maroon) la(center) /// Omit la(center) for V < 15.1
      xtitle("Days spent on land preparation {&rarr}")

    graph save "${Lab6}/histogram.gph" , replace

// Bar chart
use "${Lab6}/hh_roster.dta" if tag_hh == 1 , clear

  // Investigate outcome
  ta hh_gr_16 hh_ag_17_x_16_1 , row m
  decode hh_gr_16 , gen(cooperative)
  replace cooperative = proper(cooperative)

  // Make and save graph
  graph bar hh_ag_17_x_16_1 ///
    , over(cooperative) horizontal ///
      ylabel(0 "0%" .25 "25%" .5 "50%" .75 "75%" 1 "100%") ///
      ytitle("Households that hired labor {&rarr}") ///
      bar(1 ,  lw(thin) lc(white) fc(navy) fi(50) la(center))

    graph save  "${Lab6}/bar.gph" , replace

// Scatter plot
use "${Lab6}/hh_roster.dta" , clear

  tw ///
    (scatter hh_ag_18_x_16_1 hh_ag_16_x_16_1 ///
      if hh_treatment == 0 ///
      , mc(maroon) ms(Oh) msize(med) lw(thin)) ///
    (scatter hh_ag_18_x_16_1 hh_ag_16_x_16_1 ///
      if hh_treatment == 1 ///
      , mc(black) ms(O) ) ///
    (lfit hh_ag_18_x_16_1 hh_ag_16_x_16_1 ///
      if hh_treatment == 0 ///
      , lc(black) lw(thick)) ///
    (lfit hh_ag_18_x_16_1 hh_ag_16_x_16_1 ///
      if hh_treatment == 1 ///
      , lc(maroon) lw(thick)) ///
  if hh_ag_16_x_16_1 < 70 & hh_ag_16_x_16_1 > 0 & hh_ag_18_x_16_1 < 20000 ///
  , xtitle("Days spent on land preparation {&rarr}") ///
    ytitle("Amount spent on hired labor") ///
    legend(on order(1 "Control" 2 "Treatment") c(1) ring(0) pos(1))

    graph save "${Lab6}/scatter.gph" , replace

// Combine
  graph combine ///
    "${Lab6}/histogram.gph" ///
    "${Lab6}/bar.gph" ///
    "${Lab6}/scatter.gph" ///
  , graphregion(color(white))

    graph export "${Lab6}/lab6.png" , replace width(1000)

// End of dofile
