#!/bin/bash

# This script is used to load the Home Assistant launch agent.

set -e
set -o pipefail

###############################################################################
# Load Home Assistant Launch Agent
###############################################################################

# Copy start-hass.sh to ~/Developer/Scripts
mkdir -p ~/Developer/Scripts/start-hass/
cp start-hass.sh ~/Developer/Scripts/start-hass/

# Copy com.user.starthass.plist to ~/Library/LaunchAgents
cp com.user.starthass.plist ~/Library/LaunchAgents

# Load the launch agent
launchctl load ~/Library/LaunchAgents/com.user.starthass.plist

# Check if the launch agent is loaded
launchctl list | grep com.user.starthass
