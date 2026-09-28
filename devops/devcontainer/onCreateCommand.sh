#!/bin/bash
# onCreateCommand — first lifecycle hook after the container is created.
# Heavy lifting (system packages, Python venv, Node.js) is baked into the
# Dockerfile. This hook handles workspace-local setup only.
set -xo pipefail

# This hook runs as the (non-root) remoteUser, remapped to the host UID.
# Paths that were created as root in the image or in a named volume must be
# handed to that user before anything below writes to them:
#   /var/lib/odoo   — odoo-data volume: data_dir, filestore, sessions. Odoo is
#                     started by the dev user in this container (no separate
#                     odoo service), so the dev user must own it.
#   /opt/npm-cache  — npm cache pre-warmed in the image as root.
# sudo is baked into the image for exactly this purpose; the shared Claude
# config mount is deliberately NOT touched here.
if [ "$(id -u)" -ne 0 ] && command -v sudo &>/dev/null; then
  for dir in /var/lib/odoo /opt/npm-cache; do
    if [ -d "$dir" ]; then
      sudo chown -R "$(id -u):$(id -g)" "$dir"
    fi
  done
  # Node/Claude live under a group-writable nvm prefix; join that group so
  # `claude update` and `npm i -g` keep working without root.
  if getent group nvm &>/dev/null; then
    sudo usermod -aG nvm "$(id -un)"
  fi
fi

# Install Node.js dev dependencies (eslint, prettier, stylelint, etc.)
# Uses the npm cache already present in the Docker image for speed.
if [ -f package.json ]; then
  npm install
fi

# The workspace is a bind mount owned by the host user. With the remoteUser
# remapped to the host UID this is normally a no-op, but CI checkouts and any
# UID mismatch still need the directory marked safe.
git config --global --add safe.directory "$(pwd)"

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
