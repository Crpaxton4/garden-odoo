#!/bin/bash
set -xo pipefail
################################################################################
# https://containers.dev/implementors/json_reference/
# initializeCommand
# onCreateCommand
# updateContentCommand
# >>> postCreateCommand
# postStartCommand
# postAttachCommand
#
# Last of three commands that finalize container setup. Happens after
# updateContentCommand and once the dev container has been assigned to a user
# for the first time. Can use user-scoped secrets and permissions.
################################################################################

# Initialize the Odoo database (creates tables, installs base module)
odoo -i base --stop-after-init

# Neutralize the dev database (disable outgoing email, cron jobs, etc.)
odoo neutralize
