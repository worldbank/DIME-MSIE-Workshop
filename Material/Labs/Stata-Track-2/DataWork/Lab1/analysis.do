// Analysis dofile for Lab 1

  // Load the dataset
  use "${Lab1}/endline_data_final.dta", clear

  // Create some simple graphs
  graph bar numplots  ///
  , over(pl_id_09)    ///
    title(, justification(left) color(black) span pos(11)) /// la() may not work
    graphregion(color(white) lc(white) lw(med) la(center)) /// on older versions
    ylab(,angle(0) nogrid)                                 /// remove if so
    yscale(noline) legend(region(lc(none) fc(none)))

  graph bar inc_t ///
  , over(pl_id_09) ///
    graphregion(color(white) lc(white) lw(med) la(center))

  // Run some regressions

    reg inc_01 numplots pl_hhsize ///
    , cl(pl_id_09)

    xi: reg inc_01 numplots pl_hhsize ///
      i.pl_id_10                      ///
    if oi_assign == "Treatment"       ///
    , cl(pl_id_09)

    xi: reg inc_02 numplots pl_hhsize ///
      i.pl_id_10                      ///
    if treatment == 1                 ///
    , cl(pl_id_09)

// End of dofile
