* User Number:
* You                     1    //Kristoffer
* Next User               2    //Luiza

* Set this value to the user currently using this file
global user  1

* Root folder globals
* ---------------------
if (${user} == 1) {
    global projectfolder "C:/Users/kbrkb/Dropbox/MSIE-workshop/Material/Labs/Stata-Track-1"
}

if (${user} == 2) {
    global projectfolder "C:/Users/Luiza/Dropbox/MSIE-workshop/Material/Labs/Stata-Track-1"
}

* Project folder globals
* ---------------------
global dataWorkFolder         "$projectfolder/DataWork"
