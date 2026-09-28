#!/usr/bin/env bash
# test_git_config.sh — Verify git configuration and hooks.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "$(dirname "$0")/helpers.sh"

suite_header "Git Configuration"

# core.autocrlf should be 'input'
autocrlf=$(git config --global core.autocrlf 2>/dev/null || echo "unset")
if [[ "$autocrlf" == "input" ]]; then
    pass "git core.autocrlf = input"
else
    fail "git core.autocrlf = input (got: $autocrlf)"
fi

# core.eol should be 'lf'
eol=$(git config --global core.eol 2>/dev/null || echo "unset")
if [[ "$eol" == "lf" ]]; then
    pass "git core.eol = lf"
else
    fail "git core.eol = lf (got: $eol)"
fi

# Pre-commit hook installed
GIT_HOOKS_DIR="${REPO_ROOT}/.git/hooks"
if [[ -f "${GIT_HOOKS_DIR}/pre-commit" ]]; then
    pass "pre-commit git hook is installed"
else
    fail "pre-commit git hook is installed"
fi

# Verify we're in a git repository
if git -C "$REPO_ROOT" rev-parse --is-inside-work-tree &>/dev/null; then
    pass "workspace is a git repository"
else
    fail "workspace is a git repository"
fi

summary || exit 1
