* import_georeferencing_points.do
*
* 	Imports and aggregates "Georeferencing (Points)" (ID: georeferencing_points) data.
*
*	Inputs: .csv file(s) exported by the SurveyCTO Server
*	Outputs: "Georeferencing (Points).dta"
*
*	Output by the SurveyCTO Server June 8, 2019 12:00 AM.

* initialize Stata
clear all
set more off
set mem 100m

* *** NOTE ***                                              *** NOTE ***
* If you run this .do file without customizing it, Stata will probably 
* give you errors about not being able to find or open files. If so,
* put all of your downloaded .do and .csv files into a single directory,
* edit the "cd" command just below to point to that directory, and then
* remove the * from the front of that cd line to un-comment it. That
* should resolve the problem.
*
* If you continue to encounter errors, see what filename Stata is trying
* to open, and rename any downloaded files accordingly. (E.g., your 
* browser might have added a (1) or a (2) to a downloaded filename.)

* initialize workflow-specific parameters
*	Set overwrite_old_data to 1 if you use the review and correction
*	workflow and allow un-approving of submissions. If you do this,
*	incoming data will overwrite old data, so you won't want to make
*	changes to data in your local .dta file (such changes can be
*	overwritten with each new import).
local overwrite_old_data 0

* initialize form-specific parameters
local csvfile 		   "${geo_raw_data}/Georeferencing (Points)_WIDE.csv"
local dtafile 		   "${geo_raw_data}/Georeferencing (Points).dta"
local corrfile 	  	   "${geo_raw_data}/Georeferencing (Points)_corrections.csv"
local note_fields1 	   ""
local text_fields1 	   "deviceid subscriberid simid devicephonenum username duration caseid participant participant_other team plotstorepeat e_repeat1_count parcelle_id_* e2_1_* desc_plot1 desc_plot2 desc_plot3 desc_plot4"
local text_fields2 	   "desc_plot5 travel_plot1 travel_plot2 travel_plot3 travel_plot4 travel_plot5 tomap nummapcheck nummap difference_parcelle notmap_count notmap_id_* notmapwhy_* mapping_count map_index_* numpoints_*"
local text_fields3 	   "plotsmapped comment instanceid"
local date_fields1 	   ""
local datetime_fields1 "submissiondate starttime endtime"

disp
disp "Starting import of: `csvfile'"
disp

* import data from primary .csv file
insheet using "`csvfile'", names clear

* drop extra table-list columns
cap drop reserved_name_for_field_*
cap drop generated_table_list_lab*

