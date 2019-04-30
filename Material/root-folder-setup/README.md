# Explanation to the root-folder-setup

All users who want to use this repository must set up a file called `root-folder-setup.do`. This file should be the only place where you write any identifying information like UPI or file/folder paths, or other information that can potentially be used maliciously such as network drive names. This file is ignored by the `.gitignored` file so that your information are not shown on GitHub.

Just copy the content in the code example below and save it in the same folder as this README.md file. Name your new file `root-folder-setup.do`. Then fill in the global file paths below. Far from all projects use all three folder paths, so in almost all cases it is expected that you leave some folder paths empty.

DO NOT DELETE empty folder paths, as if you are working on multiple projects, then it is much better that the code crashes, rather than you write output in the wrong project folder.

``` Stata

*To get the username from your Stata
di `c(username)'

*Add your username in the empty quote. If you are not sure
*what your username is, then run this script and see the
*output from the line above
if `c(username)' == "" {

    *The top folder of this repo
    global repo         ""

    *Your OneDrive, DropBox folder etc.
    global syncedfolder ""

    *The folder for this project on a shared network drive.
    *Even if this path is the same for everyone, it is more
    *secure to put it in this ignored file.
    global networkdrive ""
}

*To make replication easier, run the replication do-file from here
do "${repo}/Material/Data/data-master-dofile.do"

```
