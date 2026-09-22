#!/bin/bash

# This script installs Oracle VirtualBox directly on macOS.

set -e
set -o pipefail

echo "Installing VirtualBox..."

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

if command -v VBoxManage >/dev/null 2>&1 || [[ -x "/Applications/VirtualBox.app/Contents/MacOS/VBoxManage" ]]; then
    echo "VirtualBox is already installed."
    exit 0
fi

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

echo "Downloading Oracle VirtualBox ${VIRTUALBOX_VERSION}..."
curl --fail --location --retry 3 --retry-all-errors "$VIRTUALBOX_URL" -o "$VIRTUALBOX_DMG"
echo "$VIRTUALBOX_SHA256  $VIRTUALBOX_DMG" | shasum -a 256 -c -

VIRTUALBOX_MOUNT="$(hdiutil attach -nobrowse "$VIRTUALBOX_DMG" | sed -n 's#.*\(/Volumes/.*\)$#\1#p' | tail -n 1)"
if [[ -z "$VIRTUALBOX_MOUNT" || ! -f "$VIRTUALBOX_MOUNT/VirtualBox.pkg" ]]; then
    echo "Error: Could not find VirtualBox.pkg in the downloaded Oracle disk image." >&2
    exit 1
fi

sudo installer -pkg "$VIRTUALBOX_MOUNT/VirtualBox.pkg" -target /
hdiutil detach "$VIRTUALBOX_MOUNT" >/dev/null
VIRTUALBOX_MOUNT=""

echo "Successfully installed VirtualBox."
