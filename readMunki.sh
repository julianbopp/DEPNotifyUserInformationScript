#!/bin/zsh

MUNKI_INSTALL_LOG="/Library/Managed Installs/Logs/Install.log"
DEP_NOTIFY_LOG="/var/tmp/depnotify.log"

# Make sure directories and log file exist
mkdir -p "/Library/Managed Installs/Logs"
touch $MUNKI_MSU_LOG

echo "Running managedsoftwareupdate"
/usr/local/munki/managedsoftwareupdate &

tail -n 1 -f "$MUNKI_MSU_LOG" | while read LOGLINE
do
	echo "HELLO" >> "Users/test/test.txt"
    if ([[ "${LOGLINE}" == *"Installing"* ]] || [[ "${LOGLINE}" == *"Downloading"* ]]) && [[ "${LOGLINE}" != *" at "* ]] && [[ "${LOGLINE}" != *" from "* ]]; then
        echo "Status: ${LOGLINE:27}" >> $DEP_NOTIFY_LOG
    fi
    if [[ "${LOGLINE}" == *"Ending managedsoftwareupdate run"* ]]; then
    	echo "Ending managedsoftwareupdate run"
    	echo "Running managedsoftwareupdate --installonly"
    	/usr/local/munki/managedsoftwareupdate --installonly &
    fi
    if [[ "${LOGLINE}" == *"End managed installer session"* ]]; then
    	echo "End managed installer session"
        echo "Telling DEPNotify that software installs are done"
        echo "Command: ${LOGLINE:27}" >> $DEP_NOTIFY_LOG
        pkill -P $$ tail
            echo "Command: DeterminateManual: 0" >> $DEP_NOTIFY_LOG
            echo "Status: Setup Complete! " >> $DEP_NOTIFY_LOG  
            echo "Command: ContinueButton: Get Started!" >> $DEP_NOTIFY_LOG
    fi
done