#!/bin/bash

# This script is used to load the Home Assistant launch agent.

set -e
set -o pipefail

###############################################################################
# Load Home Assistant Launch Agent
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
START_HASS_DIR="$HOME/Developer/Scripts/start-hass"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"

if [[ -e "$LAUNCH_AGENTS_DIR" || -L "$LAUNCH_AGENTS_DIR" ]] && [[ ! -d "$LAUNCH_AGENTS_DIR" ]]; then
    BACKUP_PATH="${LAUNCH_AGENTS_DIR}.backup-$(date +%Y%m%d%H%M%S)"
    echo "Backing up conflicting LaunchAgents path to: $BACKUP_PATH"
    mv "$LAUNCH_AGENTS_DIR" "$BACKUP_PATH"
fi

mkdir -p "$START_HASS_DIR" "$LAUNCH_AGENTS_DIR"

# Copy the startup script and create a plist for the current user.
cp "$SCRIPT_DIR/start-hass.sh" "$START_HASS_DIR/start-hass.sh"
chmod 755 "$START_HASS_DIR/start-hass.sh"

# Load the launch agent in the current user's GUI launchd domain.
LAUNCH_AGENT="$HOME/Library/LaunchAgents/com.user.starthass.plist"
GUI_DOMAIN="gui/$(id -u)"

sed "s|/Users/aguilarcarboni|$HOME|g" "$SCRIPT_DIR/com.user.starthass.plist" > "$LAUNCH_AGENT"
chmod 644 "$LAUNCH_AGENT"
chown "$(id -un):$(id -gn)" "$LAUNCH_AGENT" "$START_HASS_DIR/start-hass.sh"

launchctl bootout "$GUI_DOMAIN/com.user.starthass" 2>/dev/null || true
launchctl remove com.user.starthass 2>/dev/null || true
launchctl bootstrap "$GUI_DOMAIN" "$LAUNCH_AGENT"

# Check if the launch agent is loaded.
launchctl print "$GUI_DOMAIN/com.user.starthass" >/dev/null
