cp com.user.starthass.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/com.user.starthass.plist
launchctl list | grep com.user.starthass
