/*******************************************************************************
*   					  SURVEY HIGH FREQUENCY CHECKS						   *
********************************************************************************
	
	** OUTLINE:		PART 1: Check for duplicates 
					PART 2: Check number of incomplete interviews
					PART 3: Check for consent
					PART 4: Check progress (number of completed surveys per interest group)
									
	** WRITEN BY:   Luiza Andrade [lcardosodeandrad@worldbank.org]
	** Last time modified: Nov 2017
********************************************************************************
*					PART 0: Check unique ID is always defined
* 		If it's not, it will not be possible to run a number of checks
*******************************************************************************/

	* Check if ID is numeric or string to define format of missing
	cap confirm numeric $idVar
	if _rc {
		qui count if $idVar == .
		local missing .
	}
	else {
		qui count if $idVar == ""
		local missing ""
	}
	
	* Count if there are undefined IDs
	if r(N) > 0 {
		noi display as error "{phang} There are `r(N)' observations with no unique ID. Type 'e' and press ENTER to drop those observations and continue checks. Type 'BREAK' and press ENTER to stop.{p_end}"	
		pause
	}
	
	* Drop observations with no ID
	drop if $idVar == `missing'
	
********************************************************************************
* 						PART 1: Check for duplicates
********************************************************************************
	
* -----------------------------------------------------------------------------*
* 							1.1 Duplicated IDs
* -----------------------------------------------------------------------------*
	
	if $dup_ids {
	
		* If a team variable was defined, we'll create one report per team
		if $teams {
			foreach team of global teamsList {
			
				preserve 
				
					keep if $teamVar == `team'
					
					ieduplicates 	${idVar}, ///
									folder("$HFC/Final documents") ///
									uniquevars($keyVar) ///
									keepvars($dateVar $startVar $endVar $enumeratorVar) ///
									suffix(_team`team')
				restore
			}	
		}
		
		* Otherwise, there will only be one report in total
		else {
			ieduplicates 	${idVar}, ///
							folder("$HFC/Final documents") ///
							uniquevars($keyVar) ///
							keepvars($dateVar $startVar $endVar $enumeratorVar)
		}
	}
	
* -----------------------------------------------------------------------------*
* 						1.2 Duplicated times and dates
* -----------------------------------------------------------------------------*

	if $dup_times {
	
		preserve
			* Check if there are duplicated surveys
			* =====================================
			duplicates 	$startVars, generate(dup_date)
			count if dup_date > 0
			
			* If there are, identify them
			* ===========================
			if r(N) != 0 {
			
				keep if		dup_date > 0
				
				* Prepare for exporting
				sort 	$enumeratorVar $dateVar $startVars
				gen 	issue = "Different IDs with duplicated times and dates"
				keep 	${issuesVarList} deviceid ${startVars}					
				order 	${issuesVarList} deviceid ${startVars}
			
				* Save separate reports for each team, if that option was selected
				* ================================================================
				if $teams {
				
					* Save tempfile for loop
					* ----------------------
					tempfile duplicated_dates
					save	 `duplicated_dates'
				
					* Loop through teams
					* ------------------
					foreach team of global teamsList {

						use `duplicated_dates',clear
						count if $teamVar == `team'
						 
						if r(N) != 0 {
						
							* Display message confirming lack of consent
							* ------------------------------------------
							noi display as error "{phang}Team `team' has `r(N)' surveys with duplicated start times.{p_end}"
						
							* Put observations in issues report
							* ---------------------------------
							keep if $teamVar == `team'
							
							* Check if issues report already exists
							capture confirm file "$HFC/Output/Raw files/issues_team`team'.dta" 
							
							* If it does, append the new existing info
							if _rc {
								append using "$HFC/Output/Raw files/issues_team`team'.dta"
								duplicates drop
							}
							
							* Save updated report
							save "$HFC/Output/Raw files/issues_team`team'.dta", replace
							
						}	
					}
				}
					
				* Save single file if team option wasn't selected
				* ===============================================
				else {
					
					* Display message confirming lack of consent
					noi display as error "{phang}There are `r(N)' surveys with duplicated start times.{p_end}"
							
					* Check if issues report already exists
					capture confirm file "$output/Raw files/issues.dta" 
					
					* If it does, append the new existing info
					if !_rc {
						append using "$output/Raw files/issues.dta"
						duplicates drop
					}

					* Save updated report
					save "$HFC/Output/Raw files/issues.dta", replace
					
				}
			}
		restore
	}
	
