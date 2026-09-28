#!/bin/bash
# postAttachCommand — runs each time a tool attaches to the container.
set -xo pipefail

# Activate the Python virtual environment baked into the Docker image
if [ -f /opt/venv/bin/activate ]; then
  source /opt/venv/bin/activate
fi
