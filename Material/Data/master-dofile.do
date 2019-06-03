/* ******************************************************************* *
* ******************************************************************** *

    This master do-file replicates all data and all solutions needed
    for the Managing Successful Impact Evaluations workshop (also known
    as the FC training).

    To replicate all files, set up your root folder in the section below
    and then run the file.

* ******************************************************************** *
* ******************************************************************* */

    ********************
    * Install user written commands

    *Loop over all needed commands
    local user_commands ietoolkit iefieldkit      //Fill this list will all user-written commands this project requires
    foreach command of local user_commands {

        *Check if already installed, if not, install it
        cap which `command'
        if _rc == 111 {
            ssc install `command'
        }
    }

    *Standardize settings accross users
    ieboilstart, version(12.1)      //Set the version number to the oldest version used by anyone in the project team
    `r(version)'                    //This line is needed to actually set the version from the command above


    * Root folder globals
    * ---------------------

    if "`c(username)'" == "kbrkb" {
        global MSIE_local_clone "C:\Users\kbrkb\Documents\GitHub\DIME-MSIE-Workshop"
    }

    if "`c(username)'" == "" {
        global MSIE_local_clone ""  //Enter the file path to the projectfolder of next user here
    }


    * Project folder globals
    * ---------------------

    global mtrl_fldr         "$MSIE_local_clone/Material"

    * ******************************************************************** *

    **This repo starts with the data used in the 2018 workshop
    * and then make edits as needed. The data master dofile takes
    * that data set and applies any changes needed to be done to
    * that data set as the labs keeps developing.
    do "$mtrl_fldr/Data/do-files/data-master-dofile.do"

	**This dofile copies the data files created above to each Stata
	* track. Then it runs all solutions do-files for each topic to
	* make sure that they all run, and that each topic correctly
	*builds on each other and that the results are correct.
    do "$mtrl_fldr/Data/do-files/labs-master-dofile.do"
