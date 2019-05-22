********************************************************************************
* 							Calculate inputs
********************************************************************************
	
	* Crate a string unique ID so when exporting it is not rounded
	capture confirm numeric variable $idVar
	if !_rc {
		tostring $idVar, gen(idStr)
    }
	else gen idStr = $idVar	
	
	* Create strings for a date variables so they are exported correctly
	foreach timeVar in date start end {
		generate `timeVar'Str = string(${`timeVar'Var}, "%tC")
	}
	
	if "$teamVar" != "" {
		global teams	1
		
		levelsof ${teamVar}, local(teamsList)
		global teamsList = "`teamsList'"
	}
	else {
		global teams	0
	}
	
	* Identify last submission date
	if $allObs {
		global dateCondition ""
	}
	else if $lastDay & !$lastDayChecked {
		qui sum $dateVar
		local lastDay = dofc(r(max))
		global dateCondition $dateVar >= `lastDay'
	}
	else if !$lastDay & $lastDayChecked {
	
		global dateCondition $dateVar >= $lastDayChecked
	}
	else {
		noi display as error "{phang} Dates to be checked were incorrectly specified. Note that you cannot select checking only the last day and specify one start date at the same time.{p_end}"	
	}

	* Make enumerators name a string to export them correctly
	local valueLabel : value label $enumeratorVar

	if "`valueLabel'" != "" {						
		decode 	 $enumeratorVar, gen(enumeratorName)
	}
	else {
		cap confirm numeric $enumeratorVar
		if _rc {
			gen enumeratorName = $enumeratorVar
		}
		else {
			tostring $enumeratorVar, gen(enumeratorName)
		}
	} 
			
