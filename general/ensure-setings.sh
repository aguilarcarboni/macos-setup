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
appIcon="$fullPath/../dialog/settings.icns"
dialogTitle="System Settings"

# Source the reusable UserDialog functions
source "$fullPath/../dialog/user-dialog.sh"

# Settings Tabs
settings_tabs=(
    "Hostname ## x-apple.systempreferences:com.apple.SystemProfiler.AboutExtension"
    "Lock Screen ## x-apple.systempreferences:com.apple.Lock-Screen-Settings.extension"
    "Sharing ## x-apple.systempreferences:com.apple.Sharing-Settings.extension"
    "Battery ## x-apple.systempreferences:com.apple.Battery-Settings.extension"
    "Users and Groups ## x-apple.systempreferences:com.apple.Users-Groups-Settings.extension"
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
