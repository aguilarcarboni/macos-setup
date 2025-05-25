osVer="$(sw_vers -productVersion)"
currentUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
uid=$(id -u "$currentUser")

# Create Dialog
appPath="/Applications/System Preferences.app"
appName="Settings"
appIcon="/Applications/System Preferences.app/Contents/Resources/ScreenCapture.icns"
dialogTitle="Settings"
dialogMessage="Set your nightshift settings."
dialogPath="/usr/local/bin/dialog"
dialogApp="/Library/Application Support/Dialog/Dialog.app"

UserDialog (){

  #First check if the app icon exists
  if [ -e "$appIcon" ]; then
    iconCMD=(--icon "$appIcon")
  else
    #If the icon file doesn't exist, set an empty array to omit from dialogs.
    iconCMD=()
  fi

  if [ -e "$appIcon" ]; then
    echo "Icon found"
    /usr/bin/osascript -e 'display dialog "'"$dialogMessage"'" with title "'"$dialogTitle"'" with icon POSIX file "'"$appIcon"'" buttons {"Okay"} default button 1 giving up after 15'
  #No Kandji, no SwiftDialog, and no appicon. Use osascript.
  else
    echo "No icon found"
     /usr/bin/osascript -e 'display dialog "'"$dialogMessage"'" with title "'"$dialogTitle"'" buttons {"Okay"} default button 1 giving up after 15'
  fi
}

UserDialog

# Nightshift
open x-apple.systempreferences:com.apple.Displays-Settings.extension

# Wait for System Settings to close
while pgrep -x "System Settings" > /dev/null; do
    sleep 1
done


exit 0