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

VBOXMANAGE="${VBOXMANAGE:-}"
VM_NAME="Home Assistant"

if [[ -z "$VBOXMANAGE" ]] && command -v VBoxManage >/dev/null 2>&1; then
    VBOXMANAGE="$(command -v VBoxManage)"
fi
if [[ -z "$VBOXMANAGE" ]]; then
    for candidate in \
        "/Applications/VirtualBox.app/Contents/MacOS/VBoxManage" \
        "$HOME/Applications/VirtualBox.app/Contents/MacOS/VBoxManage" \
        "/usr/local/bin/VBoxManage"; do
        if [[ -x "$candidate" ]]; then
            VBOXMANAGE="$candidate"
            break
        fi
    done
fi
if [[ -z "$VBOXMANAGE" || ! -x "$VBOXMANAGE" ]]; then
    echo "VirtualBox VBoxManage was not found." >&2
    exit 1
fi

# Check if the VM "Home Assistant" is already running
if ! "$VBOXMANAGE" list runningvms | grep -q "\"$VM_NAME\""; then
    "$VBOXMANAGE" startvm "$VM_NAME" --type gui
fi

echo "Successfully started Home Assistant."
