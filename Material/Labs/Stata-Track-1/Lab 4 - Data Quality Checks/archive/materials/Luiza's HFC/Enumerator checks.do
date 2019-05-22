/*******************************************************************************
*   					  SURVEY HIGH FREQUENCY CHECKS						   *
********************************************************************************
	
	** OUTLINE:		PART 1: List uploaded surveys by enumerator on last survey day		
					PART 2: Total number of households surveyed by enumerator
					PART 3: Total number of surveys completed by enumerator
					PART 4: Average survey duration by enumerator
					PART 5: Share of don't knows and refusals
					
	** WRITEN BY:   Luiza Andrade [lcardosodeandrad@worldbank.org]
	** Last time modified: Oct 2017
	
********************************************************************************
* 		PART 1: List uploaded surveys by enumerator on last suvey day
*******************************************************************************/

	if $enum_ids {
		
		* We will create a data set where variable names are enumerators names
		* and variable values are the list of hhids they submitted in the last
		* day of survey. We will then export this data set as a table.
		
		preserve	
			
			tempfile names
			save	 `names'
				
			* Loop over teams -- save one table per team
			if $teams {
				
				foreach team of global teamsList {
					
					* Create a table that has enumerators names as columns names
					* ----------------------------------------------------------
					use `names', clear
					
					* Get list of enumerators in the team
					levelsof enumeratorName if $teamVar == `team', local(enumeratorsList)
					local 	 enumCount = `: word count `enumeratorsList''

					clear
					set obs 1
					
					forvalues enumerator = 1/`enumCount'{
						
						gen v`enumerator' = "`: word `enumerator' of `enumeratorsList''"
					
					}
					
					* Save tempfile															// We will alternate between the raw data and this table to fill it
					tempfile submitted
					save	`submitted', replace


					* Fill each enumerator's column with the list of HHIDs they submitted
					* -------------------------------------------------------------------
					forvalues enumerator = 1/`enumCount'{
					
						use	 `names', clear
						
						* Get list of households
						if $lastDay {
							levelsof $idVar if enumeratorName == "`: word `enumerator' of `enumeratorsList''" & $dateCondition, local(idList)
						}
						else {
							levelsof $idVar if enumeratorName == "`: word `enumerator' of `enumeratorsList''", local(idList)
						}
						
						* Count number of households submitted
						local totalIds = `: word count `idList'' + 1
										
						* Open the table
						use `submitted', clear
						
						* We need to have as many rows as submitted households,
						* so we'll increase the number of observations in the data set
						* in case they don't fit
						if `totalIds' > _N {
							set obs `totalIds'
						}
				
						* Now will fill the row values with the list of households
						forvalues obs = 1/`totalIds' {
							replace v`enumerator' = "`: word `obs' of `idList''" if _n == `obs' + 1
						}
				
						* Save table, then go back to survey data for next enumerator
						save `submitted', replace
						
					}

					* Export team's table, then go back to survey data for next team
					* --------------------------------------------------------------
					use `submitted', clear
					sxpose, clear
					export excel "$output/Raw files/team`team'_id_list.xlsx", replace
						 
				}
			}
			else {
			
				* Create a table that has enumerators names as columns names
				* ----------------------------------------------------------
				* Get list of enumerators in the team
				levelsof enumeratorName, local(enumeratorsList)
				local 	 enumCount = `: word count `enumeratorsList''

				clear
				set obs 1
				
				forvalues enumerator = 1/`enumCount'{
					
					gen v`enumerator' = "`: word `enumerator' of `enumeratorsList''"
				
				}
				
				* Save tempfile															// We will alternate between the raw data and this table to fill it
				tempfile submitted
				save	`submitted', replace


				* Fill each enumerator's column with the list of IDs they submitted
				* -------------------------------------------------------------------
				forvalues enumerator = 1/`enumCount'{
				
					use	 `names', clear
					
					* Get list of households
					levelsof $idVar if enumeratorName == "`: word `enumerator' of `enumeratorsList''" & $dateCondition, local(idList)
					
					* Count number of households submitted
					local totalIds = `: word count `idList'' + 1
									
					* Open the table
					use `submitted', clear
					
					* We need to have as many rows as submitted households,
					* so we'll increase the number of observations in the data set
					* in case they don't fit
					if `totalIds' > _N {
						set obs `totalIds'
					}
			
					* Now will fill the row values with the list of households
					forvalues obs = 1/`totalIds' {
						replace v`enumerator' = "`: word `obs' of `idList''" if _n == `obs' + 1
					}
			
					* Save table, then go back to survey data for next enumerator
					save `submitted', replace
					
				}

				* Export team's table, then go back to survey data for next team
				* --------------------------------------------------------------
				use `submitted', clear
				export excel "$output/Raw files/id_list.xlsx", replace
						 
			}
			
		restore		
	}
	

	
