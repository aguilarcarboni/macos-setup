#!/bin/bash

# This script is used to start the Home Assistant VM.

set -e
set -o pipefail

###############################################################################
# Start Home Assistant
###############################################################################

# Ensure VirtualBox services are loaded by opening and closing VirtualBox
open -a VirtualBox

# Wait briefly to ensure services are initialized
sleep 5

# Close VirtualBox Manager GUI to avoid keeping it open
pkill -x VirtualBox

# Check if the VM "Home Assistant" is already running
if ! /Applications/VirtualBox.app/Contents/MacOS/VBoxManage list runningvms | grep -q "\"Home Assistant\""; then
    /Applications/VirtualBox.app/Contents/MacOS/VBoxManage startvm "Home Assistant" --type gui
fi

echo "Successfully started Home Assistant."
