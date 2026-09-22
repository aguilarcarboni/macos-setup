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

# Load the launch agent in the current user's GUI launchd domain.
LAUNCH_AGENT="$HOME/Library/LaunchAgents/com.user.starthass.plist"
GUI_DOMAIN="gui/$(id -u)"

launchctl bootout "$GUI_DOMAIN" "$LAUNCH_AGENT" 2>/dev/null || true
launchctl bootstrap "$GUI_DOMAIN" "$LAUNCH_AGENT"

# Check if the launch agent is loaded.
launchctl print "$GUI_DOMAIN/com.user.starthass" >/dev/null
