#!/bin/bash

# This script is used to open certain windows of the System Settings app to ensure the settings are set.

set -e
set -o pipefail

################################################################################
# Open System Settings                                                                
################################################################################

echo "Ensuring settings are correct..."

# Create Dialog
appIcon="/Applications/System Preferences.app/Contents/Resources/ScreenCapture.icns"
dialogTitle="Settings"

# Source the reusable UserDialog functions
source "/Users/aguilarcarboni/Library/Mobile Documents/com~apple~CloudDocs/Personal/Developer/Repositories/macos-setup/dialog/user-dialog.sh"

# Note: Remove trailing commas from each URL. Some URLs may not work on all macOS versions (especially Ventura and newer).
settings_tabs=(
    x-apple.systempreferences:com.apple.SystemProfiler.AboutExtension
    x-apple.systempreferences:com.apple.preference.universalaccess?SpokenContent
    x-apple.systempreferences:com.apple.preference.universalaccess?Seeing_Display
    x-apple.systempreferences:com.apple.ControlCenter-Settings.extension
    x-apple.systempreferences:com.apple.Displays-Settings.extension
    x-apple.systempreferences:com.apple.Wallpaper-Settings.extension
    x-apple.systempreferences:com.apple.Lock-Screen-Settings.extension
    x-apple.systempreferences:com.apple.preferences.AppleIDPrefPane?iCloud
    x-apple.systempreferences:com.apple.WalletSettingsExtension
    x-apple.systempreferences:com.apple.Internet-Accounts-Settings.extension
    x-apple.systempreferences:com.apple.preference.security?Privacy_Advertising
    x-apple.systempreferences:com.apple.preference.security?Privacy_Analytics
)

# Open settings tabs
for tab in "${settings_tabs[@]}"; do

    # Get the dialog message from the tab name
    dialogMessage="Set your ${tab##*?} settings."

    # Show the dialog
    show_user_dialog "$dialogTitle" "$dialogMessage" "$appIcon"

    # Open the settings tab
    open "$tab"

    # Wait for System Settings (Ventura+) or System Preferences (Monterey and earlier) to close
    while pgrep -x "System Settings" > /dev/null || pgrep -x "System Preferences" > /dev/null; do
        sleep 1
    done

done

exit 0