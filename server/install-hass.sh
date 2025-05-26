#!/bin/bash

# This script is used to setup the Home Assistant virtual machine and schedule the launch agent.

set -e
set -o pipefail

###############################################################################
# Download the Disk Image
###############################################################################

echo "Installing Home Assistant..."

VERSION="15.2"

# Create Disk Images directory
mkdir -p ~/Developer/Virtual\ Machines/Disk\ Images
mkdir -p ~/Developer/Virtual\ Machines/Home\ Assistant
mkdir -p ~/Developer/Scripts

# Download the disk image
if [ ! -f "~/Developer/Virtual\ Machines/Disk\ Images/haos_ova-$VERSION.vdi.zip" ]; then
    curl -L "https://github.com/home-assistant/operating-system/releases/download/$VERSION/haos_ova-$VERSION.vdi.zip" -o ~/Developer/Virtual\ Machines/Disk\ Images/haos_ova-$VERSION.vdi.zip
fi

# Unzip the disk image
if [ ! -f "~/Developer/Virtual\ Machines/Disk\ Images/haos_ova-$VERSION.vdi" ]; then
    unzip ~/Developer/Virtual\ Machines/Disk\ Images/haos_ova-$VERSION.vdi.zip -d ~/Developer/Virtual\ Machines/Disk\ Images
fi

rm ~/Developer/Virtual\ Machines/Disk\ Images/haos_ova-$VERSION.vdi.zip

###############################################################################
# Setup Home Assistant VM
###############################################################################

echo "Setting up Home Assistant VM..."

VBOXMANAGE="/Applications/VirtualBox.app/Contents/MacOS/VBoxManage"
VM_NAME="Home Assistant"
VDI_PATH="$HOME/Developer/Virtual Machines/Disk Images/haos_ova-$VERSION.vdi"
VM_PATH="$HOME/Developer/Virtual Machines/Home Assistant"

# Check if the VM already exists
if ! "$VBOXMANAGE" list vms | grep -q "\"$VM_NAME\""; then
    # Create the VM
    "$VBOXMANAGE" createvm --name "$VM_NAME" --ostype "Oracle_64" --basefolder "$VM_PATH" --register
    # Set memory and CPU
    "$VBOXMANAGE" modifyvm "$VM_NAME" --memory 2048 --cpus 2 --firmware efi
    # Set network to bridged (default to en0:Wi-Fi, change if needed)
    "$VBOXMANAGE" modifyvm "$VM_NAME" --nic1 bridged --bridgeadapter1 en0
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
cd start-hass
sh load.sh

echo "Successfully installed Home Assistant VM."

exit 0