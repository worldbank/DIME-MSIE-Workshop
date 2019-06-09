* Analysis dofile for Lab 2

graph bar numplots , over(pl_id_09) title(, justification(left) color(black) span pos(11)) graphregion(color(white) lc(white) lw(med) la(center)) /// <- la() may not work on older versions
	ylab(,angle(0) nogrid)  yscale(noline) legend(region(lc(none) fc(none)))
graph bar inc_t , over(pl_id_09) graphregion(color(white) lc(white) lw(med) la(center))
reg inc_01 numplots pl_hhsize , cl(pl_id_09)
xi: reg inc_01 numplots pl_hhsize i.pl_id_10 if oi_assign == "Treatment" , cl(pl_id_09)
xi: reg inc_02 numplots pl_hhsize i.pl_id_10 if treatment == 1 , cl(pl_id_09)

* Have a lovely day! <- Stata needs a blank line at the end of code. I like affirmations.
