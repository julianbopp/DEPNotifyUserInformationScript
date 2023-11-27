#!/bin/bash


MUNKI_INSTALL_LOG="/Library/Managed Installs/Logs/Install.log"
MUNKI_MSU_LOG="/Library/Managed Installs/Logs/ManagedSoftwareUpdate.log"

tail -n 0 -f "$MUNKI_MSU_LOG" | while read LOGLINE
do
    if [[ "${LOGLINE}" == *"Installing"* ]]; then
        echo "Status: ${LOGLINE:27}" >> /var/tmp/depnotify.log
    fi
    if [[ "${LOGLINE}" == *"End managed installer session"* ]]; then
        echo "Command: ${LOGLINE:27}" >> /var/tmp/depnotify.log
        pkill -P $$ tail
            echo "Command: DeterminateManual: 0" >> /var/tmp/depnotify.log
            echo "Status: Setup Complete! " >> /var/tmp/depnotify.log  
            echo "Command: ContinueButton: Get Started!" >> /var/tmp/depnotify.log
    fi
done
