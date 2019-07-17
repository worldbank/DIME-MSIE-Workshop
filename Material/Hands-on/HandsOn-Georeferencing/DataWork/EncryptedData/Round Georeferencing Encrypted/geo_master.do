
/*******************************************************************************
*																			   *
*  Project:			  	DIME Field Coordinator Training 2019				   *
*						Georeferencing Hands-on Sessions					   *												   
*																 			   *
*  PURPOSE:  		  	Prepare polygon data   	   	   						   * 
*  WRITTEN BY: 		  	Jonas Guthoff [jguthoff@worldbank.org]				   *
						Matteo Ruzzante [mruzzante@worldbank.org]			   *
*  Last time modified: 	June 2019										   	   *
*																			   *
********************************************************************************

	** OUTLINE:		PART 1: Settings
					PART 2: Figures and Tables
	
	** REQUIRES:	Clean dataset

	** CREATES:		
	
	** NOTES:		
	
	
********************************************************************************
* 							PART 1: SETTINGS								   *
********************************************************************************/

*----------------------------------------------------------------------------- *
* 						1.0 Select sections to run
*----------------------------------------------------------------------------- *
								
	local import			1	// Import raw data from Survey CTO
	local export			1	// Prepare data for plotting (reshape)

* ---------------------------------------------------------------------------- *
* 						1.1 Initial settings
* ---------------------------------------------------------------------------- *
{
	* Standardize settings accross users
    global 				   stataVersion 	"15.0" 
    ieboilstart, version(${stataVersion})
			  `r(version)'   
	   
	set   maxvar 120000, perm
	query memory  
}   

* ---------------------------------------------------------------------------- *
* 						1.2 Create file path globals						   *
* ---------------------------------------------------------------------------- *
{
	* Users																		
	* -----
   	if  c(username) == 		"WB527265" { 										//Matteo Bank
		global dropbox		"C:/Users/WB527265/Dropbox/Georeferencing"
	}
	if  c(username) ==		"ruzza" {											//Matteo PC
		global dropbox		"C:/Users/ruzza/Dropbox/Georeferencing"
	}
	if  c(username) ==		"jonasguthoff" {									//Jonas PC
		global dropbox		"/Users/jonasguthoff/Dropbox/Georeferencing/"
	}
	//add your directory here!
	
	* Project folder globals
	* ----------------------	
	global dataWorkFolder	"${dropbox}/DataWork"
	global encryptFolder	"${dataWorkFolder}/EncryptedData"
	global geo_encrypt		"${encryptFolder}/Round Georeferencing Encrypted"
	
	global geo_raw_data     "${geo_encrypt}/Raw Identified Data"
	
	global geo_hfc			"${geo_encrypt}/High Frequency Checks"
	global geo_hfc_data		"${geo_hfc}/Data"
	global geo_hfc_out		"${geo_hfc}/Output"
	
	* Check global list
	macro  list
	
	* Create folders if they don't exist
	cap    mkdir 			"${dataWorkFolder}"
	cap    mkdir 			"${encryptFolder}"
	cap    mkdir 			"${geo_encrypt}"
	cap    mkdir 			"${geo_raw_data}"
	cap    mkdir 			"${geo_hfc}"
	cap    mkdir 			"${geo_hfc_data}"
	cap    mkdir 			"${geo_hfc_out}"
	
	* Make sure the raw data are there, otherwise the code won't work!
}
	
********************************************************************************
* 							PART 2: CLEANING								   *
********************************************************************************

* ---------------------------------------------------------------------------- *
* 								2.1 Run do-files						   	   *
* ---------------------------------------------------------------------------- *
{	
	
	if `import' do "${geo_encrypt}/Dofiles Import/import_georeferencing_points.do"
	if `export' do "${geo_hfc}/Export polygon coordinates.do"
}

***************************** End of do-file ***********************************
