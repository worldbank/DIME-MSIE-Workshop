   * ******************************************************************** *
   * ******************************************************************** *
   *                                                                      *
   *               GEOREFERENCING CLEANING MASTER DO_FILE                 *
   *               This master dofile calls all dofiles related           *
   *               to cleaning in the Georeferencing round.               *
   *                                                                      *
   * ******************************************************************** *
   * ******************************************************************** *

   ** IDS VAR:          list_ID_var_here         // Uniquely identifies households (update for your project)
   ** NOTES:
   ** WRITTEN BY:       names_of_contributors
   ** Last date modified:  7 Jun 2019


   * ***************************************************** *
   *                                                       *
   * ***************************************************** *
   *
   *   cleaning dofile 1
   *
   *   The purpose of this dofiles is:
   *     (The ideas below are examples on what to include here)
   *      - what additional data sets does this file require
   *      - what variables are created
   *      - what corrections are made
   *
   * ***************************************************** *

       *do "$Georeferencing_doCln/dofile1.do" //Give your dofile a more informative name, this is just a placeholder name

   * ***************************************************** *
   *
   *   cleaning dofile 2
   *
   *   The purpose of this dofiles is:
   *     (The ideas below are examples on what to include here)
   *      - what additional data sets does this file require
   *      - what variables are created
   *      - what corrections are made
   *
   * ***************************************************** *

       *do "$Georeferencing_doCln/dofile2.do" //Give your dofile a more informative name, this is just a placeholder name

   * ***************************************************** *
   *
   *   cleaning dofile 3
   *
   *   The purpose of this dofiles is:
   *     (The ideas below are examples on what to include here)
   *      - what additional data sets does this file require
   *      - what variables are created
   *      - what corrections are made
   *
   * ***************************************************** *

       *do "$Georeferencing_doCln/dofile3.do" //Give your dofile a more informative name, this is just a placeholder name

   * ************************************
   *   Keep adding sections for all additional dofiles needed
