   * ******************************************************************** *
   * ******************************************************************** *
   *                                                                      *
   *               your_round_name                                        *
   *               MASTER DO_FILE                                         *
   *                                                                      *
   * ******************************************************************** *
   * ******************************************************************** *

       /*
       ** PURPOSE:      Write intro to survey round here

       ** OUTLINE:      PART 0: Standardize settings and install packages
                        PART 1: Preparing folder path globals
                        PART 2: Run the master do files for each high level task

       ** IDS VAR:      list_ID_var_here         //Uniquely identifies households (update for your project)

       ** NOTES:

       ** WRITEN BY:    names_of_contributors

       ** Last date modified: 14 Jun 2018
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
   local user_commands ietoolkit iefieldkit      //Fill this list will all commands this project requires
   foreach command of local user_commands {
       cap which `command'
       if (_rc == 111) {
           cap ssc install `command'
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
   global user  1

   * Root folder globals
   * ---------------------

   if (${user} == 1) {
       global projectfolder "C:/Users/kbrkb/Dropbox/MSIE-workshop/Material/Labs/Stata-Track-1"
   }

   if (${user} == 2) {
       global projectfolder ""  //Enter the file path to the projectfolder of next user here
   }

*These lines are used to test that name ois not already used (do not edit manually)

   * Project folder globals
   * ---------------------

   global dataWorkFolder         "$projectfolder/DataWork"

*iefolder*1*FolderGlobals*ST1**********************************************
*iefolder will not work properly if the line above is edited


   *Round sub-folder globals
   global ST1               "${dataWorkFolder}/ST1"

   *Encrypted round sub-folder globals
   global ST1_encrypt       "${ST1_encrypt}/Raw Identified Data"
   global ST1_dtRaw         "${ST1_encrypt}/Raw Identified Data"
   global ST1_doImp         "${ST1_encrypt}/Dofiles Import"
   global ST1_HFC           "${ST1_encrypt}/High Frequency Checks"

   *DataSets sub-folder globals
   global ST1_dt            "${ST1}/DataSets"
   global ST1_dtDeID        "${ST1_dt}/Deidentified"
   global ST1_dtInt         "${ST1_dt}/Intermediate"
   global ST1_dtFin         "${ST1_dt}/Final"

   *Dofile sub-folder globals
   global ST1_do            "${ST1}/Dofiles"
   global ST1_doCln         "${ST1_do}/Cleaning"
   global ST1_doCon         "${ST1_do}/Construct"
   global ST1_doAnl         "${ST1_do}/Analysis"

   *Output sub-folder globals
   global ST1_out           "${ST1}/Output"
   global ST1_outRaw        "${ST1_out}/Raw"
   global ST1_outFin        "${ST1_out}/Final"

   *Questionnaire sub-folder globals
   global ST1_prld          "${ST1_quest}/PreloadData"
   global ST1_doc           "${ST1_quest}/Questionnaire Documentation"

*iefolder*1*End_FolderGlobals***************************************************
*iefolder will not work properly if the line above is edited

*iefolder*3*RunDofiles**********************************************************
*iefolder will not work properly if the line above is edited

   * ******************************************************************** *
   *
   *       PART 3: - RUN DOFILES CALLED BY THIS MASTER DO FILE
   *
   *           -A task master dofile has been created for each high
   *            level task (cleaning, construct, analyze). By
   *            running all of them all data work associated with the
   *            ST1 should be replicated, including output of
   *            tablets, graphs, etc.
   *           -Feel free to add to this list if you have other high
   *            level tasks relevant to your project.
   *
   * ******************************************************************** *

   **Set the locals corresponding to the taks you want
   * run to 1. To not run a task, set the local to 0.
   local topic1    0

   if (`topic1' == 1) { //Change the local above to run or not to run this file
       do "${ST1_do}/"
   }

*iefolder*3*End_RunDofiles******************************************************
*iefolder will not work properly if the line above is edited
