#!/bin/bash

# This script is used to setup the Home Assistant virtual machine and schedule the launch agent.

set -e
set -o pipefail

###############################################################################
# Setup Home Assistant VM
###############################################################################

echo "Setting up Home Assistant VM..."

# Create Virtual Machine using VirtualBox and Disk Image in ~/Developer/Virtual Machines/Disk Images

###############################################################################
# Setup Launch Agent
###############################################################################

# Load the launch agent
# TODO: Currently, this is saved to the /Developer/Scripts directory, but it should be gotten from iCloud. Upgrade hardware.
sh start-hass/load.sh

echo "Successfully setup Home Assistant VM."
exit 0