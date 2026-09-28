#!/bin/bash
set -xo pipefail
################################################################################
# https://containers.dev/implementors/json_reference/
# initializeCommand
# onCreateCommand
# updateContentCommand
# postCreateCommand
# postStartCommand
# >>> postAttachCommand
#
# Runs each time a tool has successfully attached to the container.
################################################################################

# Activate the Python virtual environment baked into the Docker image
if [ -f /opt/venv/bin/activate ]; then
  source /opt/venv/bin/activate
fi
