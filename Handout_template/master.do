
* This code is written directly in the master.do file

  * Set the top-level directory to work in
  global directory "/Users/stataexpert99/Desktop/DIMEresources"

  * Initialize the new project
  iefolder new project , project("${directory}")

  * Create separate folders for each lab
  forvalues i = 1/6 { // Set up for all the labs
    iefolder new subfolder "Lab`i'", project("${directory}")
  }

  * Create README for all folders
  iegitaddmd , folder("${directory}") all skip

* Have a lovely day!