* continue only if there's at least one row of data to import
if _N>0 {
	* drop note fields (since they don't contain any real data)
	forvalues i = 1/100 {
		if "`note_fields`i''" ~= "" {
			drop `note_fields`i''
		}
	}
	
	* format date and date/time fields
	forvalues i = 1/100 {
		if "`datetime_fields`i''" ~= "" {
			foreach dtvarlist in `datetime_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=clock(`tempdtvar',"MDYhms",2025)
						* automatically try without seconds, just in case
						cap replace `dtvar'=clock(`tempdtvar',"MDYhm",2025) if `dtvar'==. & `tempdtvar'~=""
						format %tc `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
		if "`date_fields`i''" ~= "" {
			foreach dtvarlist in `date_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=date(`tempdtvar',"MDY",2025)
						format %td `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
	}

	* ensure that text fields are always imported as strings (with "" for missing values)
	* (note that we treat "calculate" fields as text; you can destring later if you wish)
	tempvar ismissingvar
	quietly: gen `ismissingvar'=.
	forvalues i = 1/100 {
		if "`text_fields`i''" ~= "" {
			foreach svarlist in `text_fields`i'' {
				cap unab svarlist : `svarlist'
				if _rc==0 {
					foreach stringvar in `svarlist' {
						quietly: replace `ismissingvar'=.
						quietly: cap replace `ismissingvar'=1 if `stringvar'==.
						cap tostring `stringvar', format(%100.0g) replace
						cap replace `stringvar'="" if `ismissingvar'==1
					}
				}
			}
		}
	}
	quietly: drop `ismissingvar'


	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid


	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"
	cap label variable formdef_version "Form version used on device"
	cap label variable review_status "Review status"
	cap label variable review_comments "Comments made during review"
	cap label variable review_corrections "Corrections made during review"


	label variable participant "Please select all the participants in your team."
	note participant: "Please select all the participants in your team."

	label variable participant_other "Enter the name that was not on the list:"
	note participant_other: "Enter the name that was not on the list:"

	label variable team "Please give yourself a team name:"
	note team: "Please give yourself a team name:"

	label variable num_polygons "Please enter the number of polygons that you will map"
	note num_polygons: "Please enter the number of polygons that you will map"

	label variable tomap "Please georeference the \${plotstorepeat} polygons you entered before. If you en"
	note tomap: "Please georeference the \${plotstorepeat} polygons you entered before. If you entered more than 5 plots, we ask you to focus on the 5 most interesting ones. Please select in the following the polygons that you would like to georeference."

	label variable tomapcheck "Please select the \${nummapcheck} polygon(s) that you will georeference. Please "
	note tomapcheck: "Please select the \${nummapcheck} polygon(s) that you will georeference. Please verifier that the number is correct."
	label define tomapcheck 1 "Yes" 2 "No"
	label values tomapcheck tomapcheck

	label variable comment "Leave a comment"
	note comment: "Leave a comment"



	capture {
		foreach rgvar of varlist e2_1_* {
			label variable `rgvar' "A.1. Please describe the polygon \${parcelle_id} that you will map."
			note `rgvar': "A.1. Please describe the polygon \${parcelle_id} that you will map."
		}
	}

	capture {
		foreach rgvar of varlist e2_5_* {
			label variable `rgvar' "A.2. Please enter the travel time from the World Bank J building."
			note `rgvar': "A.2. Please enter the travel time from the World Bank J building."
		}
	}

	capture {
		foreach rgvar of varlist notmapwhy_* {
			label variable `rgvar' "Please give a brief explanation why you're not georeferencing this polygon."
			note `rgvar': "Please give a brief explanation why you're not georeferencing this polygon."
		}
	}

	capture {
		foreach rgvar of varlist map_* {
			label variable `rgvar' "Please select the plot you would like to georeference:"
			note `rgvar': "Please select the plot you would like to georeference:"
			label define `rgvar' 1 "Polygon 1: \${desc_plot1}, \${travel_plot1} minutes from the J building" 2 "Polygon 2: \${desc_plot2}, \${travel_plot2} minutes from the J building" 3 "Polygon 3: \${desc_plot3}, \${travel_plot3} minutes from the J building" 4 "Polygon 4: \${desc_plot4}, \${travel_plot4} minutes from the J building" 5 "Polygon 5: \${desc_plot5}, \${travel_plot5} minutes from the J building" 0 "NONE"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist gps1latitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 1 * (latitude)"
			note `rgvar': "* Polygon \${map} * * Point 1 * (latitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps1longitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 1 * (longitude)"
			note `rgvar': "* Polygon \${map} * * Point 1 * (longitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps1altitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 1 * (altitude)"
			note `rgvar': "* Polygon \${map} * * Point 1 * (altitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps1accuracy_* {
			label variable `rgvar' "* Polygon \${map} * * Point 1 * (accuracy)"
			note `rgvar': "* Polygon \${map} * * Point 1 * (accuracy)"
		}
	}

	capture {
		foreach rgvar of varlist gps2latitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 2 * (latitude)"
			note `rgvar': "* Polygon \${map} * * Point 2 * (latitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps2longitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 2 * (longitude)"
			note `rgvar': "* Polygon \${map} * * Point 2 * (longitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps2altitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 2 * (altitude)"
			note `rgvar': "* Polygon \${map} * * Point 2 * (altitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps2accuracy_* {
			label variable `rgvar' "* Polygon \${map} * * Point 2 * (accuracy)"
			note `rgvar': "* Polygon \${map} * * Point 2 * (accuracy)"
		}
	}

	capture {
		foreach rgvar of varlist gps3latitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 3 * (latitude)"
			note `rgvar': "* Polygon \${map} * * Point 3 * (latitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps3longitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 3 * (longitude)"
			note `rgvar': "* Polygon \${map} * * Point 3 * (longitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps3altitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 3 * (altitude)"
			note `rgvar': "* Polygon \${map} * * Point 3 * (altitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps3accuracy_* {
			label variable `rgvar' "* Polygon \${map} * * Point 3 * (accuracy)"
			note `rgvar': "* Polygon \${map} * * Point 3 * (accuracy)"
		}
	}

	capture {
		foreach rgvar of varlist done3_* {
			label variable `rgvar' "* Polygon \${map} * Point 3 is taken! Do you need to take more points to close t"
			note `rgvar': "* Polygon \${map} * Point 3 is taken! Do you need to take more points to close the polygon?"
			label define `rgvar' 1 "Yes" 0 "No - the polygon is closed."
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist gps4latitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 4 * (latitude)"
			note `rgvar': "* Polygon \${map} * * Point 4 * (latitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps4longitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 4 * (longitude)"
			note `rgvar': "* Polygon \${map} * * Point 4 * (longitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps4altitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 4 * (altitude)"
			note `rgvar': "* Polygon \${map} * * Point 4 * (altitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps4accuracy_* {
			label variable `rgvar' "* Polygon \${map} * * Point 4 * (accuracy)"
			note `rgvar': "* Polygon \${map} * * Point 4 * (accuracy)"
		}
	}

	capture {
		foreach rgvar of varlist done4_* {
			label variable `rgvar' "* Polygon \${map} * Point 4 is taken! Do you need to take more points to close t"
			note `rgvar': "* Polygon \${map} * Point 4 is taken! Do you need to take more points to close the polygon?"
			label define `rgvar' 1 "Yes" 0 "No - the polygon is closed."
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist gps5latitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 5 * (latitude)"
			note `rgvar': "* Polygon \${map} * * Point 5 * (latitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps5longitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 5 * (longitude)"
			note `rgvar': "* Polygon \${map} * * Point 5 * (longitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps5altitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 5 * (altitude)"
			note `rgvar': "* Polygon \${map} * * Point 5 * (altitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps5accuracy_* {
			label variable `rgvar' "* Polygon \${map} * * Point 5 * (accuracy)"
			note `rgvar': "* Polygon \${map} * * Point 5 * (accuracy)"
		}
	}

	capture {
		foreach rgvar of varlist done5_* {
			label variable `rgvar' "* Polygon \${map} * Point 5 is taken! Do you need to take more points to close t"
			note `rgvar': "* Polygon \${map} * Point 5 is taken! Do you need to take more points to close the polygon?"
			label define `rgvar' 1 "Yes" 0 "No - the polygon is closed."
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist gps6latitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 6 * (latitude)"
			note `rgvar': "* Polygon \${map} * * Point 6 * (latitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps6longitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 6 * (longitude)"
			note `rgvar': "* Polygon \${map} * * Point 6 * (longitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps6altitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 6 * (altitude)"
			note `rgvar': "* Polygon \${map} * * Point 6 * (altitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps6accuracy_* {
			label variable `rgvar' "* Polygon \${map} * * Point 6 * (accuracy)"
			note `rgvar': "* Polygon \${map} * * Point 6 * (accuracy)"
		}
	}

	capture {
		foreach rgvar of varlist done6_* {
			label variable `rgvar' "* Polygon \${map} * Point 6 is taken! Do you need to take more points to close t"
			note `rgvar': "* Polygon \${map} * Point 6 is taken! Do you need to take more points to close the polygon?"
			label define `rgvar' 1 "Yes" 0 "No - the polygon is closed."
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist gps7latitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 7 * (latitude)"
			note `rgvar': "* Polygon \${map} * * Point 7 * (latitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps7longitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 7 * (longitude)"
			note `rgvar': "* Polygon \${map} * * Point 7 * (longitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps7altitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 7 * (altitude)"
			note `rgvar': "* Polygon \${map} * * Point 7 * (altitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps7accuracy_* {
			label variable `rgvar' "* Polygon \${map} * * Point 7 * (accuracy)"
			note `rgvar': "* Polygon \${map} * * Point 7 * (accuracy)"
		}
	}

	capture {
		foreach rgvar of varlist done7_* {
			label variable `rgvar' "* Polygon \${map} * Point 7 is taken! Do you need to take more points to close t"
			note `rgvar': "* Polygon \${map} * Point 7 is taken! Do you need to take more points to close the polygon?"
			label define `rgvar' 1 "Yes" 0 "No - the polygon is closed."
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist gps8latitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 8 * (latitude)"
			note `rgvar': "* Polygon \${map} * * Point 8 * (latitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps8longitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 8 * (longitude)"
			note `rgvar': "* Polygon \${map} * * Point 8 * (longitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps8altitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 8 * (altitude)"
			note `rgvar': "* Polygon \${map} * * Point 8 * (altitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps8accuracy_* {
			label variable `rgvar' "* Polygon \${map} * * Point 8 * (accuracy)"
			note `rgvar': "* Polygon \${map} * * Point 8 * (accuracy)"
		}
	}

	capture {
		foreach rgvar of varlist done8_* {
			label variable `rgvar' "* Polygon \${map} * Point 8 is taken! Do you need to take more points to close t"
			note `rgvar': "* Polygon \${map} * Point 8 is taken! Do you need to take more points to close the polygon?"
			label define `rgvar' 1 "Yes" 0 "No - the polygon is closed."
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist gps9latitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 9 * (latitude)"
			note `rgvar': "* Polygon \${map} * * Point 9 * (latitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps9longitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 9 * (longitude)"
			note `rgvar': "* Polygon \${map} * * Point 9 * (longitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps9altitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 9 * (altitude)"
			note `rgvar': "* Polygon \${map} * * Point 9 * (altitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps9accuracy_* {
			label variable `rgvar' "* Polygon \${map} * * Point 9 * (accuracy)"
			note `rgvar': "* Polygon \${map} * * Point 9 * (accuracy)"
		}
	}

	capture {
		foreach rgvar of varlist done9_* {
			label variable `rgvar' "* Polygon \${map} * Point 9 is taken! Do you need to take more points to close t"
			note `rgvar': "* Polygon \${map} * Point 9 is taken! Do you need to take more points to close the polygon?"
			label define `rgvar' 1 "Yes" 0 "No - the polygon is closed."
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist gps10latitude_* {
			label variable `rgvar' "* Parcelle \${map} * * Point 10 * (latitude)"
			note `rgvar': "* Parcelle \${map} * * Point 10 * (latitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps10longitude_* {
			label variable `rgvar' "* Parcelle \${map} * * Point 10 * (longitude)"
			note `rgvar': "* Parcelle \${map} * * Point 10 * (longitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps10altitude_* {
			label variable `rgvar' "* Parcelle \${map} * * Point 10 * (altitude)"
			note `rgvar': "* Parcelle \${map} * * Point 10 * (altitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps10accuracy_* {
			label variable `rgvar' "* Parcelle \${map} * * Point 10 * (accuracy)"
			note `rgvar': "* Parcelle \${map} * * Point 10 * (accuracy)"
		}
	}

	capture {
		foreach rgvar of varlist done10_* {
			label variable `rgvar' "* Polygon \${map} * Point 10 is taken! Do you need to take more points to close "
			note `rgvar': "* Polygon \${map} * Point 10 is taken! Do you need to take more points to close the polygon?"
			label define `rgvar' 1 "Yes" 0 "No - the polygon is closed."
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist gps11latitude_* {
			label variable `rgvar' "* Parcelle \${map} * * Point 11 * (latitude)"
			note `rgvar': "* Parcelle \${map} * * Point 11 * (latitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps11longitude_* {
			label variable `rgvar' "* Parcelle \${map} * * Point 11 * (longitude)"
			note `rgvar': "* Parcelle \${map} * * Point 11 * (longitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps11altitude_* {
			label variable `rgvar' "* Parcelle \${map} * * Point 11 * (altitude)"
			note `rgvar': "* Parcelle \${map} * * Point 11 * (altitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps11accuracy_* {
			label variable `rgvar' "* Parcelle \${map} * * Point 11 * (accuracy)"
			note `rgvar': "* Parcelle \${map} * * Point 11 * (accuracy)"
		}
	}

	capture {
		foreach rgvar of varlist done11_* {
			label variable `rgvar' "* Polygon \${map} * Point 11 is taken! Do you need to take more points to close "
			note `rgvar': "* Polygon \${map} * Point 11 is taken! Do you need to take more points to close the polygon?"
			label define `rgvar' 1 "Yes" 0 "No - the polygon is closed."
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist gps12latitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 12 * (latitude)"
			note `rgvar': "* Polygon \${map} * * Point 12 * (latitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps12longitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 12 * (longitude)"
			note `rgvar': "* Polygon \${map} * * Point 12 * (longitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps12altitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 12 * (altitude)"
			note `rgvar': "* Polygon \${map} * * Point 12 * (altitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps12accuracy_* {
			label variable `rgvar' "* Polygon \${map} * * Point 12 * (accuracy)"
			note `rgvar': "* Polygon \${map} * * Point 12 * (accuracy)"
		}
	}

	capture {
		foreach rgvar of varlist done12_* {
			label variable `rgvar' "* Polygon \${map} * Point 12 is taken! Do you need to take more points to close "
			note `rgvar': "* Polygon \${map} * Point 12 is taken! Do you need to take more points to close the polygon?"
			label define `rgvar' 1 "Yes" 0 "No - the polygon is closed."
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist gps13latitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 13 * (latitude)"
			note `rgvar': "* Polygon \${map} * * Point 13 * (latitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps13longitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 13 * (longitude)"
			note `rgvar': "* Polygon \${map} * * Point 13 * (longitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps13altitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 13 * (altitude)"
			note `rgvar': "* Polygon \${map} * * Point 13 * (altitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps13accuracy_* {
			label variable `rgvar' "* Polygon \${map} * * Point 13 * (accuracy)"
			note `rgvar': "* Polygon \${map} * * Point 13 * (accuracy)"
		}
	}

	capture {
		foreach rgvar of varlist done13_* {
			label variable `rgvar' "* Polygon \${map} * Point 13 is taken! Do you need to take more points to close "
			note `rgvar': "* Polygon \${map} * Point 13 is taken! Do you need to take more points to close the polygon?"
			label define `rgvar' 1 "Yes" 0 "No - the polygon is closed."
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist gps14latitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 14 * (latitude)"
			note `rgvar': "* Polygon \${map} * * Point 14 * (latitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps14longitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 14 * (longitude)"
			note `rgvar': "* Polygon \${map} * * Point 14 * (longitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps14altitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 14 * (altitude)"
			note `rgvar': "* Polygon \${map} * * Point 14 * (altitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps14accuracy_* {
			label variable `rgvar' "* Polygon \${map} * * Point 14 * (accuracy)"
			note `rgvar': "* Polygon \${map} * * Point 14 * (accuracy)"
		}
	}

	capture {
		foreach rgvar of varlist done14_* {
			label variable `rgvar' "* Polygon \${map} * Point 14 is taken! Do you need to take more points to close "
			note `rgvar': "* Polygon \${map} * Point 14 is taken! Do you need to take more points to close the polygon?"
			label define `rgvar' 1 "Yes" 0 "No - the polygon is closed."
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist gps15latitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 15 * (latitude)"
			note `rgvar': "* Polygon \${map} * * Point 15 * (latitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps15longitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 15 * (longitude)"
			note `rgvar': "* Polygon \${map} * * Point 15 * (longitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps15altitude_* {
			label variable `rgvar' "* Polygon \${map} * * Point 15 * (altitude)"
			note `rgvar': "* Polygon \${map} * * Point 15 * (altitude)"
		}
	}

	capture {
		foreach rgvar of varlist gps15accuracy_* {
			label variable `rgvar' "* Polygon \${map} * * Point 15 * (accuracy)"
			note `rgvar': "* Polygon \${map} * * Point 15 * (accuracy)"
		}
	}




	* append old, previously-imported data (if any)
	cap confirm file "`dtafile'"
	if _rc == 0 {
		* mark all new data before merging with old data
		gen new_data_row=1
		
		* pull in old data
		append using "`dtafile'"
		
		* drop duplicates in favor of old, previously-imported data if overwrite_old_data is 0
		* (alternatively drop in favor of new data if overwrite_old_data is 1)
		sort key
		by key: gen num_for_key = _N
		drop if num_for_key > 1 & ((`overwrite_old_data' == 0 & new_data_row == 1) | (`overwrite_old_data' == 1 & new_data_row ~= 1))
		drop num_for_key

		* drop new-data flag
		drop new_data_row
	}
	
	* save data to Stata format
	save "`dtafile'", replace

	* show codebook and notes
	codebook
	notes list
}

disp
disp "Finished import of: `csvfile'"
disp

* apply corrections (if any)
capture confirm file "`corrfile'"
if _rc==0 {
	disp
	disp "Starting application of corrections in: `corrfile'"
	disp

	* save primary data in memory
	preserve

	* load corrections
	insheet using "`corrfile'", names clear
	
	if _N>0 {
		* number all rows (with +1 offset so that it matches row numbers in Excel)
		gen rownum=_n+1
		
		* drop notes field (for information only)
		drop notes
		
		* make sure that all values are in string format to start
		gen origvalue=value
		tostring value, format(%100.0g) replace
		cap replace value="" if origvalue==.
		drop origvalue
		replace value=trim(value)
		
		* correct field names to match Stata field names (lowercase, drop -'s and .'s)
		replace fieldname=lower(subinstr(subinstr(fieldname,"-","",.),".","",.))
		
		* format date and date/time fields (taking account of possible wildcards for repeat groups)
		forvalues i = 1/100 {
			if "`datetime_fields`i''" ~= "" {
				foreach dtvar in `datetime_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						gen origvalue=value
						replace value=string(clock(value,"MDYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
						* allow for cases where seconds haven't been specified
						replace value=string(clock(origvalue,"MDYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
						drop origvalue
					}
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						replace value=string(clock(value,"MDY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
					}
				}
			}
		}

		* write out a temp file with the commands necessary to apply each correction
		tempfile tempdo
		file open dofile using "`tempdo'", write replace
		local N = _N
		forvalues i = 1/`N' {
			local fieldnameval=fieldname[`i']
			local valueval=value[`i']
			local keyval=key[`i']
			local rownumval=rownum[`i']
			file write dofile `"cap replace `fieldnameval'="`valueval'" if key=="`keyval'""' _n
			file write dofile `"if _rc ~= 0 {"' _n
			if "`valueval'" == "" {
				file write dofile _tab `"cap replace `fieldnameval'=. if key=="`keyval'""' _n
			}
			else {
				file write dofile _tab `"cap replace `fieldnameval'=`valueval' if key=="`keyval'""' _n
			}
			file write dofile _tab `"if _rc ~= 0 {"' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab _tab `"disp "CAN'T APPLY CORRECTION IN ROW #`rownumval'""' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab `"}"' _n
			file write dofile `"}"' _n
		}
		file close dofile
	
		* restore primary data
		restore
		
		* execute the .do file to actually apply all corrections
		do "`tempdo'"

		* re-save data
		save "`dtafile'", replace
	}
	else {
		* restore primary data		
		restore
	}

	disp
	disp "Finished applying corrections in: `corrfile'"
	disp
}
