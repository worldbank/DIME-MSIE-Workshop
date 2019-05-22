
	* Install required packages
   local user_commands ietoolkit       //Fill this list will all commands this project requires
   foreach command of local user_commands {
       cap which `command'
       if _rc == 111 {
           cap ssc install `command'
       }
   }

	*Standardize settings accross users
    ieboilstart, version(12.0)      											
    `r(version)'   

*-------------------------------------------------------------------------------
* 						1.2 Create file path globals
*-------------------------------------------------------------------------------

   * Users																		
   * -----
    if c(username) == "kbrkb" {
       global projectfolder "C:\Users\kbrkb\Dropbox\FC Training\June 2018"
	}

   if c(username) == "wb506743" {
		global projectfolder "C:\Users\wb506743\Dropbox\FC Training\June 2018"
   }
   *
   
   	
	*Open the data set
	use "$projectfolder\data\endline_data_raw.dta", clear 	
	
	* ENUMERATOR, TEAMS, BACK CHECKERS
	* Enumerator variable
	local enum "enumerator_ID"
	* Enumerator Team variable
	local enumteam "supervisor_ID"
	* Back checker variable
	local  bcer "backcheck_enum_ID"
	
	local type1_var plots lab_01_1  pl_age_1
	local type2_var pl_hhsize rf_1
	local type3_var fs_01 fs_03
	
	drop if inlist(id_05, 21495, 4099, 2116)
	
	save "$projectfolder\data\endline_data_raw_nodup.dta", replace
	
	bcstats, surveydata("$projectfolder\data\endline_data_raw_nodup.dta") bcdata("$projectfolder\data\back_check.dta") ///
		id(id_05) enumerator(`enum') enumteam(`enumteam') backchecker(`bcer') 	///
		t1vars(`type1_var') t2vars(`type2_var') t3vars(`type3_var') replace		///
		keepsurvey(starttime endtime importdate)
		
