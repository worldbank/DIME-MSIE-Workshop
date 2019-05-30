* User Number:
* You                     1    //Li
* Next User               2    //Anna

* Set this value to the user currently using this file
global user  2

* Root folder globals
* ---------------------
if (${user} == 1) {
    global projectfolder "C:/Users/user_li/Docuemnet/myProject"
}

if (${user} == 2) {
    global projectfolder "C:/Users/user_anna/Docuemnet/myProject"
}

* Project folder globals
* ---------------------
global dataWorkFolder         "$projectfolder/DataWork"