********************************************************************************
*				PART 2: Count number of unfinished surveys
*******************************************************************************/

			
	* Check any interviews were not finished 
	qui count if $completeVar != 1
	
	if r(N) != 0 {
		
	noi display as error "{phang} There are `r(N)' incomplete interviews.{p_end}"	
			
		if $finished {
			
			preserve 
				
				keep if $completeVar != 1
		
				if $teams {
				
					if "$progressVars" == "" {
						gr  bar (count) ${idVar}, over($teamVar) ///
							blabel(total) ///
							title(Number of incomplete interviews) ///
							ytitle("") 
							
						gr export "$output/Raw files/incomplete.png", width(5000) replace
					}
					
					else {
						foreach progressVar of global progressVars {
						gr  bar (count) ${idVar}, over($teamVar) by(`progressVar') ///
							blabel(total) ///
							title(Number of incomplete interviews) ///
							ytitle("") 
							
						gr export "$output/Raw files/incomplete_by`progressVar'.png", width(5000) replace
						
						}
					}
				}
			
				else {
				
					if "$progressVars" != "" {
					
						foreach progressVar of global progressVars {
							gr  bar (count) ${idVar}, over(`progressVar') ///
								blabel(total) ///
								title(Number of incomplete interviews) ///
								ytitle("") 
								
							gr export "$output/Raw files/incomplete_by`progressVar'.png", width(5000) replace

						}
					}				
				}
			restore
		}
	}
	
	
	* Drop incomplete observations
	if $completeOnly {
		drop if $completeVar != 1
	}


********************************************************************************
* 						  3. Check for consent
********************************************************************************	

	if $consent {
	
		* Check if there are observations without consent
		qui count if $consentVar != 1 & $completeVar == 1
		if r(N) != 0 {
		
			preserve
			
				* Identify observations without consent
				* =====================================
				sort 	$enumeratorVar $dateVar
				gen 	issue = "No consent"
				keep 	$issuesVarList						
				order 	$issuesVarList	
			
				* Save separate reports for each team, if that option was selected
				* ================================================================
				if $teams {
				
					* Save tempfile for loop
					* ----------------------
					tempfile noconsent
					save	 `noconsent'
				
					* Loop through teams
					* ------------------
					foreach team of global teamsList {

						use `noconsent',clear
						count if $teamVar == `team'
						 
						if r(N) != 0 {
						
							* Display message confirming lack of consent
							* ------------------------------------------
							noi display as error "{phang}Team `team' has `r(N)' surveys with no consent.{p_end}"
						
							* Put observations in issues report
							* ---------------------------------
							keep if $teamVar == `team' & $consentVar != 1 & $completeVar == 1
							
							* Check if issues report already exists
							capture confirm file "$HFC/Output/Raw files/issues_team`team'.dta" 
							
							* If it does, append the new existing info
							if _rc {
								append using "$HFC/Output/Raw files/issues_team`team'.dta"
							}
							
							* Save updated report
							save "$HFC/Output/Raw files/issues_team`team'.dta", replace
							
						}	
					}
				}
					
				* Save single file if team option wasn't selected
				* ===============================================
				else {
					
					* Display message confirming lack of consent
					noi display as error "{phang}There are `r(N)' surveys with no consent.{p_end}"
							
					* Check if issues report already exists
					capture confirm file "$output/Raw files/issues.dta" 
					
					* If it does, append the new existing info
					if !_rc {
						append using "$output/Raw files/issues.dta"
						duplicates drop
					}

					* Save updated report
					save "$HFC/Output/Raw files/issues.dta", replace
				
				}
				
			restore
			
		}
	}	

	
********************************************************************************
* 							4. Check progress
********************************************************************************	

	if $progress {
		foreach varAux in $progressVars {
		
			preserve
			
				* Calculate inputs
				* ================
				
				* If there's no intended number of observations for this variable,
				* make it so the arrow will not be displayed
				* --------------------------------------------------------------
				cap confirm variable `varAux'_goal
				if _rc {
					gen `varAux'_goal = .
				}
					
				
				* Count number of surveys completed
				* ---------------------------------
				collapse 	`varAux'_goal (sum) count = $completeVar ///
							if `varAux' != ., ///
							by(`varAux')
				sort 		`varAux'
				
				* Calculate the maximum value to set the axis labels
				* --------------------------------------------------
				qui sum `varAux'_goal
				local maxValueGoal = r(max)
				
				qui sum count
				local maxValueVar = r(max)
				
				local maxValue = max(`maxValueGoal',`maxValueVar')
				local interval = floor(`maxValue'/5)
				
				tab `varAux' if `varAux' == `maxValue'
				* Create variable to display the goal arrow
				* -----------------------------------------
				gen order = _n
				gen order1 = order -.4
				gen order2 = order +.4
				
				* Label categories
				* ----------------
				* If variable is labelled, use the value labels
				local valueLabel : value label `varAux'

				if "`valueLabel'" != "" {						
					decode `varAux', gen(label)
					labmask order, val(label)
				}
				* Otherwise, just use the variable
				else {
					labmask order, val(`varAux')
				} 
			
				* Identify outliers
				* ------------------
				centile count, centile($lowerPctile $upperPctile)			
				gen 	flag_bottom = 1 if count < `r(c_1)'
	
				
				* Create and export graph
				* =======================				
				twoway 	(bar count order if flag_bottom == 1, color(red) horizontal barwidth(.8)) ///
						(bar count order if count, color(stone) horizontal barwidth(.8)) ///
						(bar count order if count == `varAux'_goal, color("102 194 164") horizontal barwidth(.8)) ///
						(pcarrow order1 `varAux'_goal order2 `varAux'_goal, lcolor("0 88 66") lpattern(dash) msize(zero) mcolor("0 88 66")), ///
						ylabel(1/`r(N)',valuelabel angle(0) labsize(vsmall)) ///
						xlabel(0(`interval')`maxValue') ///
						ytitle("") xtitle("") legend(off) ///
						graphregion(color(white))			
						
				graph 	export "$output/Raw files/obs_per_`varAux'.png", width(5000) replace
					
			restore 
		}
	}
