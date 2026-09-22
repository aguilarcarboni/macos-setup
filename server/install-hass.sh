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

# Install VirtualBox directly from Oracle when it is not already available.
if [[ -z "$VBOXMANAGE" ]] && ! command -v VBoxManage >/dev/null 2>&1; then
    VIRTUALBOX_VERSION="7.1.18"
    VIRTUALBOX_BUILD="173720"
    case "$(uname -m)" in
        x86_64)
            VIRTUALBOX_FILENAME="VirtualBox-${VIRTUALBOX_VERSION}-${VIRTUALBOX_BUILD}-OSX.dmg"
            VIRTUALBOX_SHA256="174820ee0e3251c612439a907c3c1dac1d5e1f1c2fd27b17afdde1b400db2be5"
            ;;
        arm64)
            VIRTUALBOX_FILENAME="VirtualBox-${VIRTUALBOX_VERSION}-${VIRTUALBOX_BUILD}-macOSArm64.dmg"
            VIRTUALBOX_SHA256="145aab47e28a7b870eb5ad1070a6176aacaca390e8bc6952ef114fa283c16a4a"
            ;;
        *)
            echo "Error: Unsupported CPU architecture: $(uname -m)" >&2
            exit 1
            ;;
    esac

    VIRTUALBOX_URL="https://download.virtualbox.org/virtualbox/${VIRTUALBOX_VERSION}/${VIRTUALBOX_FILENAME}"
    VIRTUALBOX_TMPDIR="$(mktemp -d "${TMPDIR:-/tmp}/virtualbox.XXXXXX")"
    VIRTUALBOX_DMG="$VIRTUALBOX_TMPDIR/$VIRTUALBOX_FILENAME"
    VIRTUALBOX_MOUNT=""
    cleanup_virtualbox() {
        if [[ -n "$VIRTUALBOX_MOUNT" ]]; then
            hdiutil detach "$VIRTUALBOX_MOUNT" >/dev/null 2>&1 || true
        fi
        rm -rf "$VIRTUALBOX_TMPDIR"
    }
    trap cleanup_virtualbox EXIT

    echo "VirtualBox was not found. Downloading Oracle VirtualBox ${VIRTUALBOX_VERSION}..."
    curl -fL "$VIRTUALBOX_URL" -o "$VIRTUALBOX_DMG"
    echo "$VIRTUALBOX_SHA256  $VIRTUALBOX_DMG" | shasum -a 256 -c -

    VIRTUALBOX_MOUNT="$(hdiutil attach -nobrowse "$VIRTUALBOX_DMG" | sed -n 's#.*\(/Volumes/.*\)$#\1#p' | tail -n 1)"
    if [[ -z "$VIRTUALBOX_MOUNT" || ! -f "$VIRTUALBOX_MOUNT/VirtualBox.pkg" ]]; then
        echo "Error: Could not find VirtualBox.pkg in the downloaded Oracle disk image." >&2
        exit 1
    fi

    sudo installer -pkg "$VIRTUALBOX_MOUNT/VirtualBox.pkg" -target /
    hdiutil detach "$VIRTUALBOX_MOUNT" >/dev/null
    VIRTUALBOX_MOUNT=""
fi

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
    echo "VirtualBox VBoxManage was not found. Install VirtualBox before running this script." >&2
    exit 1
fi

if [[ -z "${BRIDGE_INTERFACE:-}" ]]; then
    DEFAULT_INTERFACE="$(route -n get default 2>/dev/null | awk '/interface:/{print $2}')"
    BRIDGED_INTERFACES="$("$VBOXMANAGE" list bridgedifs | awk -F': ' '/^Name:/{sub(/^[[:space:]]+/, "", $2); print $2}')"
    if [[ -n "$DEFAULT_INTERFACE" ]]; then
        BRIDGE_INTERFACE="$(printf '%s\n' "$BRIDGED_INTERFACES" | awk -v iface="$DEFAULT_INTERFACE" '$0 == iface || index($0, iface ":") == 1 {print; exit}')"
    fi
    if [[ -z "$BRIDGE_INTERFACE" ]]; then
        BRIDGE_INTERFACE="$(printf '%s\n' "$BRIDGED_INTERFACES" | sed -n '1p')"
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
