   * ******************************************************************** *
   *
   *       SET UP STANDARDIZATION GLOBALS AND OTHER CONSTANTS
   *
   *           -Set globals used all across the projects
   *           -It is bad practice to define these at mutliple locations
   *
   * ******************************************************************** *

   * ******************************************************************** *
   * Set all conversion rates used in unit standardization 
   * ******************************************************************** *

   **Define all your conversion rates here instead of typing them each 
   * time you are converting amounts, for example - in unit standardization. 
   * We have already listed common conversion rates below, but you
   * might have to add rates specific to your project, or change the target 
   * unit if you are standardizing to other units than meters, hectares,
   * and kilograms.

   *Standardizing length to meters
       global foot     = 0.3048
       global mile     = 1609.34
       global km       = 1000
       global yard     = 0.9144
       global inch     = 0.0254

   *Standardizing area to hectares
       global sqfoot   = (1 / 107639)
       global sqmile   = (1 / 258.999)
       global sqmtr    = (1 / 10000)
       global sqkmtr   = (1 / 100)
       global acre     = 0.404686

   *Standardizing weight to kilorgrams
       global pound    = 0.453592
       global gram     = 0.001
       global impTon   = 1016.05
       global usTon    = 907.1874996
       global mtrTon   = 1000

   * ******************************************************************** *
   * Set global lists of variables
   * ******************************************************************** *

   **This is a good location to create lists of variables to be used at 
   * multiple locations across the project. Examples of such lists might 
   * be different list of controls to be used across multiple regressions. 
   * By defining these lists here, you can easliy make updates and have 
   * those updates being applied to all regressions without a large risk 
   * of copy and paste errors.

       *Control Variables
       *Example: global household_controls       income female_headed
       *Example: global country_controls         GDP inflation unemployment

   * ******************************************************************** *
   * Set custom ado file path
   * ******************************************************************** *

   **It is possible to control exactly which version of each command that 
   * is used in the project. This prevents that different versions in 
   * installed commands leads to different results.

   /*
       global ado      "$dataWorkFolder/your_ado_folder"
           adopath ++  "$ado" 
           adopath ++  "$ado/m" 
           adopath ++  "$ado/b" 
   */

   * ******************************************************************** *
   * Anything else
   * ******************************************************************** *

   **Everything that is constant may be included here. One example of
   * something not constant that should be included here is exchange
   * rates. It is best practice to have one global with the exchange rate
   * here, and reference this each time a currency conversion is done. If 
   * the currency exchange rate needs to be updated, then it only has to
   * be done at one place for the whole project.
