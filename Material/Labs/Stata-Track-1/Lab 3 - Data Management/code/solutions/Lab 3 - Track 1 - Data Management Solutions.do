
********************************************************************************
* 							PART 1: FilePaths
*******************************************************************************/

   * Users
   * -----
   if c(username) == "kbrkb" {
		global track_1_folder "C:/Users/kbrkb/Dropbox/FC Training/June 2018/Manage Successful Impact Evaluations - 2018 Course Materials (public)/Stata Lab Track 1"
	}

   if c(username) == "wb506743" {
		global track_1_folder "C:/Users/wb506743/Dropbox/FC Training/June 2018/Manage Successful Impact Evaluations - 2018 Course Materials (public)/Stata Lab Track 1"
   }
   
   * Project folder globals
   * ---------------------
	global track_1_data        "$track_1_folder/data"
	global track_1_lab_2       "$track_1_folder/labs/Lab 2 - Coding for Reproducible Research"
	global track_1_lab_3       "$track_1_folder/labs/Lab 3 - Data Management"
	global output		       "$track_1_lab_3/output"

********************************************************************************
* 							PART 2: Descriptive 
*******************************************************************************/
	
	* Load the data. If you managed to save the data set with the duplicates removed in lab 5, use that data set, otherwise use the data set we prepared for you
	use "${track_1_data}/endline_data_rand.dta",  clear
	use "${track_1_lab_2}/endline_data_post_lab2.dta",  clear
	
	
	*-------------------------------------------------------------------------------
	* 						2.1 Task 1 
	*-------------------------------------------------------------------------------

		iefolder new project , proj("${track_1_lab_3}")

	*-------------------------------------------------------------------------------
	* 						2.2 Task 2
	*-------------------------------------------------------------------------------	

		iefolder new round baseline , proj("${track_1_lab_3}")
 
	*-------------------------------------------------------------------------------
	* 						2.3 Task 3-4
	*-------------------------------------------------------------------------------		

	*Re-run master do-file created in last task
		qui do "${track_1_lab_3}/DataWork/Project_MasterDofile.do" 
	
	
	**Load the data set (for the next line to work you first need to manually move the endline_data_raw.dta file to 
	* Stata Lab Track 1\labs\Lab 3 - Data Management\DataWork\EncryptedData\Round baseline Encrypted\Raw Identified Data)
		use "${baseline_dtRaw}/endline_data_raw.dta", clear
	
	*See seperate folder for the folder structure and 
	*the saving location of load_imported_data.do

	*-------------------------------------------------------------------------------
	* 						2.4 Task 5
	*-------------------------------------------------------------------------------	

	*Use codebook to explore ID variable candidate
		codebook id_05
	
	*Test that variable is a valid ID variable - if not it will break
		isid id_05
	
	*-------------------------------------------------------------------------------
	* 						2.5 Lab Task 6
	*-------------------------------------------------------------------------------	
	
	*Define the label with codes already in use
		label define dist 44 "Burera" 41 "Gicumbi" 54 "Kayonza" 55 "Rulindo" 51 "Rwamagana"
	
	*Encode the varaible using that label
		encode  pl_id_09,  gen(pl_id_09_code) label(dist) noextend
	
	*Move the new variable next to the old one
		order pl_id_09_code, after(pl_id_09)
	
	*-------------------------------------------------------------------------------
	* 						2.6 Lab Task 7
	*-------------------------------------------------------------------------------	
		
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
		
	