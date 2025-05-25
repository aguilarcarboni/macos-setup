#!/bin/bash

# This script is used to unload the Home Assistant launch agent.

set -e
set -o pipefail

###############################################################################
# Unload Home Assistant Launch Agent
###############################################################################

# Unload the launch agent
launchctl unload ~/Library/LaunchAgents/com.user.starthass.plist
rm ~/Library/LaunchAgents/com.user.starthass.plist

# Remove the script
rm -rf ~/Developer/Scripts/start-hass

# Check if the launch agent is loaded
launchctl list | grep starthass