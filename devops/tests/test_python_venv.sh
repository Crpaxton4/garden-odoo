#!/usr/bin/env bash
# test_python_venv.sh — Verify the Python virtualenv is correctly configured.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "$(dirname "$0")/helpers.sh"

suite_header "Python Virtualenv"

# Venv binary exists and is executable
assert_file_exists /opt/venv/bin/python "/opt/venv/bin/python exists"
assert_file_executable /opt/venv/bin/python "/opt/venv/bin/python is executable"

# which python3 resolves inside venv
python3_path=$(which python3 2>/dev/null || true)
if [[ "$python3_path" == /opt/venv/bin/* ]]; then
    pass "python3 resolves inside venv ($python3_path)"
else
    fail "python3 resolves inside venv (got: $python3_path)"
fi

# System site-packages accessible (can import odoo)
assert_python_import odoo "system site-packages: 'import odoo' works"

# Odoo CLI shebang points to venv python
odoo_shebang=$(head -1 /usr/bin/odoo 2>/dev/null || echo "")
if echo "$odoo_shebang" | grep -q '/opt/venv/bin/python'; then
    pass "odoo CLI shebang points to venv python"
else
    fail "odoo CLI shebang points to venv python (got: $odoo_shebang)"
fi

# All requirements-dev.txt packages are installed
suite_header "Python Virtualenv: requirements-dev.txt packages"

REQUIREMENTS_FILE="${REPO_ROOT}/requirements-dev.txt"
if [[ -f "$REQUIREMENTS_FILE" ]]; then
    pip_list=$(pip list --format=freeze 2>/dev/null | tr '[:upper:]' '[:lower:]')
    while IFS= read -r line; do
        # Skip comments and blank lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// /}" ]] && continue
        # Extract package name (before any version specifier)
        pkg=$(echo "$line" | sed -E 's/[>=<\[!].*//' | tr '[:upper:]' '[:lower:]')
        # pip normalizes both - and _ to - in freeze output; try both
        pkg_hyphen=$(echo "$pkg" | tr '_' '-')
        pkg_under=$(echo "$pkg" | tr '-' '_')
        if echo "$pip_list" | grep -qi "^${pkg_hyphen}=\|^${pkg_under}="; then
            pass "pip package '$pkg' is installed"
        else
            fail "pip package '$pkg' is installed"
        fi
    done < "$REQUIREMENTS_FILE"
else
    fail "requirements-dev.txt exists at $REQUIREMENTS_FILE"
fi

summary || exit 1
