
/*******************************************************************************
*																			   *
*  Project:			  	DIME Field Coordinator Training 2019				   *
*						Georeferencing Hands-on Sessions					   *											   
*																 			   *
*  PURPOSE:  		  	Export polygon data	   	   	   						   * 
*  WRITTEN BY: 		  	Jonas Guthoff [jguthoff@worldbank.org]				   *
*						Matteo Ruzzante [mruzzante@worldbank.org]			   *
*  Last time modified: 	June 2019										   	   *
*																			   *
********************************************************************************

       OUTLINE:         Load data
                        Make long per plot
                        Make each observation one plot vertex
					    Clean up and save
					   
       REQUIRES:	    "${geo_raw_data}/Georeferencing (Points).dta"

       CREATES: 		"${geo_raw_data}/plots_clean.dta"
						"${geo_raw_data}/additional_info.dta"

       NOTES:   


********************************************************************************
* 							PART 1: LOAD DATA								   *
********************************************************************************/
	
	* Open final data set
	use "${geo_raw_data}/Georeferencing (Points).dta", clear
	
	* Generate a HHID
	gen hhid = _n

	
********************************************************************************
* 						PART 2: RESHAPE LONG PER PLOT						   *
********************************************************************************

	* List of plot-level variables
	
	local   plotVars 				    										///
		    map_ map_index_	 													///
		    gps1latitude_  gps1longitude_  gps1altitude_  gps1accuracy_			///
		    gps2latitude_  gps2longitude_  gps2altitude_  gps2accuracy_ 		///
		    gps3latitude_  gps3longitude_  gps3altitude_  gps3accuracy_			///
		    gps4latitude_  gps4longitude_  gps4altitude_  gps4accuracy_			///
		    gps5latitude_  gps5longitude_  gps5altitude_  gps5accuracy_ 		///	    
		    gps6latitude_  gps6longitude_  gps6altitude_  gps6accuracy_			///
		    gps7latitude_  gps7longitude_  gps7altitude_  gps7accuracy_ 		///	    
		    gps8latitude_  gps8longitude_  gps8altitude_  gps8accuracy_			///
		    gps9latitude_  gps9longitude_  gps9altitude_  gps9accuracy_ 	 	///   
		    gps10latitude_ gps10longitude_ gps10altitude_ gps10accuracy_ 		///	    
		    gps11latitude_ gps11longitude_ gps11altitude_ gps11accuracy_		///
		    gps12latitude_ gps12longitude_ gps12altitude_ gps12accuracy_ 	 	///   
		    gps13latitude_ gps13longitude_ gps13altitude_ gps13accuracy_ 		///	    
		    gps14latitude_ gps14longitude_ gps14altitude_ gps14accuracy_		///
		    gps15latitude_ gps15longitude_ gps15altitude_ gps15accuracy_ 	    	

	* Reshape to long
	reshape long `plotVars', i(key) j(plot) 
		
	* Keep only relevant variables
	keep 	hhid plot      key team 											///
			map_ 		   map_index_	 	desc_plot1-desc_plot5				///
			gps1latitude_  gps1longitude_   gps1accuracy_						///
			gps2latitude_  gps2longitude_   gps2accuracy_ 						///
			gps3latitude_  gps3longitude_   gps3accuracy_						///
			gps4latitude_  gps4longitude_   gps4accuracy_						///
			gps5latitude_  gps5longitude_   gps5accuracy_ 						///	    
			gps6latitude_  gps6longitude_   gps6accuracy_						///
			gps7latitude_  gps7longitude_   gps7accuracy_ 						///	    
			gps8latitude_  gps8longitude_   gps8accuracy_						///
			gps9latitude_  gps9longitude_   gps9accuracy_ 						///   
			gps10latitude_ gps10longitude_  gps10accuracy_ 						///	    
			gps11latitude_ gps11longitude_  gps11accuracy_						///
			gps12latitude_ gps12longitude_  gps12accuracy_ 						///   
			gps13latitude_ gps13longitude_  gps13accuracy_ 						///	    
			gps14latitude_ gps14longitude_  gps14accuracy_						///
			gps15latitude_ gps15longitude_  gps15accuracy_ 	    
	
	* Rename reshaped variables
	forv point = 1/9			 					  {	
		foreach geoVar in latitude longitude accuracy {
			
			rename gps`point'`geoVar'_	`geoVar'`point'
		}
	}	

	* Reshape to long
	reshape long latitude longitude accuracy, i(plot key) j(point) string
	
	* Drop blank obs
	drop if missing(latitude) & missing(longitude) & missing(latitude)

	
********************************************************************************
* 						PART 3: CLEAN UP AND SAVE							   *
********************************************************************************
	
	* Identify points 
	replace  point = subinstr(point, "gps", "", .)
	destring point , replace
	
	order 	 key
	sort  	 key plot point

	* Generate a Plot ID
	egen 	 plot_ID =  group(hhid plot)
	
	* Generate the plot descriptions for the corresponding plot
	gen  	 plot_desc = ""
	
	forv 	 plotNum = 1/5 {
			 replace plot_desc = desc_plot`plotNum' if map_ == `plotNum'
	}
			
	* Save some additional information that will be merged to the polygons in R
	preserve
		
		duplicates drop plot_ID, force
		order 	   key  plot_ID  team hhid map_ map_index_ accuracy plot_desc 
		keep  	   key  plot_ID  team hhid map_ map_index_ accuracy plot_desc 
		
		save  "${geo_raw_data}/additional_info.dta", replace
		
	restore
			
	* Keep here only key variables
	order  plot_ID hhid team plot point latitude longitude accuracy key 
	keep   plot_ID hhid team plot point latitude longitude accuracy key
		
	* Save clean dataset
	save "${geo_raw_data}/plots_clean.dta", replace

**************************** End of do-file ************************************
