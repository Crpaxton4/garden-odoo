#!/bin/bash
set -xo pipefail
################################################################################
# https://containers.dev/implementors/json_reference/
# initializeCommand
# >>> onCreateCommand
# updateContentCommand
# postCreateCommand
# postStartCommand
# postAttachCommand
#
# First of three commands that finalize container setup when a dev container is
# created. Executes inside the container immediately after it has started for
# the first time. No access to user-scoped secrets.
#
# Heavy lifting (system packages, Python venv, Node.js) is baked into the
# Dockerfile. This hook handles workspace-local setup only.
################################################################################

# Install Node.js dev dependencies (eslint, prettier, stylelint, etc.)
# Uses the npm cache already present in the Docker image for speed.
if [ -f package.json ]; then
  npm install
fi

# Install pre-commit hooks into the repo
if command -v pre-commit &>/dev/null; then
  pre-commit install
fi

# Configure Git to use LF endings
git config --global core.autocrlf input
git config --global core.eol lf

# Enable Odoo CLI auto-completion
echo "complete -W '$(odoo --help 2>/dev/null | \
  sed -e 's/[^a-z_-]\(-\+[a-z0-9_-]\+\)/\n\1\n/' | \
  grep -- '^-' | sort | uniq | tr '\n' ' ')' odoo" >> ~/.bash_completion

# Enable bash completion in .bashrc
cat << 'EOF' >> ~/.bashrc
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi
EOF
