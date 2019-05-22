/*******************************************************************************
*   					  SURVEY HIGH FREQUENCY CHECKS						   *
********************************************************************************
	
	** OUTLINE:		PART 1: Share of variables with all missing observations per section
					PART 2: Identify variables that only have missing variables
					PART 3: Check variables that should have no missing values
					PART 4: Other values to recategorize
					PART 5: Identify outliers
									
	** WRITEN BY:   Luiza Andrade [lcardosodeandrad@worldbank.org]
	** Last time modified: Oct 2017
********************************************************************************
*	PART 1: Share of variables with all missing observations per section
*******************************************************************************/
	 
	if $dup_times {
	
		preserve
		
			keep if 	!inlist(start_year,${surveyYears}) | ///
						!inlist(start_month,${surveyMonths}) | ///
						(starttime < endtime)
			
			count
			if r(N) != 0 {
				
				* Prepare for exporting
				sort 	$enumeratorVar $dateVar
				gen 	issue = "Inaccurate device date"
				keep 	${issuesVarList} deviceid starttime endtime			
				order 	${issuesVarList} deviceid starttime endtime
			
				* Save separate reports for each team, if that option was selected
				* ================================================================
				if $teams {
				
					* Save tempfile for loop
					* ----------------------
					tempfile wrong_dates
					save	 `wrong_dates'
				
					* Loop through teams
					* ------------------
					foreach team of global teamsList {

						use `wrong_dates',clear
						count if $teamVar == `team'
						 
						if r(N) != 0 {
						
							* Display message confirming lack of consent
							* ------------------------------------------
							noi display as error "{phang}Team `team' has `r(N)' surveys inaccurate dates.{p_end}"
						
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
					noi display as error "{phang}There are `r(N)' surveys with inaccurate dates.{p_end}"
							
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
*	PART 1: Share of variables with all missing observations per section
*******************************************************************************/

	if $survey_section {
		preserve
		
			keep $questionVars
			ds, has(type numeric)
			keep `r(varlist)'
			
			tempfile questionVars
			save	 `questionVars'
			
			local nobs = _N
			
			xpose, clear varname promote
		
			gen survey_section = ""
			foreach section of global sectionsList {
				local nChar = length("$`section'")
				replace survey_section = "`section'" if substr(_varname,1,`nChar') == "$`section'"
			}
		
			egen missings = rowmiss(_all)
			gen all_miss = (missings == `nobs')
			
			collapse (count) missings (sum) all_miss, by(survey_section)
			
			gen share = (all_miss/missings)*100
			
			gr 	bar share, ///
				over(survey_section) ///
				graphregion(color(white)) ///
				title("Percentage of variables with all missing" "observations per section") ///
				ytitle("%")
				
			graph export "$output/Raw files/sections_missing.png", width(5000) replace
			
		restore
	}
	
********************************************************************************
* 		PART 2: Identify variables that only have missing variables
********************************************************************************

	if $survey_missvar {
		preserve
			
			keep $questionVars
			ds, has(type numeric)
			keep `r(varlist)'
			
			tempfile questionVars
			save	 `questionVars'
			
			clear
			tempfile exportTable
			gen		 delete_me = 1
			save	 `exportTable'
			
			foreach section of global sectionsList {
				
				di "`section'"
				local allmissVarList = ""
				
				use	 `questionVars', clear
				
				foreach allmissVar of varlist $`section'* {
				
					cap assert mi(`allmissVar')
					if !_rc {
						local allmissVarList "`allmissVarList' `allmissVar'"
					}
				}
					
				local varcount = `: word count `allmissVarList''
				if `varcount' > 0 {
					use	 `exportTable', clear
					
					local nobs = _N
					if `varcount' > `nobs' {
						set obs `: word count `allmissVarList''
					}
					
					gen `section' = ""
					
					forvalues varNo = 1/`: word count `allmissVarList'' {		
						replace `section' = "`:word `varNo' of `allmissVarList''" in `varNo'
					}
					
					tempfile  exportTable
					save	 `exportTable', replace
				}
			}
			
			use  `exportTable', clear
			drop delete_me
			
			export excel using "$output\Raw files\allmiss.xls", sheetreplace firstrow(variables)

		
		restore 
	}	

	
********************************************************************************
* 		PART 3: Check variables that should have no missing values
*******************************************************************************/

	if $survey_nomiss {
		preserve
			
			clear
			
			gen missing_var = ""
			
			tempfile nomiss
			save	 `nomiss'
		
		restore
			
		foreach nomissVar of global nomissVarList {
		
			cap assert mi(`nomissVar')
			if _rc {
			
				preserve 
				
					keep if `nomissVar' == .
					keep 	$enumeratorVar $dateVar $hhVar
					gen 	missing_var = "`nomissVar'"
					
					append 	using `nomiss'
					save 	`nomiss', replace
					
				restore
					
			}	
		}
		
		preserve
			
			use  `nomiss', clear
			sort  missing_var $enumeratorVar
			order missing_var $enumeratorVar $dateVar $hhVar
			
			dataout, save("$output/Raw files/delete_me") tex mid(1) replace
			filefilter 	"$output/Raw files/delete_me.tex" "$output/Raw files/nomiss.tex", 	///
						from("documentclass[]{article}") to("documentclass[border=1em]{standalone}") ///
						replace
		restore
	}
	
********************************************************************************
* 						PART 4: Other values to recategorize
********************************************************************************
	
	if $survey_other {
		foreach otherVar of local otherVarList {
			
			replace `otherVar' = "" if `otherVar' == "."
			
			cap assert mi(`otherVar')
			if _rc {
		
				local varLabel : var label `otherVar'
			
				eststo clear
				estpost tab `otherVar'
				esttab 	using "$output/Raw files/other_`otherVar'.tex", /// 
						cells   ("b(label(Frequency)) pct(fmt(%9.2f)label(Share))")  ///
						replace varlabels(`e(labels)') ///
						title(`varLabel') ///
						nonumbers nomtitles
						
			}
		}
	}
	
********************************************************************************
* 							PART 5: Identify outliers
********************************************************************************

	if $survey_outliers {
		foreach outliersVar of global outliersVarList {
		
			sum `outliersVar', detail
		
			hist 	`outliersVar', ///
					freq kdensity ///
					color(gs12) ///
					xline(`r(p99)', lcolor(red) lwidth(vthin)) ///
					xline(`r(p95)', lcolor(cranberry) lwidth(vthin) lpattern(shortdash)) ///
					note(Note: `r(obs)' observations.)
					
			graph export "$output/Raw files/outliers_`outliersVar'.png", width(5000) replace
					
		}
	}
