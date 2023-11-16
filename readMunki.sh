#!/bin/zsh


MUNKI_INSTALL_LOG="/Library/Managed Installs/Logs/Install.log"
MUNKI_MSU_LOG="/Library/Managed Installs/Logs/ManagedSoftwareUpdate.log"

tail -n 0 -f $MUNKI_MSU_LOG | while read LOGLINE
do
    if [[ "${LOGLINE}" == *"Installing"* ]]; then
        echo $LOGLINE
    fi
    if [[ "${LOGLINE}" == *"Ending managedsoftwareupdate run"* ]]; then
        pkill -P $$ tail
    fi
done
