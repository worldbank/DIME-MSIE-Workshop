# Explanation to the root-folder-setup

All users who want to use this repository must set up a file called `root-folder-setup.do`. This file should be the only place where you write any identifying information like UPI or file/folder paths, or other information that can potentially be used maliciously such as network drive names. This file is ignored by the `.gitignored` file so that your information are not shown on GitHub.

Just copy the content in the code example below and save it in the same folder as this README.md file. Name your new file `root-folder-setup.do`. Then fill in the global file paths below. Far from all projects use all three folder paths, so in almost all cases it is expected that you leave some folder paths empty.

``` Stata

*To get the username from your Stata
di `c(username)'

*Add your username in the empty quote. If you are not sure of your username, then run this script and see the ouput from the line above
if `c(username)' == "" {

    *The top folder of this repo
    global repo         ""

    *Your OneDrive, DropBox folder etc.
    global syncedfolder ""

    *The folder for this project on a shared drive
    global networkdrive ""
}

*To make replication easier, run the replication do-file from hereg
do "${repo}/Material/Data/data-master-dofile.do"

```
