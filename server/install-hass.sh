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

# This setup script is intended for fresh installations. Do not reuse a prior
# archive or disk image.
rm -f "$ZIP_PATH" "$VDI_PATH"

# Remove an incomplete archive left by an interrupted download.
if [[ -f "$ZIP_PATH" ]] && ! unzip -tq "$ZIP_PATH" >/dev/null 2>&1; then
    echo "Removing incomplete Home Assistant disk image archive."
    rm -f "$ZIP_PATH"
fi

# Download the disk image.
if [[ ! -f "$ZIP_PATH" && ! -f "$VDI_PATH" ]]; then
    curl --fail --location --retry 3 --retry-all-errors \
        "https://github.com/home-assistant/operating-system/releases/download/$VERSION/haos_ova-$VERSION.vdi.zip" \
        -o "$ZIP_PATH"
fi

# Unzip the disk image.
if [[ ! -f "$VDI_PATH" ]]; then
    unzip -tq "$ZIP_PATH" >/dev/null
    unzip "$ZIP_PATH" -d "$DISK_IMAGES_PATH"
fi

[[ -f "$ZIP_PATH" ]] && rm "$ZIP_PATH"

###############################################################################
# Setup Home Assistant VM
###############################################################################

echo "Setting up Home Assistant VM..."

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
    echo "VirtualBox VBoxManage was not found. Run server/install-virtualbox.sh first." >&2
    exit 1
fi

echo "Resetting the Home Assistant VM for a clean install."
if "$VBOXMANAGE" list vms | grep -q "\"$VM_NAME\""; then
    "$VBOXMANAGE" unregistervm "$VM_NAME" --delete
fi
rm -rf "$VM_PATH/Home Assistant"

if [[ -z "${BRIDGE_INTERFACE:-}" ]]; then
    DEFAULT_INTERFACE="$(route -n get default 2>/dev/null | awk '/interface:/{print $2}')"
    BRIDGED_INTERFACES="$("$VBOXMANAGE" list bridgedifs | awk -F': ' '/^Name:/{sub(/^[[:space:]]+/, "", $2); print $2}')"
    while IFS= read -r candidate; do
        [[ -z "$candidate" ]] && continue
        candidate_interface="${candidate%%:*}"
        if [[ "$candidate_interface" == "$DEFAULT_INTERFACE" ]] && ifconfig "$candidate_interface" >/dev/null 2>&1; then
            hardware_port="$(networksetup -listallhardwareports 2>/dev/null | awk -v iface="$candidate_interface" '
                /^Hardware Port:/ {port=$0; sub(/^Hardware Port: /, "", port)}
                /^Device:/ && $2 == iface {print port; exit}')"
            BRIDGE_INTERFACE="$candidate"
            [[ "$candidate" == "$candidate_interface" && -n "$hardware_port" ]] && BRIDGE_INTERFACE="$candidate_interface: $hardware_port"
            break
        fi
    done <<< "$BRIDGED_INTERFACES"
    if [[ -z "$BRIDGE_INTERFACE" ]]; then
        while IFS= read -r candidate; do
            [[ -z "$candidate" ]] && continue
            candidate_interface="${candidate%%:*}"
            if ifconfig "$candidate_interface" >/dev/null 2>&1; then
                BRIDGE_INTERFACE="$candidate"
                break
            fi
        done <<< "$BRIDGED_INTERFACES"
    fi
fi
if [[ -z "${BRIDGE_INTERFACE:-}" ]]; then
    echo "Error: VirtualBox found no bridged network interfaces." >&2
    "$VBOXMANAGE" list bridgedifs >&2
    exit 1
fi

echo "Using network interface: $BRIDGE_INTERFACE"

# Check if the VM already exists
if ! "$VBOXMANAGE" list vms | grep -q "\"$VM_NAME\""; then
    # Create the VM
    "$VBOXMANAGE" createvm --name "$VM_NAME" --ostype "Oracle_64" --basefolder "$VM_PATH" --register
    # Set memory and CPU
    "$VBOXMANAGE" modifyvm "$VM_NAME" --memory 2048 --cpus 2 --firmware efi
    # Create SATA controller
    "$VBOXMANAGE" storagectl "$VM_NAME" --name "SATA" --add sata --controller IntelAhci
    # Attach the VDI disk
    "$VBOXMANAGE" storageattach "$VM_NAME" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "$VDI_PATH"
    # Enable discard/trim and non-rotational (SSD)
    "$VBOXMANAGE" storageattach "$VM_NAME" --storagectl "SATA" --port 0 --device 0 --nonrotational on --discard on

else
    echo "VM '$VM_NAME' already exists. Skipping creation."
fi

# Apply the current network interface even when the VM was created previously.
"$VBOXMANAGE" modifyvm "$VM_NAME" --nic1 bridged --bridgeadapter1 "$BRIDGE_INTERFACE"

###############################################################################
# Setup Launch Agent
###############################################################################

# Load the launch agent
# TODO: Currently, this is saved to the /Developer/Scripts directory, but it should be gotten from iCloud. Upgrade hardware.
cd "$SCRIPT_DIR/start-hass"
sh load.sh

echo "Successfully installed Home Assistant VM."

exit 0
