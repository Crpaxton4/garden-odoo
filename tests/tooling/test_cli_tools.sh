#!/usr/bin/env bash
# test_cli_tools.sh — Verify all CLI tools are available with expected versions.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "$(dirname "$0")/helpers.sh"

suite_header "CLI Tools: Python"

assert_command_exists python3
assert_version_match python3 '3\.1[0-9]' "python3 version is 3.1x"
assert_command_exists black
assert_command_exists isort
assert_command_exists pylint
assert_command_exists coverage "coverage.py is available"
# coverage >= 7.13
coverage_ver=$(coverage --version 2>&1 | grep -oP '\d+\.\d+' | head -1)
if [[ "$(echo "$coverage_ver >= 7.13" | bc -l 2>/dev/null || echo 0)" == "1" ]]; then
    pass "coverage version >= 7.13 (got $coverage_ver)"
else
    # Fallback: compare major.minor manually
    cov_major=${coverage_ver%%.*}
    cov_minor=${coverage_ver#*.}
    if [[ "$cov_major" -gt 7 ]] || { [[ "$cov_major" -eq 7 ]] && [[ "${cov_minor%%.*}" -ge 13 ]]; }; then
        pass "coverage version >= 7.13 (got $coverage_ver)"
    else
        fail "coverage version >= 7.13 (got $coverage_ver)"
    fi
fi
assert_command_exists cosmic-ray
assert_command_exists pre-commit
assert_python_import debugpy "debugpy is importable"

suite_header "CLI Tools: Node.js"

assert_command_exists node
assert_version_match node 'v22\.' "node version is 22.x"
assert_command_exists npm
assert_command_exists npx

suite_header "CLI Tools: NPX tools"

if npx eslint --version &>/dev/null; then
    eslint_ver=$(npx eslint --version 2>&1)
    if echo "$eslint_ver" | grep -qE '^v?9\.'; then
        pass "eslint version is 9.x (got $eslint_ver)"
    else
        fail "eslint version is 9.x (got $eslint_ver)"
    fi
else
    fail "eslint is available via npx"
fi

if npx prettier --version &>/dev/null; then
    prettier_ver=$(npx prettier --version 2>&1)
    if echo "$prettier_ver" | grep -qE '^3\.'; then
        pass "prettier version is 3.x (got $prettier_ver)"
    else
        fail "prettier version is 3.x (got $prettier_ver)"
    fi
else
    fail "prettier is available via npx"
fi

if npx stylelint --version &>/dev/null; then
    pass "stylelint is available via npx"
else
    fail "stylelint is available via npx"
fi

if npx markdownlint-cli2 --version &>/dev/null; then
    pass "markdownlint-cli2 is available via npx"
else
    fail "markdownlint-cli2 is available via npx"
fi

suite_header "CLI Tools: Global CLIs"

assert_command_exists gh "GitHub CLI (gh) is available"
assert_command_exists git
assert_command_exists odoo

suite_header "CLI Tools: System utilities"

assert_python_import IPython "ipython is importable"

if [[ -f /etc/bash_completion ]] || [[ -d /etc/bash_completion.d ]]; then
    pass "bash-completion is installed"
else
    fail "bash-completion is installed"
fi

summary || exit 1
