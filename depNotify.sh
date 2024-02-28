#!/bin/bash

# Testing Mode
#########################################################################################
# Testing flag will enable the following things to change:
# Auto removal of BOM files to reduce errors
# Sleep commands instead of policies or other changes being called
# Quit Key set to command + control + x
  TESTING_MODE=true # Set variable to true or false

#########################################################################################
# General Appearance
#########################################################################################
# Flag the app to open fullscreen or as a window
  FULLSCREEN=false # Set variable to true or false

# Banner image can be 600px wide by 100px high. Images will be scaled to fit
# If this variable is left blank, the generic image will appear. If using custom Self
# Service branding, please see the Customized Self Service Branding area below
  BANNER_IMAGE_PATH="/Applications/Self Service.app/Contents/Resources/AppIcon.icns"

# Update the variable below replacing "Organization" with the actual name of your organization. Example "ACME Corp Inc."
  ORG_NAME="University of Basel"

# Main heading that will be displayed under the image
# If this variable is left blank, the generic banner will appear
  BANNER_TITLE="Welcome to $ORG_NAME"
	
# Update the variable below replacing "email helpdesk@company.com" with the actual plaintext instructions for your organization. Example "call 555-1212" or "email helpdesk@company.com"
  SUPPORT_CONTACT_DETAILS="email support-its@unibas.ch"

# Onboarding Video URLs
  VIDEO_URL_DE="WTfpzZzUTw8"
  VIDEO_URL_EN="A-eGjyG5SBk"
  
# Paragraph text that will display under the main heading. For a new line, use \n
# If this variable is left blank, the generic message will appear. Leave single
# quotes below as double quotes will break the new lines.
  MAIN_TEXT='Thanks for choosing a Mac at '$ORG_NAME'! We want you to have a few applications and settings configured before you get started with your new Mac. This process should take 10 to 20 minutes to complete. \n \n If you need additional software or help, please visit the Self Service app in your Applications folder or on your Dock.'

# Initial Start Status text that shows as things are firing up
  INITAL_START_STATUS="Initial Configuration Starting..."

# Text that will display in the progress bar
  INSTALL_COMPLETE_TEXT="Configuration Complete!"

# Complete messaging to the end user can ether be a button at the bottom of the
# app with a modification to the main window text or a dropdown alert box. Default
# value set to false and will use buttons instead of dropdown messages.
  COMPLETE_METHOD_DROPDOWN_ALERT=false # Set variable to true or false

# Script designed to automatically logout user to start FileVault process if
# deferred enablement is detected. Text displayed if deferred status is on.
  # Option for dropdown alert box
    FV_ALERT_TEXT="Your Mac must logout to start the encryption process. You will be asked to enter your password and click OK or Continue a few times. Your Mac will be usable while encryption takes place."
  # Options if not using dropdown alert box
    FV_COMPLETE_MAIN_TEXT='Your Mac must logout to start the encryption process. You will be asked to enter your password and click OK or Continue a few times. Your Mac will be usable while encryption takes place.'
    FV_COMPLETE_BUTTON_TEXT="Logout"

# Text that will display inside the alert once policies have finished
  # Option for dropdown alert box
    COMPLETE_ALERT_TEXT="Your Mac is now finished with initial setup and configuration. Press Quit to get started!"
  # Options if not using dropdown alert box
    COMPLETE_MAIN_TEXT='Your Mac is now finished with initial setup and configuration.'
    COMPLETE_BUTTON_TEXT="Get Started!"

#########################################################################################
# Plist Configuration
#########################################################################################
# The menu.depnotify.plist contains more and more things that configure the DEPNotify app
# You may want to save the file for purposes like verifying EULA acceptance or validating
# other options.

# Plist Save Location
  # This wrapper allows variables that are created later to be used but also allow for
  # configuration of where the plist is stored
    INFO_PLIST_WRAPPER (){
      DEP_NOTIFY_USER_INPUT_PLIST="/Users/$CURRENT_USER/Library/Preferences/menu.nomad.DEPNotifyUserInput.plist"
    }

# Status Text Alignment
  # The status text under the progress bar can be configured to be left, right, or center
    STATUS_TEXT_ALIGN="center"

