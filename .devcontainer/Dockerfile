# garden-odoo development container
# Based on the official Odoo 19.0 community image.
# Bakes in system packages, Node.js, Python dev tools, and npm cache
# so onCreateCommand only runs lightweight workspace-local setup.
#
# Build context: repository root (context: .. in compose.yml)
#
# ── Base image inventory (odoo:19.0) ────────────────────────────────────────
# Source: https://github.com/odoo/docker/blob/master/19.0/Dockerfile
# OS:     Ubuntu Noble (24.04)
# System: ca-certificates, curl, dirmngr, fonts-noto-cjk, gnupg, libssl-dev,
#         node-less, npm, xz-utils
# Python: python3-magic, python3-num2words, python3-odf, python3-pdfminer,
#         python3-pip, python3-phonenumbers, python3-pyldap, python3-qrcode,
#         python3-renderpm, python3-setuptools, python3-slugify, python3-vobject,
#         python3-watchdog, python3-xlrd, python3-xlwt
# PDF:    wkhtmltopdf 0.12.6.1
# DB:     postgresql-client (pgdg — latest available for Noble)
# JS:     rtlcss (npm global)
# CLI:    gh (GitHub CLI)
# Odoo:   19.0 nightly .deb (includes all Odoo Python deps)
# Env:    ODOO_VERSION=19.0, ODOO_RC=/etc/odoo/odoo.conf
# Vols:   /var/lib/odoo, /mnt/extra-addons
FROM odoo:19.0

USER root

# ── 1. System packages (rarely change) ──────────────────────────────────────
# Grouped install + cleanup in a single layer to minimise image size.
# NOTE: postgresql-client, curl, npm are already in the base image.
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends -qq \
        bash-completion \
        git \
        python3-ipython \
        python3-virtualenv \
    # GitHub CLI
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update -qq \
    && apt-get install -y --no-install-recommends -qq gh \
    && rm -rf /var/lib/apt/lists/*

# ── 2. Node.js 22 LTS (rarely changes) ──────────────────────────────────────
# Install from NodeSource; clean up apt lists in same layer.
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && apt-mark manual nodejs \
    && rm -rf /var/lib/apt/lists/*

# ── 3. Python virtual environment + dev dependencies ────────────────────────
# Venv lives at /opt/venv (outside workspace mount) so it survives bind mounts.
# --system-site-packages gives access to Odoo's installed Python packages.
COPY requirements-dev.txt /tmp/requirements-dev.txt
RUN virtualenv --system-site-packages /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir \
        pydevd-odoo \
        -r /tmp/requirements-dev.txt \
    && rm /tmp/requirements-dev.txt

ENV PATH="/opt/venv/bin:$PATH"

# ── 4. npm cache pre-warm (changes with package.json) ───────────────────────
# Install once to populate the npm cache inside the image, then discard the
# node_modules — the real install happens in the workspace at create-time.
COPY package.json /tmp/npm-cache-seed/package.json
RUN cd /tmp/npm-cache-seed \
    && npm install --ignore-scripts \
    && rm -rf /tmp/npm-cache-seed

# ── 5. Odoo CLI shebang patch ───────────────────────────────────────────────
# Point the system odoo executable at the venv Python so CLI and debugger
# run inside the virtualenv.
RUN sed -i '1s|^#!.*python3|#!/opt/venv/bin/python|' /usr/bin/odoo
