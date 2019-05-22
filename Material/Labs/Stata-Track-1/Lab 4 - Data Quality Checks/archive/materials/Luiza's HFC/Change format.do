
	use "$HFC/Raw data/RFR_FU2_EU_v1.6.dta" , clear

	gen 	duration = (endtime_manual - starttime)/60000
	replace duration = . if duration < 0
	replace duration = . if duration > 5*3600
	lab var duration "Average survey duration (min)"
	
	destring id_05, gen(hhid)
	encode pl_id_06, gen(village_id)
	
	foreach district in "BUGESERA" "HUYE" "MUHANGA" "NGOMA" "NGORORERO" "RULINDO" "RUBAVU" {
		qui count if pl_id_09 == "`district'"
		if r(N) == 0 {
			local nbos = _N + 1
			set obs `nbos'
			replace pl_id_09 = "`district'" in `nbos'			
		}
	}
	encode pl_id_09, gen(district_id)
	
	gen complete = endtime_manual != .
	
	replace consent = 0 if hhid ==  3102185
	gen consent_yes = (consent == 1)
	
	lab def district_id 	1 "Sector 1" ///
							2 "Sector 2" ///
							3 "Sector 3" ///
							4 "Sector 4" ///
							5 "Sector 5" ///
							6 "Sector 6" ///
							7 "Sector 7" ///
							8 "Sector 8", replace	
	
	lab def village_id 	1 "Village 1" ///
						2 "Village 2" ///
						3 "Village 3" ///
						4 "Village 4" ///
						5 "Village 5" ///
						6 "Village 6" ///
						7 "Village 7" ///
						8 "Village 8" ///
						9 "Village 9" ///
						10 "Village 10" ///
						11 "Village 11" ///
						12 "Village 12" ///
						13 "Village 13" ///
						14 "Village 14" ///
						15 "Village 15" ///
						16 "Village 16" ///
						17 "Village 17" ///
						18 "Village 18" ///
						19 "Village 19" ///
						20 "Village 20" ///
						21 "Village 21" ///
						22 "Village 22" ///
						23 "Village 23" ///
						24 "Village 24" ///
						25 "Village 25" ///
						26 "Village 26" ///
						27 "Village 27" ///
						28 "Village 28" ///
						29 "Village 29" ///
						30 "Village 30" ///
						31 "Village 31", replace
	
	lab def id_03 	1 "Enumerator 1" ///
					2 "Enumerator 2" ///
					3 "Enumerator 3" ///
					4 "Enumerator 4" ///
					5 "Enumerator 5" ///
					6 "Enumerator 6" ///
					7 "Enumerator 7" ///
					8 "Enumerator 8" ///
					9 "Enumerator 9" ///
					10 "Enumerator 10" ///
					11 "Enumerator 11" ///
					12 "Enumerator 12" ///
					13 "Enumerator 13" ///
					14 "Enumerator 14" ///
					15 "Enumerator 15" ///
					16 "Enumerator 16" ///
					17 "Enumerator 17" ///
					18 "Enumerator 18" ///
					19 "Enumerator 19" ///
					20 "Enumerator 20" ///
					21 "Enumerator 21" ///
					22 "Enumerator 22" ///
					23 "Enumerator 23" ///
					24 "Enumerator 24" ///
					25 "Enumerator 25" ///
					26 "Enumerator 26" ///
					27 "Enumerator 27" ///
					28 "Enumerator 28" ///
					29 "Enumerator 29" ///
					30 "Enumerator 30" ///
					31 "Enumerator 31" ///
					32 "Enumerator 32" ///
					33 "Enumerator 33" ///
					34 "Enumerator 34" ///
					35 "Enumerator 35" ///
					36 "Enumerator 36" ///
					37 "Enumerator 37" ///
					38 "Enumerator 38" ///
					39 "Enumerator 39" ///
					40 "Enumerator 40" ///
					41 "Enumerator 41" ///
					42 "Enumerator 42" ///
					43 "Enumerator 43" ///
					44 "Enumerator 44" ///
					45 "Enumerator 45" ///
					46 "Enumerator 4" ///
					47 "Enumerator 4" ///
					48 "Enumerator 84", replace
					
					
						* Observation goals
