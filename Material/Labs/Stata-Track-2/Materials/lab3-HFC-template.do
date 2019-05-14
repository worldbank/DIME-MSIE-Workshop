/* *************************************************************************** *
*            Lab Session 3                         *
*                                          *
*  PURPOSE:        This solution file is a suggested solution          *
            for how the file might look in the end of          *
            the excercise.                        *
                                         *
                                         *
                                         *
*  WRITEN BY:        Michael  Orevba                         *
*  Last time modified:  June 2018                         *
*                                         *
********************************************************************************


********************************************************************************
*               PART 1: SETTINGS
********************************************************************************/


*-------------------------------------------------------------------------------
*             1.1 Initial settings
*-------------------------------------------------------------------------------

  * Install required packages
  if 0 {
    ssc install ietoolkit, replace
  }

  *Standardize settings accross users
    ieboilstart, version(14.0)
    `r(version)'

  *set maxvar 32767, perm

*-------------------------------------------------------------------------------
*             1.2 Create file path globals
*-------------------------------------------------------------------------------

   * Users
   * -----
    if c(username) == "bendaniels" {
       global projectfolder "\Users\bendaniels\Dropbox\FC Training\June 2018"
  }

   if c(username) == "wb506743" {
    global projectfolder "C:\Users\wb506743\Dropbox\FC Training\June 2018"
   }
   *

   * Project folder globals
   * ---------------------
  global folder    "$projectfolder/Lab3/
  global output     "$folder/HFC checks.xls"               // This is where the HFCs will be stored
  global enumerators   pl_id_09 id_05 key submissiondate enumerator_ID

/*********************************************************************************

  ** OUTLINE:    Load data
        CHECK 1:  HH ID duplicates
        CHECK 2:  Length of survey (minutes)
        CHECK 3:  No Plots were selected
        CHECK 4:  Farmer has no seasonal crops
        CHECK 5:  Equipment rent upper limit
        Save reports

** REQUIRES:  $projectfolder\data\endline_data_raw.dta

** CREATES:    Issues flags based on enumerator performance

********************************************************************************
*                 Load data
*******************************************************************************/

  *Open endline raw data set
    use "$projectfolder\data\endline_data_raw.dta", clear
  gen blank = ""

  * Start flags count from zero
  local   num_flags = 0

  * Create blank file to add observations
  putexcel  set "$output", sheet("HH flags") replace
  putexcel  A1 = ("pl_id_09")              ///           District name
        B1 = ("id_05")                ///           HHID
        C1 = ("key")                 ///           Unique submission ID
        D1 = ("submissiondate")           ///           Submission date
        E1 = ("enumerator_ID")             ///           ID of the enumerator
        F1 = ("question")               ///           Question number in questionnaire
        G1 = ("variable")              ///           Name of the variable in the data set
        H1 = ("value")                ///           Original value of variable
        I1 = ("issue")                ///           Description of the issue with the observation
        J1 = ("correction")              ///           Column for field teams to add correct values -- leave blank
        K1 = ("initials")              //             ID of people who added corrections

  *Clean up time variables
    gen start = trim( ///
            subinstr( ///
              subinstr( ///
                substr(starttime,strpos(starttime,"2018")+4,.) ///
              ,"AM","",.) ///
            ,"PM","",.) ///
            )

    gen end = trim( ///
            subinstr( ///
              subinstr( ///
                substr(endtime,strpos(endtime,"2018")+4,.) ///
              ,"AM","",.) ///
            ,"PM","",.) ///
            )

    gen start_clock = clock(start,"hms")
    gen end_clock = clock(end,"hms")
    replace end_clock = end_clock + 12*60*60*1000 if end_clock < start_clock

*-------------------------------------------------------------------------------
*             Check 1: HH duplicates
*-------------------------------------------------------------------------------

*

*-------------------------------------------------------------------------------
*             Check 2: Length of survey (minutes)
*-------------------------------------------------------------------------------



*-------------------------------------------------------------------------------
*             Check 3: No Plots were selected
*-------------------------------------------------------------------------------




*-------------------------------------------------------------------------------
*             Check 4: Farmer has no seasonal crops
*-------------------------------------------------------------------------------


*-------------------------------------------------------------------------------
*             Check 5: Agricultural Equipment rent upper limit
*-------------------------------------------------------------------------------





******************* End do-file ****************************************************
