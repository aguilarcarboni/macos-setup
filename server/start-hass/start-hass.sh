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

VBOXMANAGE="/Applications/VirtualBox.app/Contents/MacOS/VBoxManage"
VM_NAME="Home Assistant"

# Check if the VM "Home Assistant" is already running
if ! "$VBOXMANAGE" list runningvms | grep -q "\"$VM_NAME\""; then
    "$VBOXMANAGE" startvm "$VM_NAME" --type gui
fi

echo "Successfully started Home Assistant."