# Help Button Configuration
  # The help button was changed to a popup. Button will appear if title is populated.
    HELP_BUBBLE_TITLE="Need Help?"
    HELP_BUBBLE_BODY="This tool at $ORG_NAME is designed to help with new employee onboarding. If you have issues, please $SUPPORT_CONTACT_DETAILS"

#########################################################################################
# Error Screen Text
#########################################################################################
# If testing mode is false and configuration files are present, this text will appear to
# the end user and asking them to contact IT. Limited window options here as the
# assumption is that they need to call IT. No continue or exit buttons will show for
# DEP Notify window and it will not show in fullscreen. IT staff will need to use Terminal
# or Activity Monitor to kill DEP Notify.

# Main heading that will be displayed under the image
  ERROR_BANNER_TITLE="Uh oh, Something Needs Fixing!"

# Paragraph text that will display under the main heading. For a new line, use \n
# If this variable is left blank, the generic message will appear. Leave single
# quotes below as double quotes will break the new lines.
	ERROR_MAIN_TEXT='We are sorry that you are experiencing this inconvenience with your new Mac. However, we have the nerds to get you back up and running in no time! \n \n Please contact IT right away and we will take a look at your computer ASAP. \n \n'	
	ERROR_MAIN_TEXT="$ERROR_MAIN_TEXT $SUPPORT_CONTACT_DETAILS"	
	  
# Error status message that is displayed under the progress bar
  ERROR_STATUS="Setup Failed"

#########################################################################################
#########################################################################################
# Core Script Logic - Don't Change Without Major Testing
#########################################################################################
#########################################################################################

# https://developer.apple.com/library/archive/documentation/LanguagesUtilities/Conceptual/MacAutomationScriptingGuide/DisplayNotifications.html
# Is user using en or de locale? Use english as default
  userlang=$(defaults read -g AppleLocale) 
  userlang=${userlang:0:2}

# Display popup with title and description
  if [ "$userlang" = "de" ]; then
	  VIDEO_URL = $VIDEO_URL_DE
  else
	  VIDEO_URL = $VIDEO_URL_EN
  fi


# Variables for File Paths
  JAMF_BINARY="/usr/local/bin/jamf"
  FDE_SETUP_BINARY="/usr/bin/fdesetup"
  DEP_NOTIFY_APP="/Applications/Utilities/DEPNotify.app"
  DEP_NOTIFY_LOG="/var/tmp/depnotify.log"
  DEP_NOTIFY_DEBUG="/var/tmp/depnotifyDebug.log"
  DEP_NOTIFY_DONE="/var/tmp/com.depnotify.provisioning.done"

# Standard Testing Mode Enhancements
  if [ "$TESTING_MODE" = true ]; then
    # Removing old config file if present (Testing Mode Only)
      if [ -f "$DEP_NOTIFY_LOG" ]; then rm "$DEP_NOTIFY_LOG"; fi
      if [ -f "$DEP_NOTIFY_DONE" ]; then rm "$DEP_NOTIFY_DONE"; fi
      if [ -f "$DEP_NOTIFY_DEBUG" ]; then rm "$DEP_NOTIFY_DEBUG"; fi
      sleep 0.1
  fi
 

# Validating true/false flags
  if [ "$TESTING_MODE" != true ] && [ "$TESTING_MODE" != false ]; then
    echo "$(date "+%a %h %d %H:%M:%S"): Testing configuration not set properly. Currently set to $TESTING_MODE. Please update to true or false." >> "$DEP_NOTIFY_DEBUG"
    exit 1
  fi
  if [ "$FULLSCREEN" != true ] && [ "$FULLSCREEN" != false ]; then
    echo "$(date "+%a %h %d %H:%M:%S"): Fullscreen configuration not set properly. Currently set to $FULLSCREEN. Please update to true or false." >> "$DEP_NOTIFY_DEBUG"
    exit 1
  fi


# Run DEP Notify will run after Apple Setup Assistant
  SETUP_ASSISTANT_PROCESS=$(pgrep -l "Setup Assistant")
  until [ "$SETUP_ASSISTANT_PROCESS" = "" ]; do
    echo "$(date "+%a %h %d %H:%M:%S"): Setup Assistant Still Running. PID $SETUP_ASSISTANT_PROCESS." >> "$DEP_NOTIFY_DEBUG"
    sleep 1
    SETUP_ASSISTANT_PROCESS=$(pgrep -l "Setup Assistant")
  done


