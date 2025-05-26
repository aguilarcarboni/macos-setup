#!/bin/bash

# This script is used to programatically set the settings for macOS.

set -e
set -o pipefail

################################################################################
# Script Setup                                                                 
################################################################################

echo "Modifying MacOS settings..."

# Get 'server' from positional arguments, or default to 'N'
server="${1:-}"

if [[ -z "$server" ]]; then
    echo "Error: 'server' argument must be provided."
    echo "Usage: $0 <server>"
    exit 1
fi

# Create a symlink to the iCloud documents folder

# Check if the ~/iCloud symlink already exists first, if it does dont create it
if [ -L "~/iCloud" ]; then
    echo "iCloud symlink already exists."
else
    ln -s ~/Library/Mobile\ Documents/com~apple~CloudDocs ~/iCloud
fi

# Close any open System Preferences panes
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
# Store the keep-alive PID so we can kill it in the cleanup function
sudo -n true
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
KEEP_ALIVE_PID=$!

# Cleanup function to kill the keep-alive loop
cleanup() {
    kill -0 $KEEP_ALIVE_PID 2>/dev/null && kill $KEEP_ALIVE_PID
}

# Register the cleanup function to run when the script exits
trap cleanup EXIT

################################################################################
# General                                                                 
################################################################################

# Show hostname in login window
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

################################################################################
# System Settings > Wi-Fi                                                                 
################################################################################

################################################################################
# System Settings > Bluetooth                                                                 
################################################################################

################################################################################
# System Settings > Network                                                                 
################################################################################

################################################################################
# System Settings > Battery                                                                 
################################################################################

# Enable sleep
sudo pmset -a disablesleep 0

# Never sleep on power adapter or UPS
sudo pmset -c sleep 0
sudo pmset -u sleep 0

# Sleep on battery after 10 minutes
sudo pmset -b sleep 10

# Sleep the display after 10 minutes
# You must configure screen saver settings in System Settings > Screen Saver
sudo pmset -a displaysleep 10

# Disable Power Nap
sudo pmset -a powernap 0

# Enable lid wake
sudo pmset -a lidwake 1

if [[ -z "${server}" || "${server}" =~ ^[Yy]$ ]]; then

    # Never sleep disks
    sudo pmset -a disksleep 0

    # Set auto restart on power loss
    sudo pmset -a autorestart 1

    # Keep tcp connections alive
    sudo pmset -a tcpkeepalive 1
    
    # Wake on Magic Packet from LAN
    sudo pmset -a womp 1

    # Wake on Ring/Bell from Modem
    sudo pmset -a ring 1

else

    # Never sleep disks
    sudo pmset -a disksleep 30

    # Set auto restart on power loss
    sudo pmset -a autorestart 0

    # Keep tcp connections alive
    sudo pmset -a tcpkeepalive 0
    
    # Wake on Magic Packet from LAN
    sudo pmset -a womp 0

    # Wake on Ring/Bell from Modem
    sudo pmset -a ring 0

fi


################################################################################
# System Settings > General                                                                 
################################################################################

################################################################################
# System Settings > General > Language & Region
################################################################################

# Set Language to English
defaults write -g AppleLanguages -array en-US

# Use Metric Units
defaults write -g AppleMetricUnits -bool true

# Set Locale
defaults write -g AppleLocale -string "en_US@currency=USD"

# Use centimeters for measurements
defaults write -g AppleMeasurementUnits -string "Centimeters"

# Use Celcius for measurements
defaults write -g AppleTemperatureUnit -string "Celsius"

# Set date and time format
defaults write NSGlobalDomain AppleICUDateFormatStrings -dict-add 1 "d/M/y"

################################################################################
# System Settings > General >Sharing
################################################################################

# Disable Screen Sharing
if sudo launchctl list | grep -q "com.apple.screensharing"; then
    sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.screensharing.plist
fi

# Disable Remote Login
if sudo launchctl list | grep -q "com.openssh.sshd"; then
    sudo launchctl unload -w /System/Library/LaunchDaemons/ssh.plist
fi

# Disable File Sharing
if sudo launchctl list | grep -q "com.apple.AppleFileServer"; then
    sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist
fi

# Disable SMB
if sudo launchctl list | grep -q "com.apple.smbd"; then
    sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.smbd.plist
fi

if [[ -z "${server}" || "${server}" =~ ^[Yy]$ ]]; then

    # Enable Screen Sharing
    sudo defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.screensharing -dict Disabled -bool false
    sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist

    # Enable Remote Login
    sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist

    # Enable File Sharing
    sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist

    # Enable SMB
    sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.smbd.plist
fi

################################################################################
# System Settings > Accessibility                                                                 
################################################################################

# Enable Speaking
defaults write com.apple.Accessibility SpeakThisEnabled -bool true

# Enable Accessibility
defaults write com.apple.Accessibility AccessibilityEnabled -bool true
defaults write com.apple.Accessibility ApplicationAccessibilityEnabled -bool true

################################################################################
# Appearance                                                                 
################################################################################

# Appearance: Dark
defaults write -globalDomain AppleInterfaceStyle -string "Dark"
defaults write -globalDomain AppleAccentColor -int 9

