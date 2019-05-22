   * ******************************************************************** *
   * ******************************************************************** *
   *                                                                      *
   *               your_project_name                                      *
   *               MASTER DO_FILE                                         *
   *                                                                      *
   * ******************************************************************** *
   * ******************************************************************** *

       /*
       ** PURPOSE:      Write intro to project here

       ** OUTLINE:      PART 0: Standardize settings and install packages
                        PART 1: Set globals for dynamic file paths
                        PART 2: Set globals for constants and varlist
                               used across the project. Intall custom
                               commands needed.
                        PART 3: Call the task specific master do-files 
                               that call all do-files needed for that 
                               tas. Do not include Part 0-2 in a task
                               specific master do-file


       ** IDS VAR:      list_ID_var_here         //Uniquely identifies households (update for your project)

       ** NOTES:

       ** WRITEN BY:    names_of_contributors

       ** Last date modified: 30 May 2017
       */

*iefolder*0*StandardSettings****************************************************
*iefolder will not work properly if the line above is edited

   * ******************************************************************** *
   *
   *       PART 0:  INSTALL PACKAGES AND STANDARDIZE SETTINGS
   *
   *           -Install packages needed to run all dofiles called
   *            by this master dofile.
   *           -Use ieboilstart to harmonize settings across users
   *
   * ******************************************************************** *

*iefolder*0*End_StandardSettings************************************************
*iefolder will not work properly if the line above is edited

       *Install all packages that this project requires:
       ssc install ietoolkit

       *Standardize settings accross users
       ieboilstart, version(12.1)      //Set the version number to the oldest version used by anyone in the project team
       `r(version)'                    //This line is needed to actually set the version from the command above

*iefolder*1*FolderGlobals*******************************************************
*iefolder will not work properly if the line above is edited

   * ******************************************************************** *
   *
   *       PART 1:  PREPARING FOLDER PATH GLOBALS
   *
   *           -Set the global box to point to the project folder
   *            on each collaborators computer.
   *           -Set other locals that point to other folders of interest.
   *
   * ******************************************************************** *

   * Users
   * -----------

   *User Number:
   * You                     1    //Replace "You" with your name
   * Next User               2    //Assign a user number to each additional collaborator of this code

   *Set this value to the user currently using this file
   global user  2

   * Root folder globals
   * ---------------------

   if $user == 1 {
       global projectfolder "C:\Users\Kristoffer\Dropbox\FC Training\June 2017\Session Materials\Lab 3 - Data Management and Cleaning\Lab 3 - Track 1 - Data Management and Cleaning/solutions"
   }

   if $user == 2 {
       global projectfolder "C:\Users\WB462869\Dropbox\FC Training\June 2017\Session Materials\Lab 3 - Data Management and Cleaning\Lab 3 - Track 1 - Data Management and Cleaning/solutions"
   }


   * Project folder globals
   * ---------------------

   global dataWorkFolder         "$projectfolder/DataWork"

*iefolder*1*FolderGlobals*master************************************************
*iefolder will not work properly if the line above is edited

   global mastData               "$dataWorkFolder/MasterData" 

*iefolder*1*FolderGlobals*rawData***********************************************
*iefolder will not work properly if the line above is edited

   global encryptFolder          "$dataWorkFolder/EncryptedData" 
   global masterIdDataSets       "$encryptFolder/IDMasterKey" 


*iefolder*1*RoundGlobals*rounds*baseline*baseline*******************************
*iefolder will not work properly if the line above is edited

   *baseline folder globals
   global baseline               "$dataWorkFolder/baseline" 
   global baseline_dt            "$baseline/DataSets" 
   global baseline_do            "$baseline/Dofiles" 
   global baseline_out           "$baseline/Output" 

*iefolder*1*FolderGlobals*monitor***********************************************
*iefolder will not work properly if the line above is edited


*iefolder*1*End_FolderGlobals***************************************************
*iefolder will not work properly if the line above is edited


*iefolder*2*StandardGlobals*****************************************************
*iefolder will not work properly if the line above is edited

   * ******************************************************************** *
   *
   *       PART 2: - SET STANDARDIZATION GLOBALS AND OTHER CONSTANTS
   *
   *           -Set globals with numbers or lists of 
   *            variables that is supposed to stay the
   *            same across the project.
   *
   * ******************************************************************** *

   * Set all conversion rates used in unit standardization 
   * accross the whole project here. 

   **Example. Expand this section with globals for all constant
   * scalars used in this project. Reference these globals instead
   * of hardcode values each time constant converstion rates are used.
   *Standardizing to meters

   global foot     = 0.3048
   global mile     = 1609.34
   global km       = 1000

   **Other examples to be included here could be regression controls
   * used across the project. Everything that is constant may be
   * included here. One example of something not constant that should
   * be included here is exchange rates. It is best practice to have one
   * global with the exchange rate here, and reference this each time a
   * currency conversion is done. If the currency exchange rate needs to be
   * updated, then it only has to be done at one place for the whole project.


*iefolder*2*End_StandardGlobals*************************************************
*iefolder will not work properly if the line above is edited


*iefolder*3*RunDofiles**********************************************************
*iefolder will not work properly if the line above is edited

   * ******************************************************************** *
   *
   *       PART 3: - RUN DOFILES CALLED BY THIS MASTER DO FILE
   *
   *           -When survey rounds are added, this section will
   *            link to the master dofile for that round.
   *           -The default is that these dofiles are set to not
   *            run. It is rare that all round specfic master dofiles
   *            are called at the same time, the round specifc master
   *            dofiles are almost always called individually. The
   *            excpetion is when reviewing or replicating a full project.
   *
   * ******************************************************************** *


*iefolder*3*RunDofiles*baseline*baseline****************************************
*iefolder will not work properly if the line above is edited

   if (0) { //Change the 0 to 1 to run the baseline master dofile
       do "$baseline/baseline_MasterDofile.do" 
   }

*iefolder*3*End_RunDofiles******************************************************
*iefolder will not work properly if the line above is edited

