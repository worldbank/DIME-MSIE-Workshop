// This dofile sets up the folder structure for the entire Stata Labs Track 2.
// This file only needs to be run once.

  // Set the top-level directory to work in
  global directory "/Users/bbdaniels/Desktop/Stata-Track-2"

  // Initialize the new project
  iefolder new project , project("${directory}")

  // Create separate folders for each lab
  forvalues i = 2/7 { // Set up for all the labs
    iefolder new subfolder "Lab`i'", project("${directory}")
  }

  // Create README for all folders
  iegitaddmd , folder("${directory}") all skip

// Have a lovely day!
