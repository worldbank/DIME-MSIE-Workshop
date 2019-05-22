/* *************************************************************************** *
*						Lab Session 3							  			   *												   
*																 			   *
*  PURPOSE:  			This solution file is a suggested solution 			   *
						for how the file might look in the end of 			   *	
						the excercise. 										   *
																			   *
																			   *
																			   *
*  WRITEN BY:  			Michael	Orevba	  									   *
*  Last time modified:  June 2018											   *
*																			   *
********************************************************************************


********************************************************************************
* 							PART 1: SETTINGS
*******************************************************************************/

*-------------------------------------------------------------------------------
* 						1.1 Initial settings
*-------------------------------------------------------------------------------

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
   
   * Project folder globals
   * ---------------------
	global folder	"$projectfolder\Session Materials\Stata Track 1\Lab 3 - Data Management"

   
	*The code below is to erase Datawork folder if it already exists from pilot testing
	* "C:\Users\wb506743\Dropbox\FC Training\June 2018\Session Materials\Stata Track 1\Lab 3 - Data Management\DataWork"
	
*-------------------------------------------------------------------------------
* 						2.1 Lab Task 1
*-------------------------------------------------------------------------------	

	iefolder new project , proj("${folder}")

*-------------------------------------------------------------------------------
* 						2.2 Lab Task 2
*-------------------------------------------------------------------------------	

	iefolder new round baseline , proj("${folder}")
 
*-------------------------------------------------------------------------------
* 						2.3 Lab Task 3-4
*-------------------------------------------------------------------------------		

	*Re-run master do-file created in last task
	qui do "$folder\DataWork\Project_MasterDofile.do" 
	
	
	exit 
	
	*Load the data set
	use "$baseline_dtRaw/endline_data_raw.dta", clear
	
	*See seperate folder for the folder structure and 
	*the saving location of load_imported_data.do

*-------------------------------------------------------------------------------
* 						2.4 Lab Task 5
*-------------------------------------------------------------------------------	

	*Use codebook to explore ID variable candidate
	codebook id_05
	
	*Test that variable is a valid ID variable - if not it will break
	isid id_05
	
*-------------------------------------------------------------------------------
* 						2.5 Lab Task 6
*-------------------------------------------------------------------------------	
	
	*Define the label with codes already in use
	label define dist 44 "Burera" 45 "Gicumbi" 54 "Kayonza" 41 "Rulindo" 51 "Rwamagana"
	
	*Encode the varaible using that label
	encode  pl_id_09,  gen(pl_id_09_code) label(dist) noextend
	
	*Move the new variable next to the old one
	order pl_id_09_code, after(pl_id_09)
	
*-------------------------------------------------------------------------------
* 						2.6 Lab Task 7
*-------------------------------------------------------------------------------	
	
	*Replace missing with -99
	replace ag_08_1_1 = -99 if ag_08_1_1 ==. // this was done for the training
	
	*Summarize compost use
	summarize ag_08_1_1
	
	*Replace -99 with missing value .a
	replace ag_08_1_1 = .a if ag_08_1_1 == -99
	
	*Summarize again
	summarize ag_08_1_1
	
*-------------------------------------------------------------------------------
* 						2.7 Lab Task 8
*-------------------------------------------------------------------------------		
	
	*Summarize the following four variables
	summarize aa_02_1 aa_02_2 aa_02_3 aa_02_4 aa_02_5 aa_02_6 aa_02_7 aa_02_8 aa_02_9 aa_02_10, detail
	summarize aa_02_?, detail

*-------------------------------------------------------------------------------
* 						2.8 Lab Task 9
*-------------------------------------------------------------------------------	
	
	*Install winsor command
	ssc install winsor
	
	*Winsorixe INC_01
	winsor inc_01 , gen(inc_01_w) high p(.05)
	
	*Compare the original variable with the winsorized one
	sum inc_01 inc_01_w
	sum inc_01 inc_01_w, d
	
	
	
	
******************* End do-file ****************************************************	