# Checking to see if the Finder is running now before continuing. This can help
# in scenarios where an end user is not configuring the device.
  FINDER_PROCESS=$(pgrep -l "Finder")
  until [ "$FINDER_PROCESS" != "" ]; do
    echo "$(date "+%a %h %d %H:%M:%S"): Finder process not found. Assuming device is at login screen." >> "$DEP_NOTIFY_DEBUG"
    sleep 1
    FINDER_PROCESS=$(pgrep -l "Finder")
  done


# After the Apple Setup completed. Now safe to grab the current user and user ID
  CURRENT_USER=$(/usr/bin/stat -f "%Su" /dev/console)
  CURRENT_USER_ID=$(id -u $CURRENT_USER)
  echo "$(date "+%a %h %d %H:%M:%S"): Current user set to $CURRENT_USER (id: $CURRENT_USER_ID)." >> "$DEP_NOTIFY_DEBUG"

 
# Adding Check and Warning if Testing Mode is off and BOM files exist
  if [[ ( -f "$DEP_NOTIFY_LOG" || -f "$DEP_NOTIFY_DONE" ) && "$TESTING_MODE" = false ]]; then
    echo "$(date "+%a %h %d %H:%M:%S"): TESTING_MODE set to false but config files were found in /var/tmp. Letting user know and exiting." >> "$DEP_NOTIFY_DEBUG"
    mv "$DEP_NOTIFY_LOG" "/var/tmp/depnotify_old.log"
    echo "Command: MainTitle: $ERROR_BANNER_TITLE" >> "$DEP_NOTIFY_LOG"
    echo "Command: MainText: $ERROR_MAIN_TEXT" >> "$DEP_NOTIFY_LOG"
    echo "Status: $ERROR_STATUS" >> "$DEP_NOTIFY_LOG"
    launchctl asuser $CURRENT_USER_ID open -a "$DEP_NOTIFY_APP" --args -path "$DEP_NOTIFY_LOG"
    sleep 5
    exit 1
  fi


# Setting Quit Key set to command + control + x
  echo "Command: QuitKey: x" >> "$DEP_NOTIFY_LOG"

# Setting custom image if specified
  if [ "$BANNER_IMAGE_PATH" != "" ]; then  echo "Command: Image: $BANNER_IMAGE_PATH" >> "$DEP_NOTIFY_LOG"; fi


# Setting custom title if specified
  if [ "$BANNER_TITLE" != "" ]; then echo "Command: MainTitle: $BANNER_TITLE" >> "$DEP_NOTIFY_LOG"; fi


# Setting custom main text if specified
  if [ "$MAIN_TEXT" != "" ]; then echo "Command: MainText: $MAIN_TEXT" >> "$DEP_NOTIFY_LOG"; fi


# Opening the app after initial configuration
  if [ "$FULLSCREEN" = true ]; then
    launchctl asuser $CURRENT_USER_ID open -a "$DEP_NOTIFY_APP" --args -path "$DEP_NOTIFY_LOG" -fullScreen
  elif [ "$FULLSCREEN" = false ]; then
    launchctl asuser $CURRENT_USER_ID open -a "$DEP_NOTIFY_APP" --args -path "$DEP_NOTIFY_LOG"
  fi

# Grabbing the DEP Notify Process ID for use later
  DEP_NOTIFY_PROCESS=$(pgrep -l "DEPNotify" | cut -d " " -f1)
  until [ "$DEP_NOTIFY_PROCESS" != "" ]; do
    echo "$(date "+%a %h %d %H:%M:%S"): Waiting for DEPNotify to start to gather the process ID." >> "$DEP_NOTIFY_DEBUG"
    sleep 1
    DEP_NOTIFY_PROCESS=$(pgrep -l "DEPNotify" | cut -d " " -f1)
  done

# Adding an alert prompt to let admins know that the script is in testing mode
  if [ "$TESTING_MODE" = true ]; then
    echo "Command: Alert: DEP Notify is in TESTING_MODE. Script will not run Policies or other commands that make change to this computer."  >> "$DEP_NOTIFY_LOG"
  fi

# Display video
  echo "Command: YouTube: $VIDEO_URL" >> "$DEP_NOTIFY_LOG"

# Adding nice text and a brief pause for prettiness
  echo "Status: $INITAL_START_STATUS" >> "$DEP_NOTIFY_LOG"
  #sleep 5


exit 0
