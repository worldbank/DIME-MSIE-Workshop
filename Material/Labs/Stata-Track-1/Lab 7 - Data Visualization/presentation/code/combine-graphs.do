graph combine                 ///
    "${ST1_outRaw}/task1.gph" ///
    "${ST1_outRaw}/task2.gph" ///
    "${ST1_outRaw}/task3.gph" ///
  , graphregion(color(white))

graph export "${ST1_outRaw}/lab7.png" , replace width(1000)
