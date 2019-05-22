
	********
	*Task 1
	********

	global folder	"C:\Users\WB462869\Dropbox\FC Training\June 2017\DIME Training - Manage Successful Impact Evaluation - June 2017 (public)\Lab 3 - Data Management and Cleaning\Lab 3 - Track 1 - Data Management and Cleaning\Solutions"


	iefolder new project , proj("${folder}")


	********
	*Task 2
	********	

	iefolder new round baseline , proj("${folder}\Solutions")

	********
	*Task 3-4
	********

	*Load the data set
	use "$baseline_dtInt/LWH_Baseline_Raw_Imported.dta", clear
	
	*See seperate folder for the folder structure and 
	*the saving location of load_imported_data.do
	
	********
	*Task 5
	********

	*Use codebook to explore ID variable candidate
	codebook ID_05
	
	*Test that variable is a valid ID variable
	isid ID_05
	
	********
	*Task 6
	********
	
	*Define the label with codes already in use
	label define dist 1001 "Rwamangana" 1004 "Kayonza" 2001 "Karongi" 2002 "Rutsiro"
	
	*Encode the varaible using that label
	encode ID_09,  gen(ID_09_code) label(dist) noextend
	
	*Move the new variable next to the old one
	order ID_09_code, after(ID_09)
	
	********
	*Task 7
	********	
	
	*Summarize compost use
	summarize AAG_08_A
	
	*Replace -99 with missing value .a
	replace AAG_08_A = .a if AAG_08_A == -99
	
	*Summarize again
	summarize AAG_08_A
	
	********
	*Task 8
	********
	
	*Summarize the following four variables
	summarize AA_02_A AA_02_B AA_02_C AA_02_D , detail
	summarize AA_02_?, detail

	
	********
	*Task 9
	********
	
	*Install winsor command
	ssc install winsor
	
	*Winsorixe INC_01
	winsor INC_01 , gen(INC_01_w) high p(.05)
	
	*Compare the original variable with the winsorized one
	sum INC_01 INC_01_w
	sum INC_01 INC_01_w, d
	
