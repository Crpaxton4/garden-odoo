#!/bin/bash
set -xo pipefail
################################################################################
# https://containers.dev/implementors/json_reference/
# initializeCommand
# onCreateCommand
# >>> updateContentCommand
# postCreateCommand
# postStartCommand
# postAttachCommand
#
# Second of three commands that finalize container setup. Executes inside the
# container after onCreateCommand whenever new content is available in the
# source tree during the creation process. Cloud services will periodically
# re-execute this command to refresh cached or prebuilt containers.
################################################################################