# Sidebar Size: Small
defaults write NSGlobalDomain "NSTableViewDefaultSizeMode" -int 1

# Show scroll bars when scrolling
defaults write NSGlobalDomain AppleShowScrollBars -string "WhenScrolling"

################################################################################
# System Settings > Apple Intelligence & Siri
################################################################################

# Enable Apple Intelligence & Siri
defaults write com.apple.CloudSubscriptionFeatures.optIn "545129924" -bool true

################################################################################
# System Settings > Control Center                                                                 
################################################################################

# Control Center Modules > WiFi > Show in Menu Bar
defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -int 1

# Control Center Modules > Bluetooth > Show in Menu Bar
defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -int 1
defaults write com.apple.controlcenter "NSStatusItem Preferred Position Bluetooth" -int 303

# Control Center Modules > Focus > Show in Menu Bar
defaults write "com.apple.controlcenter" "NSStatusItem Visible FocusModes" -int 1
defaults write com.apple.controlcenter "NSStatusItem Preferred Position FocusModes" -int 328

# Control Center Modules > Sound > Show in Menu Bar
defaults write "com.apple.controlcenter" "NSStatusItem Visible Sound" -int 1
defaults write com.apple.controlcenter "NSStatusItem Preferred Position Sound" -int 282

# Control Center Modules > User Switcher > Show in Menu Bar
defaults write com.apple.controlcenter "NSStatusItem Visible UserSwitcher" -int 1
defaults write com.apple.controlcenter "NSStatusItem Preferred Position UserSwitcher" -int 296

# Menu Bar Only > Clock Options
defaults write "com.apple.menuextra.clock" ShowAMPM -bool true
defaults write "com.apple.menuextra.clock" ShowDate -bool true
defaults write "com.apple.menuextra.clock" ShowDayOfWeek -bool true

# Menu Bar Only > Spotlight > Don't Show in Menu Bar
defaults -currentHost write com.apple.Spotlight MenuItemHidden -int 1

# Menu Bar Only > Siri > Show in Menu Bar
defaults write com.apple.Siri StatusMenuVisible -int 1

################################################################################
# System Settings > Desktop & Dock                                                                 
################################################################################

# Dock > Size:
defaults write com.apple.dock tilesize -int 40

# Dock > Magnification
defaults write com.apple.dock largesize -int 60
defaults write com.apple.dock magnification -bool true

# Dock > Minimize windows using: Scale effect
defaults write com.apple.dock mineffect -string "genie"

# Dock > Minimize windows into application icon
defaults write com.apple.dock minimize-to-application -bool false

# Dock > Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Dock > Automatically hide and show the Dock (duration)
defaults write com.apple.dock autohide-time-modifier -float 0.4

# Dock > Automatically hide and show the Dock (delay)
defaults write com.apple.dock autohide-delay -float 0

# Show recent applications in Dock
defaults write com.apple.dock "show-recents" -bool false

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true

# Desktop & Stage Manager > Click Wallpaper to reveal desktop > Yes
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool true
defaults write com.apple.WindowManager EnableTilingByEdgeDrag -bool true
defaults write com.apple.WindowManager EnableTilingOptionAccelerator -bool true
defaults write com.apple.WindowManager EnableTopTilingByEdgeDrag -bool true

if [[ -z "${server}" || "${server}" =~ ^[Yy]$ ]]; then
    defaults write com.apple.dock "static-only" -bool true
else
    defaults write com.apple.dock "static-only" -bool false
fi

# Hot corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# 13: Lock Screen

# Top left screen corner
defaults write com.apple.dock wvous-tl-corner -int 0
defaults write com.apple.dock wvous-tl-modifier -int 0

# Top right screen corner
defaults write com.apple.dock wvous-tr-corner -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0

# Bottom left screen corner
defaults write com.apple.dock wvous-bl-corner -int 0
defaults write com.apple.dock wvous-bl-modifier -int 0

# Bottom right screen corner
defaults write com.apple.dock wvous-br-corner -int 0
defaults write com.apple.dock wvous-br-modifier -int 0

################################################################################
# System Settings > Displays                                                                 
################################################################################

################################################################################
# System Settings > Screen Saver                                                                 
################################################################################

################################################################################
# System Settings > Spotlight                                                                 
################################################################################

################################################################################
# System Settings > Wallpaper                                                                 
################################################################################

################################################################################
# System Settings > Notifications                                                                 
################################################################################

################################################################################
# System Settings > Sound                                                                 
################################################################################

# Increase sound quality for Bluetooth headphones/headsets
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

################################################################################
# System Settings > Focus                                                                 
################################################################################

################################################################################
# System Settings > Screen Time                                                                 
################################################################################

################################################################################
# System Settings > Lock Screen                                                                 
################################################################################

# Sleep the display after 10 minutes
sudo pmset -a displaysleep 10

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

################################################################################
# System Settings > Privacy & Security                                                                 
################################################################################

################################################################################
# System Settings > Touch ID & Password                                                                 
################################################################################

################################################################################
# System Settings > Users & Groups                                                                 
################################################################################

