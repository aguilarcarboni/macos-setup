#!/bin/bash

# This script is used to open Applications that were installed during setup that require more setup.

set -e
set -o pipefail

###############################################################################
# Open Applications
###############################################################################

echo "Opening applications..."

open -a "Wipr"
open -a "QLMarkdown"

echo "Successfully opened applications."
exit 0
