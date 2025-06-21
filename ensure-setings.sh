#!/bin/bash

# This script is used to open certain windows of the System Settings app to ensure the settings are set.

set -e
set -o pipefail

################################################################################
# Open System Settings                                                                
################################################################################

echo "Ensuring settings are correct..."

# Create Dialog
fullPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
appIcon="/Users/aguilarcarboni/Library/Mobile Documents/com~apple~CloudDocs/Personal/Developer/Repositories/macos-setup/dialog/settings.icns"
dialogTitle="System Settings"

# Source the reusable UserDialog functions
source "/Users/aguilarcarboni/Library/Mobile Documents/com~apple~CloudDocs/Personal/Developer/Repositories/macos-setup/dialog/user-dialog.sh"

# Settings Tabs
settings_tabs=(
    "Hostname ## x-apple.systempreferences:com.apple.SystemProfiler.AboutExtension"
    "Spoken Content ## x-apple.systempreferences:com.apple.preference.universalaccess?SpokenContent"
    "Display Accessibility ## x-apple.systempreferences:com.apple.preference.universalaccess?Seeing_Display"
    "Control Center ## x-apple.systempreferences:com.apple.ControlCenter-Settings.extension"
    "Displays ## x-apple.systempreferences:com.apple.Displays-Settings.extension"
    "Wallpaper ## x-apple.systempreferences:com.apple.Wallpaper-Settings.extension"
    "Lock Screen ## x-apple.systempreferences:com.apple.Lock-Screen-Settings.extension"
    "Apple ID (iCloud) ## x-apple.systempreferences:com.apple.preferences.AppleIDPrefPane?iCloud"
    "Wallet ## x-apple.systempreferences:com.apple.WalletSettingsExtension"
    "Internet Accounts ## x-apple.systempreferences:com.apple.Internet-Accounts-Settings.extension"
    "Privacy - Advertising ## x-apple.systempreferences:com.apple.preference.security?Privacy_Advertising"
    "Privacy - Analytics ## x-apple.systempreferences:com.apple.preference.security?Privacy_Analytics"
)

# Open settings tabs
for tab in "${settings_tabs[@]}"; do
    # Split on '##' to get label and URL
    tabLabel="${tab%%##*}"
    tabUrl="${tab#*##}"
    # Trim whitespace
    tabLabel="$(echo "$tabLabel" | xargs)"
    tabUrl="$(echo "$tabUrl" | xargs)"

    # Set dialog message
    dialogMessage="Please ensure your $tabLabel settings are correct."

    # Show the dialog
    show_user_dialog "$dialogTitle" "$dialogMessage" "$appIcon"

    # Open the settings tab
    open "$tabUrl"

    # Wait for System Settings (Ventura+) or System Preferences (Monterey and earlier) to close
    while pgrep -x "System Settings" > /dev/null || pgrep -x "System Preferences" > /dev/null; do
        sleep 1
    done

done

echo "Successfully ensured settings are correct."
exit 0