################################################################################
# System Settings > Internet Accounts                                                                 
################################################################################

################################################################################
# System Settings > Game Center                                                                 
################################################################################

################################################################################
# System Settings > iCloud                                                                 
################################################################################

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

################################################################################
# System Settings > Wallet & Apple Pay
################################################################################

################################################################################
# System Settings > Keyboard                                                                 
################################################################################

# Enable press and hold for keys
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool true

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable smart dashes as they're annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Show language indicator
defaults write kCFPreferencesAnyApplication TSMLanguageIndicatorEnabled -bool true

################################################################################
# System Settings > Trackpad                                                                 
################################################################################

# Tap To Click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# Enable Multitouch Clicking
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

# Enable Corner Secondary Click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

# Pointer Control > Trackpad Options > Dragging Style: Three Finger Drag
defaults write com.apple.AppleMultitouchTrackpad Dragging -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

# Pointer Control > Trackpad Options > Disable Cursor Location Magnification
defaults write NSGlobalDomain CGDisableCursorLocationMagnification -int 0

################################################################################
# System Settings > Printers & Scanners                                                                 
################################################################################

################################################################################
# Screenshots                                                               
################################################################################

# Save screenshots to Desktop
defaults write com.apple.screencapture location -string "~/Desktop"

# Save screenshots as PNG
defaults write com.apple.screencapture type -string "png"

# Disable shadow
defaults write com.apple.screencapture disable-shadow -bool false

# Show thumbnail
defaults write com.apple.screencapture "show-thumbnail" -bool "true"

################################################################################
# Finder                                                                 
################################################################################

# Show the ~/Library folder
chflags nohidden ~/Library

# Finder > View > Show View Options > Show Path Bar
defaults write com.apple.finder "ShowPathbar" -bool true

# Finder > View > Show View Options > List View
defaults write com.apple.finder "FXPreferredViewStyle" -string "clmv"

# Finder > View > Show View Options > Show Status Bar
defaults write com.apple.finder ShowStatusBar -bool false

# Finder > New Window > Target > Desktop
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

# Finder > Sort Folders First
defaults write com.apple.finder "_FXSortFoldersFirst" -bool true

# Finder > Show External Hard Drives On Desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

# Finder > Show Hard Drives On Desktop
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false

# Finder > Show Mounted Servers On Desktop
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true

# Finder > Show Removable Media On Desktop
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Finder > Show All Files
defaults write com.apple.finder AppleShowAllFiles -bool false

# Finder > Default Search Scope > Current Folder
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Finder > Desktop Services > Don't Write Network Stores
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Finder > Desktop Services > Don't Write USB Stores
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Finder > Sidebar > Devices > Show
defaults write com.apple.finder SidebarDevicesSectionDisclosedState -int 1

# Finder > Sidebar > Places > Show
defaults write com.apple.finder SidebarPlacesSectionDisclosedState -int 1

# Finder > Sidebar > iCloud > Show
defaults write com.apple.finder SidebarShowingSignedIntoiCloud -int 1
defaults write com.apple.finder SidebarShowingiCloudDesktop -int 0
defaults write com.apple.finder SidebariCloudDriveSectionDisclosedState -int 1

# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Set Finder keyboard shortcut to open new terminal at folder using CMD + Shift + T
defaults write com.apple.finder NSUserKeyEquivalents -dict-add "New Terminal at Folder" "@\$t"

################################################################################
# Photos                                                                 
################################################################################

# Disable Hot Plug
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

################################################################################
# Mac App Store                                                                 
################################################################################

# App Store
defaults write com.apple.appstore WebKitDeveloperExtras -bool true
defaults write com.apple.appstore ShowDebugMenu -bool true

# Set App Store to automatically check for updates
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Set App Store to automatically download updates on a daily basis
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Set App Store to automatically download updates in the background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Enable Auto Update
defaults write com.apple.commerce AutoUpdate -bool true

################################################################################
# Time Machine                                                                 
################################################################################

# Don't Offer New Disks For Backup
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

################################################################################
# Terminal                                                                 
################################################################################

defaults write com.apple.terminal StringEncodings -array 4
defaults write com.apple.terminal SecureKeyboardEntry -bool true
defaults write com.apple.Terminal ShowLineMarks -int 0

################################################################################
# Activity Monitor                                                                 
################################################################################

defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Edit Icon Type
defaults write com.apple.ActivityMonitor IconType -int 1
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Sort by CPU Usage
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

################################################################################
# TextEdit                                                                 
################################################################################

# Disable Rich Text
defaults write com.apple.TextEdit RichText -int 0

################################################################################
# QuickTime Player                                                                 
################################################################################

#
defaults write com.apple.QuickTimePlayerX MGPlayMovieOnOpen -bool true

################################################################################
# Music                                                                 
################################################################################

# Disable playback notifications
defaults write com.apple.Music "userWantsPlaybackNotifications" -bool "false"

echo "Successfully modified macOS settings."
exit 0

# TODO:
# Setup airplay reciever and handoff
# Setup mouse wheel
# Keyboard shortcuts
# Safari settings
# Mail settings