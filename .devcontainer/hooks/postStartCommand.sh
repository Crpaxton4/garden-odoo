#!/bin/bash
set -xo pipefail
################################################################################
# https://containers.dev/implementors/json_reference/
# initializeCommand
# onCreateCommand
# updateContentCommand
# postCreateCommand
# >>> postStartCommand
# postAttachCommand
#
# Runs each time the container is successfully started.
################################################################################

ODOO_ADDONS_DIR="/usr/lib/python3/dist-packages/odoo/addons"

# Generate tsconfig.json for better JS/OWL editing in VS Code
# not available in odoo 19?
# odoo tsconfig \
#   --addons-path "/mnt/extra-addons,${ODOO_ADDONS_DIR}" \
#   > /mnt/extra-addons/tsconfig.json
