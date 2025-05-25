launchctl unload ~/Library/LaunchAgents/com.user.starthass.plist
rm ~/Library/LaunchAgents/com.user.starthass.plist
launchctl list | grep starthass