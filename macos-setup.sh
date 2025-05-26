#!/bin/bash

# This script is used to setup a new macOS machine.

set -e
set -o pipefail

###############################################################################
# Ask type of machine
###############################################################################

read -p "Is this a server? (Y/n): " server
if [[ -z "${server}" || "${server}" =~ ^[Nn]$ ]]; then
    read -p "Is this a developer machine? (Y/n): " developer
else
    developer="N"
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

if [[ -z "${server}" || "${server}" =~ ^[Nn]$ ]]; then
    sh general/open-apps.sh
fi
sleep 1

fastfetch
exit 0