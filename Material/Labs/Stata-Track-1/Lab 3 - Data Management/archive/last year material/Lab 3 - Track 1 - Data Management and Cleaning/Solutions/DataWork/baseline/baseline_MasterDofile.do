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
   *       PART 1:  PREPARING BASELINE FOLDER PATH GLOBALS
   *
   *           -Set global to point to the baseline folders
   *           -Add to these globals as you need
   *
   * ******************************************************************** *

   *Encrypted round sub-folder globals
   global baseline_encrypt       "$encryptFolder/baseline Encrypted Data" 
   global baseline_dtRaw         "$baseline_encrypt/Raw Identified Data" 
   global baseline_doImp         "$baseline_encrypt/Dofiles Import" 

   *DataSets sub-folder globals
   global baseline_dtInt         "$baseline_dt/Intermediate" 
   global baseline_dtFin         "$baseline_dt/Final" 

   *Dofile sub-folder globals
   global baseline_doCln         "$baseline_do/Cleaning" 
   global baseline_doCon         "$baseline_do/Construct" 
   global baseline_doAnl         "$baseline_do/Analysis" 

   *Output sub-folder globals
   global baseline_outRaw        "$baseline_out/Raw" 
   global baseline_outFin        "$baseline_out/Final" 

   *Questionnaire sub-folder globals
   global baseline_prld          "$baseline_quest/PreloadData" 
   global baseline_doc           "$baseline_quest/Questionnaire Documentation" 

*iefolder*1*End_FolderGlobals***************************************************
*iefolder will not work properly if the line above is edited


*iefolder*2*RunDofiles**********************************************************
*iefolder will not work properly if the line above is edited

   * ******************************************************************** *
   *
   *       PART 2: - RUN DOFILES CALLED BY THIS MASTER DO FILE
   *
   *           -A task master dofile has been created for each high
   *            level task (cleaning, construct, analyze). By 
   *            running all of them all data work associated with the 
   *            baseline should be replicated, including output of 
   *            tablets, graphs, etc.
   *           -Feel free to add to this list if you have other high
   *            level tasks relevant to your project.
   *
   * ******************************************************************** *

   **Set the locals corresponding to the taks you want
   * run to 1. To not run a task, set the local to 0.
   local cleaningDo     1
   local constructDo    1
   local analysisDo     1

   if (`cleaningDo' == 1) { //Change the local above to run or not to run this file
       do "$baseline_do/baseline_cleaning_MasterDofile.do" 
   }

   if (`constructDo' == 1) { //Change the local above to run or not to run this file
       do "$baseline_do/baseline_construct_MasterDofile.do" 
   }

   if (`analysisDo' == 1) { //Change the local above to run or not to run this file
       do "$baseline_do/baseline_analysis_MasterDofile.do" 
   }

*iefolder*2*End_RunDofiles******************************************************
*iefolder will not work properly if the line above is edited

