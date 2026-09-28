#!/bin/bash
# postCreateCommand — runs once after onCreateCommand, with user-scoped access.
set -xo pipefail

# Initialize the Odoo database (creates tables, installs base module)
odoo -i base --stop-after-init

# Neutralize the dev database (disable outgoing email, cron jobs, etc.)
odoo neutralize
