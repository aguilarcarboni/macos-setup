#!/bin/bash

# This script is used to setup the Home Assistant virtual machine and schedule the launch agent.

set -e
set -o pipefail

###############################################################################
# Setup Home Assistant VM
###############################################################################

###############################################################################
# Setup Launch Agent
###############################################################################

sh start-hass/load.sh