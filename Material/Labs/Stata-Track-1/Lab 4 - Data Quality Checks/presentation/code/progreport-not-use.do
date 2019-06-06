/* <=== Track 2. Track surveys completed against planned ===> */
/* :HERE
if ${run_progreport} {
progreport, ///
    master("${master}") ///
    survey("${sdataset_f}_checked") ///
    id(${id}) ///
    sortby(${psortby}) ///
    keepmaster(${pkeepmaster}) ///
    keepsurvey(${pkeepsurvey}) ///
    filename("${progreport}") ///
    target(${prate}) ///
    mid(${pmid}) ///
    ${pvariable} ///
    ${plabel} ///
    ${psummary} ///
    ${pworkbooks} ///
	surveyok
}
HERE: */
