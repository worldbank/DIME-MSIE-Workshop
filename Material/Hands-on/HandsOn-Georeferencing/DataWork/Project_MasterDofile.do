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
                               used across the project. Install all user-contributed
                               commands needed.
                        PART 3: Call the task-specific master do-files 
                               that call all dofiles needed for that 
                               task. Do not include Part 0-2 in a task-
                               specific master do-file


       ** IDS VAR:      list_ID_var_here         //Uniquely identifies households (update for your project)

       ** NOTES:

       ** WRITTEN BY:   names_of_contributors

       ** Last date modified:  7 Jun 2019
       */

*iefolder*0*StandardSettings****************************************************
*iefolder will not work properly if the line above is edited

   * ******************************************************************** *
   *
   *       PART 0:  INSTALL PACKAGES AND STANDARDIZE SETTINGS
   *
   *           - Install packages needed to run all dofiles called
   *            by this master dofile.
   *           - Use ieboilstart to harmonize settings across users
   *
   * ******************************************************************** *

*iefolder*0*End_StandardSettings************************************************
*iefolder will not work properly if the line above is edited

   *Install all packages that this project requires:
   *(Note that this never updates outdated versions of already installed commands, to update commands use adoupdate)
   local user_commands ietoolkit       //Fill this list will all user-written commands this project requires
   foreach command of local user_commands {
       cap which `command'
       if _rc == 111 {
           ssc install `command'
       }
   }

   *Standardize settings accross users
   ieboilstart, version(12.1)          //Set the version number to the oldest version used by anyone in the project team
   `r(version)'                        //This line is needed to actually set the version from the command above

*iefolder*1*FolderGlobals*******************************************************
*iefolder will not work properly if the line above is edited

   * ******************************************************************** *
   *
   *       PART 1:  PREPARING FOLDER PATH GLOBALS
   *
   *           - Set the global box to point to the project folder
   *            on each collaborator's computer.
   *           - Set other locals that point to other folders of interest.
   *
   * ******************************************************************** *

   * Users
   * -----------

   *User Number:
   * You                     1    // Replace "You" with your name
   * Next User               2    // Assign a user number to each additional collaborator of this code

   *Set this value to the user currently using this file
   global user  1

   * Root folder globals
   * ---------------------

   if $user == 1 {
       global projectfolder "/Users/jonasguthoff/Dropbox/Georeferencing"
   }

   if $user == 2 {
       global projectfolder ""  // Enter the file path to the project folder for the next user here
   }

* These lines are used to test that the name is not already used (do not edit manually)
*round*Georeferencing***********************************************************
*untObs*************************************************************************
*subFld*************************************************************************
*iefolder will not work properly if the lines above are edited


   * Project folder globals
   * ---------------------

   global dataWorkFolder         "$projectfolder/DataWork"

*iefolder*1*FolderGlobals*subfolder*********************************************
*iefolder will not work properly if the line above is edited


*iefolder*1*FolderGlobals*master************************************************
*iefolder will not work properly if the line above is edited

   global mastData               "$dataWorkFolder/MasterData" 

*iefolder*1*FolderGlobals*encrypted*********************************************
*iefolder will not work properly if the line above is edited

   global encryptFolder          "$dataWorkFolder/EncryptedData" 


*iefolder*1*RoundGlobals*rounds*Georeferencing*Georeferencing*******************
*iefolder will not work properly if the line above is edited

   *Georeferencing folder globals
   global Georeferencing         "$dataWorkFolder/Georeferencing" 
   global Georeferencing_encrypt "$encryptFolder/Round Georeferencing Encrypted" 
   global Georeferencing_dt      "$Georeferencing/DataSets" 
   global Georeferencing_do      "$Georeferencing/Dofiles" 
   global Georeferencing_out     "$Georeferencing/Output" 

*iefolder*1*FolderGlobals*endRounds*********************************************
*iefolder will not work properly if the line above is edited


*iefolder*1*End_FolderGlobals***************************************************
*iefolder will not work properly if the line above is edited


*iefolder*2*StandardGlobals*****************************************************
*iefolder will not work properly if the line above is edited

   * Set all non-folder path globals that are constant accross
   * the project. Examples are conversion rates used in unit
   * standardization, different sets of control variables,
   * adofile paths etc.

   do "$dataWorkFolder/global_setup.do" 


*iefolder*2*End_StandardGlobals*************************************************
*iefolder will not work properly if the line above is edited


*iefolder*3*RunDofiles**********************************************************
*iefolder will not work properly if the line above is edited

   * ******************************************************************** *
   *
   *       PART 3: - RUN DOFILES CALLED BY THIS MASTER DOFILE
   *
   *           - When survey rounds are added, this section will
   *            link to the master dofile for that round.
   *           - The default is that these dofiles are set to not
   *            run. It is rare that all round-specfic master dofiles
   *            are called at the same time; the round specific master
   *            dofiles are almost always called individually. The
   *            exception is when reviewing or replicating a full project.
   *
   * ******************************************************************** *


*iefolder*3*RunDofiles*Georeferencing*Georeferencing****************************
*iefolder will not work properly if the line above is edited

   if (0) { //Change the 0 to 1 to run the Georeferencing master dofile
       do "$Georeferencing/Georeferencing_MasterDofile.do" 
   }

*iefolder*3*End_RunDofiles******************************************************
*iefolder will not work properly if the line above is edited