********************************************************************************
* 				PART 2: Number of hhs surveyed by enumerator
********************************************************************************
	
	if $enum_count {
	
		if $teams {
			foreach team of global teamsList {
				preserve
				
					keep if $teamVar == `team'
					
					graph 	hbar	(count) $idVar ///
									(sum) 	$consentYesVar, ///
									over	($enumeratorVar) ///
							graphregion		(color(white)) ///
							legend			(order(1 "Approached households" 2 "Surveyed households") ///
											cols(1)) ///
							bar				(1, color(stone)) ///
							bar				(2, color("1 102 94")) ///
							title			(Number of households surveyed)
						
					* Export graph
					graph export "$output/Raw files/id_count_total.png", width(5000) replace
					
				restore
			}
		}
		else {
		
			graph 	hbar	(count) $idVar ///
									(sum) 	$consentYesVar, ///
									over	($enumeratorVar) ///
							graphregion		(color(white)) ///
							legend			(order(1 "Approached households" 2 "Surveyed households") ///
											cols(1)) ///
							bar				(1, color(stone)) ///
							bar				(2, color("1 102 94")) ///
							title			(Number of households surveyed)
						
					* Export graph
					graph export "$output/Raw files/id_count_total.png", width(5000) replace
		}
	}

********************************************************************************
* 				PART 3: Number of surveys completed by enumerator
********************************************************************************

	if $enum_finish {
		preserve
			
			* Calculate number of surveys per enumerator and identify lower and upper
			* percentiles
			* ----------------------------------------------------------------------
			tempfile submissions
			
				* Count number of surveys submitted
				collapse (count) count = $completeVar, by(enumeratorName $teamVar)
				
				qui sum count
				local maxValue = r(max)
				local interval = floor(`maxValue'/5)

				* Identify enumerators in critical percentiles
				centile count, centile($lowerPctile $upperPctile)
				
				gen 	flag_bottom = 1 if count < `r(c_1)'
				gen 	flag_top = 1 	if count > `r(c_2)'
			
			if $teams {
			
				* Order enumerators (so plot looks nice)
				gsort 	+$teamVar -enumeratorName
				by 		$teamVar: gen order = _n
				
				save `submissions'
				
				* Plot number of surveys per enumerator, save one plot per team
				* -------------------------------------------------------------
				foreach team of global teamsList {
				
					* Load team's data
					use `submissions', clear
					keep if $teamVar == `team'
					
					describe
					if r(N) > 0 {
					
					* Order variable will now be a factor labeled with enumerator's name
					labmask order, val(enumeratorName)
					
					* Calculate number of valid observations
					qui count if count != .
					
					* Create graph
					twoway 	(bar count order if flag_bottom == 1, color(orange) horizontal barwidth(.8)) ///
							(bar count order if flag_bottom != 1 & flag_top!= 1, color(stone) horizontal barwidth(.8)) ///
							(bar count order if flag_top == 1,	color(ebblue) horizontal barwidth(.8)), ///
							legend(off) ///
							ylabel(1/`r(N)',valuelabel angle(0)) ///
							xlabel(0(`interval')`maxValue') ///
							title(Number of surveys submitted) ///
							graphregion(color(white)) ///
							ytitle("") xtitle("")
							
					* Export graph
					graph export "$output/Raw files/team`team'_id_count_complete.png", width(5000) replace
							
					}
				}
			}
			else {
				* Order enumerators (so plot looks nice)
				gsort -enumeratorName
				gen order = _n
				
				* Order variable will now be a factor labeled with enumerator's name
				labmask order, val(enumeratorName)
				
				* Calculate number of valid observations
				qui count if count != .
				
				* Create graph
				twoway 	(bar count order if flag_bottom == 1, color(orange) horizontal barwidth(.8)) ///
						(bar count order if flag_bottom != 1 & flag_top!= 1, color(stone) horizontal barwidth(.8)) ///
						(bar count order if flag_top == 1,	color(ebblue) horizontal barwidth(.8)), ///
						legend(off) ///
						ylabel(1/`r(N)',valuelabel angle(0)) ///
						xlabel(0(`interval')`maxValue') ///
						title(Number of surveys submitted) ///
						graphregion(color(white)) ///
						ytitle("") xtitle("")
						
				* Export graph
				graph export "$output/Raw files/id_count_complete.png", width(5000) replace
			}
		restore 
	}
	
********************************************************************************
* 				PART 4: Average survey duration by enumerator
********************************************************************************
	
	if $enum_duration {
		foreach durationVar in $durationList {
		
			local durationVarLabel: var label `durationVar'
			
			centile `durationVar', centile($lowerPctile $upperPctile)
			local 	low  = `r(c_1)'
			local 	high = `r(c_2)'
			
			qui sum `durationVar'
			local 	mean = r(mean)
			
			if $teams {
				foreach team of global teamsList {
				
					* Create graph
					gr 	hbox `durationVar' if $teamVar == `team', over($enumeratorVar) ///
						box(1, color(stone)) ///
						title(`durationVarLabel') ///
						ytitle("") ///
						yline(`mean', lcolor(olive) lpattern(dash)) ///
						yline(`low', lcolor(dkorange) lpattern(dash)) ///
						yline(`high', lcolor(ebblue) lpattern(dash)) ///
						graphregion(color(white))
							
					* Export graph
					graph export "$output/Raw files/team`team'_`durationVar'.png", width(5000) replace
				}
			}
			else {
				* Create graph
					gr 	hbox `durationVar', over($enumeratorVar) ///
						box(1, color(stone)) ///
						title(`durationVarLabel') ///
						ytitle("") ///
						yline(`mean', lcolor(olive) lpattern(dash)) ///
						yline(`low', lcolor(dkorange) lpattern(dash)) ///
						yline(`high', lcolor(ebblue) lpattern(dash)) ///
						graphregion(color(white))
							
					* Export graph
					graph export "$output/Raw files/`durationVar'.png", width(5000) replace
			}
		}			
	}

********************************************************************************
* 				PART 5: Share of don't knows and refusals
********************************************************************************

	if $enum_ref {
		preserve
		
			keep if $consentVar == 1	// otherwise, may have a lot more missings
			if "$questionVars" != "" keep $questionVars $enumeratorVar $teamVar
			ds, has(type numeric)
			keep `r(varlist)' $enumeratorVar $teamVar
			
			egen varCount = rownonmiss(_all)
			egen dkCount = anycount(_all), values($dkCode)
			egen refCount = anycount(_all), values($refCode)
			
			gen dkShare = (dkCount/varCount)*100
			gen refShare = (refCount/varCount)*100
			
			foreach missType in dk ref {
			
				* Identify enumerators in critical percentiles
				centile `missType'Count, centile($lowerPctile $upperPctile)	
				local 	low  = `r(c_1)'
				local 	high = `r(c_2)'
				
				qui sum `missType'Share
				local 	mean = r(mean)
								
				* Plot average duration per enumerator, save one plot per team
				* -------------------------------------------------------------
				if $teams {
					foreach team of global teamsList {
				
						if "`missType'" == "dk"	 	local label don't know answers
						if "`missType'" == "ref"	local label refusals to answer
						
						gr 	hbox `missType'Share if $teamVar == `team', over($enumeratorVar) ///
							box(1, color(stone)) ///
							title(Share of `label' per enumerator) ///
							ytitle("") ///
							yline(`mean', lcolor(olive) lpattern(dash)) ///
							yline(`low', lcolor(dkorange) lpattern(dash)) ///
							yline(`high', lcolor(ebblue) lpattern(dash)) ///
							graphregion(color(white)) ///
							subtitle(% of answered questions) ///
							ytitle("") ///
							graphregion(color(white))
									
							* Export graph
							graph export "$output/Raw files/team`team'_`missType'.png", width(5000) replace
					}
				}
				else {
					
					if "`missType'" == "dk"	 	local label don't know answers
					if "`missType'" == "ref"	local label refusals to answer
						
					gr 	hbox `missType'Share, over($enumeratorVar) ///
						box(1, color(stone)) ///
						title(Share of `label' per enumerator) ///
						ytitle("") ///
						yline(`mean', lcolor(olive) lpattern(dash)) ///
						yline(`low', lcolor(dkorange) lpattern(dash)) ///
						yline(`high', lcolor(ebblue) lpattern(dash)) ///
						graphregion(color(white)) ///
						subtitle(% of answered questions) ///
						ytitle("") ///
						graphregion(color(white))
								
						* Export graph
						graph export "$output/Raw files/enum_`missType'.png", width(5000) replace
				}
			}
		restore
		
		}
