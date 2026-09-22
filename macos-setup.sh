#!/bin/bash

# This script is used to setup a new macOS machine.

set -e
set -o pipefail

###############################################################################
# Ask type of machine
###############################################################################

read -p "Is this a server? (Y/n): " server
if [[ -z "${server}" || "${server}" =~ ^[Yy]$ ]]; then
    server="Y"
    developer="N"
elif [[ "${server}" =~ ^[Nn]$ ]]; then
    server="N"
    read -p "Is this a developer machine? (Y/n): " developer
    if [[ -z "${developer}" || "${developer}" =~ ^[Yy]$ ]]; then
        developer="Y"
    elif [[ "${developer}" =~ ^[Nn]$ ]]; then
        developer="N"
    else
        echo "Error: Please answer Y or N."
        exit 1
    fi
else
    echo "Error: Please answer Y or N."
    exit 1
fi

###############################################################################
# Modify Settings
###############################################################################

sh general/modify-settings.sh "$server"
sleep 1

###############################################################################
# Ensure Settings
###############################################################################

sh general/ensure-setings.sh
sleep 1

###############################################################################
# Install Software
###############################################################################

sh general/install-software.sh "$server" "$developer"
sleep 1

###############################################################################
# Open Apps
###############################################################################

if [[ "${server}" =~ ^[Nn]$ ]]; then
    sh general/open-apps.sh
fi
sleep 1

fastfetch
exit 0
