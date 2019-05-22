	
	/*
	
		This do-file laods the data and test that 
		the ID variable is uniquely and fully 
		identifying the data set
	
	*/
	
	*Load the data set
	use "$baseline_dtInt/LWH_Baseline_Raw_Imported.dta", clear
	
	*Use codebook to explore ID variable candidate
	codebook ID_05
	
	*Test that variable is a valid ID variable
	isid ID_05
