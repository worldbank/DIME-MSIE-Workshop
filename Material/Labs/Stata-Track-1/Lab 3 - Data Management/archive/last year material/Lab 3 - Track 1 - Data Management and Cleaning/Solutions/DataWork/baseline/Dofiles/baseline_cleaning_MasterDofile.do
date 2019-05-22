   * ******************************************************************** *
   * ******************************************************************** *
   *                                                                      *
   *               BASELINE CLEANING MASTER DO_FILE                       *
   *               This master dofile calls all dofiles related           *
   *               to cleaning in the baseline round.                     *
   *                                                                      *
   * ******************************************************************** *
   * ******************************************************************** *

   ** IDS VAR:          list_ID_var_here         //Uniquely identifies households (update for your project)
   ** NOTES:
   ** WRITEN BY:        names_of_contributors
   ** Last date modified: 30 May 2017

   * ***************************************************** *
   *                                                       *
   * ***************************************************** *
   *
   *   cleaning dofile 1
   *
   *   The purpose of this dofiles is:
   *     (The list below are examples on what to include here)
   *      -what additional data sets does this file require
   *      -what variables are created
   *      -what corrections are made
   *
   * ***************************************************** *

       do "$baseline_doCln/load_imported_data.do" //Give your dofile a more informative name, this is just a place holder name

   * ***************************************************** *
   *
   *   cleaning dofile 2
   *
   *   The purpose of this dofiles is:
   *     (The list below are examples on what to include here)
   *      -what additional data sets does this file require
   *      -what variables are created
   *      -what corrections are made
   *
   * ***************************************************** *

       *do "$baseline_doCln/dofile2.do" //Give your dofile a more informative name, this is just a place holder name

   * ***************************************************** *
   *
   *   cleaning dofile 3
   *
   *   The purpose of this dofiles is:
   *     (The list below are examples on what to include here)
   *      -what additional data sets does this file require
   *      -what variables are created
   *      -what corrections are made
   *
   * ***************************************************** *

       *do "$baseline_doCln/dofile3.do" //Give your dofile a more informative name, this is just a place holder name

   * ************************************
   *   Keep adding sections for all additional dofiles needed
