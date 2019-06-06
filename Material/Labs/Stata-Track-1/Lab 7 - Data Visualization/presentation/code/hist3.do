* Let y axis depict frequency instead of density and set the width of bins to 5
histogram ag_16_x_16_1 if ag_16_x_16_1 < 200 & ag_16_x_16_1 > 0, freq w(5)
