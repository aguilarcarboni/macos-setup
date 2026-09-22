#!/bin/bash

# This script is used to setup the Home Assistant virtual machine and schedule the launch agent.

set -e
set -o pipefail

###############################################################################
# Download the Disk Image
###############################################################################

echo "Installing Home Assistant..."

VERSION="15.2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VM_PATH="$HOME/Developer/Virtual Machines"
DISK_IMAGES_PATH="$VM_PATH/Disk Images"
ZIP_PATH="$DISK_IMAGES_PATH/haos_ova-$VERSION.vdi.zip"
VDI_PATH="$DISK_IMAGES_PATH/haos_ova-$VERSION.vdi"

# Create Disk Images directory
mkdir -p "$DISK_IMAGES_PATH" "$VM_PATH/Home Assistant" "$HOME/Developer/Scripts"

# Download the disk image
if [[ ! -f "$ZIP_PATH" && ! -f "$VDI_PATH" ]]; then
    curl -L "https://github.com/home-assistant/operating-system/releases/download/$VERSION/haos_ova-$VERSION.vdi.zip" -o "$ZIP_PATH"
fi

# Unzip the disk image
if [[ ! -f "$VDI_PATH" ]]; then
    unzip "$ZIP_PATH" -d "$DISK_IMAGES_PATH"
fi

if [[ -f "$ZIP_PATH" ]]; then
    rm "$ZIP_PATH"
fi

###############################################################################
# Setup Home Assistant VM
###############################################################################

echo "Setting up Home Assistant VM..."

VBOXMANAGE="${VBOXMANAGE:-}"
VM_NAME="Home Assistant"

# Find VBoxManage regardless of how VirtualBox was installed.
if [[ -z "$VBOXMANAGE" ]] && command -v VBoxManage >/dev/null 2>&1; then
    VBOXMANAGE="$(command -v VBoxManage)"
fi
if [[ -z "$VBOXMANAGE" ]]; then
    for candidate in \
        "/Applications/VirtualBox.app/Contents/MacOS/VBoxManage" \
        "$HOME/Applications/VirtualBox.app/Contents/MacOS/VBoxManage" \
        "/usr/local/bin/VBoxManage" \
        "/opt/homebrew/bin/VBoxManage"; do
        if [[ -x "$candidate" ]]; then
            VBOXMANAGE="$candidate"
            break
        fi
    done
fi
if [[ -z "$VBOXMANAGE" ]] && command -v mdfind >/dev/null 2>&1; then
    VBOXMANAGE="$(mdfind 'kMDItemFSName == "VBoxManage"c' | head -n 1)"
fi
if [[ -z "$VBOXMANAGE" || ! -x "$VBOXMANAGE" ]]; then
    echo "VirtualBox VBoxManage was not found. Install VirtualBox or set VBOXMANAGE to its executable path." >&2
    exit 1
fi

BRIDGE_INTERFACE="${BRIDGE_INTERFACE:-$(route -n get default 2>/dev/null | awk '/interface:/{print $2}')}"
BRIDGE_INTERFACE="${BRIDGE_INTERFACE:-en0}"

# Check if the VM already exists
if ! "$VBOXMANAGE" list vms | grep -q "\"$VM_NAME\""; then
    # Create the VM
    "$VBOXMANAGE" createvm --name "$VM_NAME" --ostype "Oracle_64" --basefolder "$VM_PATH" --register
    # Set memory and CPU
    "$VBOXMANAGE" modifyvm "$VM_NAME" --memory 2048 --cpus 2 --firmware efi
    # Set network to bridged using the active default interface.
    "$VBOXMANAGE" modifyvm "$VM_NAME" --nic1 bridged --bridgeadapter1 "$BRIDGE_INTERFACE"
    # Create SATA controller
    "$VBOXMANAGE" storagectl "$VM_NAME" --name "SATA" --add sata --controller IntelAhci
    # Attach the VDI disk
    "$VBOXMANAGE" storageattach "$VM_NAME" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "$VDI_PATH"
    # Enable discard/trim and non-rotational (SSD)
    "$VBOXMANAGE" storageattach "$VM_NAME" --storagectl "SATA" --port 0 --device 0 --nonrotational on --discard on

else
    echo "VM '$VM_NAME' already exists. Skipping creation."
fi

###############################################################################
# Setup Launch Agent
###############################################################################

# Load the launch agent
# TODO: Currently, this is saved to the /Developer/Scripts directory, but it should be gotten from iCloud. Upgrade hardware.
cd "$SCRIPT_DIR/start-hass"
sh load.sh

echo "Successfully installed Home Assistant VM."

exit 0
