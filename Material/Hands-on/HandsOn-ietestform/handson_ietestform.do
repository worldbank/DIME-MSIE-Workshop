
*Install ietoolkit and iefieldkit if not already installed
    foreach command in ietoolkit iefieldkit {
        cap which `command'
        if _rc == 111 ssc install `command'
    }

*This excerices requires iefieldkit version 1.1 or more recent
    iefieldkit
    if `r(version)' < 1.2 adoupdate iefieldkit, update

*This excerices requires ietoolkit version 6.0 or more recent
    ietoolkit
    if `r(version)' < 6.0 adoupdate ietoolkit, update

*Use ieboilstart to set your boilerplate code
    ieboilstart, version(12)
    `r(version)'

**Replace the empty srting in `c(username)' == "" with your
* usernane. Type di `c(username)' to see the username in the
* Stata you are using
    if "`c(username)'" == "" {

    **Replace the empty string with the full path to folder
    * where you keep "ietestform-handson-session-cto-form.xls"
        global folder ""
    }

*Run the command
    ietestform, surveyform("${folder}\ietestform-handson-session-cto-form.xls") ///
		report("${folder}\report.csv")
