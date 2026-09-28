#!/usr/bin/env bash
# test_pre_commit.sh — Verify pre-commit hooks are installed and configured.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "$(dirname "$0")/helpers.sh"

suite_header "Pre-commit: Installation"

PRECOMMIT_CFG="${REPO_ROOT}/.pre-commit-config.yaml"
assert_file_exists "$PRECOMMIT_CFG"
assert_command_exists pre-commit

# Git hooks directory contains pre-commit hook
GIT_HOOKS_DIR="${REPO_ROOT}/.git/hooks"
if [[ -f "${GIT_HOOKS_DIR}/pre-commit" ]]; then
    pass "pre-commit hook is installed in .git/hooks/"
else
    fail "pre-commit hook is installed in .git/hooks/"
fi

suite_header "Pre-commit: Hook repos"

# Count repos defined in config (lines matching '- repo:')
repo_count=$(grep -c '^\s*- repo:' "$PRECOMMIT_CFG" 2>/dev/null || echo 0)
if [[ "$repo_count" -ge 7 ]]; then
    pass "pre-commit config has $repo_count hook repos (expected >= 7)"
else
    fail "pre-commit config has $repo_count hook repos (expected >= 7)"
fi

# Count individual hook IDs (lines matching '- id:')
hook_count=$(grep -c '^\s*- id:' "$PRECOMMIT_CFG" 2>/dev/null || echo 0)
if [[ "$hook_count" -ge 14 ]]; then
    pass "pre-commit config has $hook_count hooks (expected >= 14)"
else
    fail "pre-commit config has $hook_count hooks (expected >= 14, got $hook_count)"
fi

# Verify each repo has a rev
suite_header "Pre-commit: Repo revisions"

while IFS= read -r repo_line; do
    repo_url=$(echo "$repo_line" | grep -oP 'repo:\s*\K\S+' || echo "unknown")
    # Skip local repos (no rev needed)
    if [[ "$repo_url" == "local" ]]; then
        pass "repo '$repo_url' — local (no rev needed)"
        continue
    fi
done < <(grep '^\s*- repo:' "$PRECOMMIT_CFG")

# Check all repos (non-local) have rev lines following them
non_local_repos=$(grep -c '^\s*- repo: https' "$PRECOMMIT_CFG" 2>/dev/null || echo 0)
rev_count=$(grep -c '^\s*rev:' "$PRECOMMIT_CFG" 2>/dev/null || echo 0)
if [[ "$rev_count" -ge "$non_local_repos" ]]; then
    pass "all non-local repos ($non_local_repos) have rev pinned ($rev_count revs found)"
else
    fail "all non-local repos have rev pinned (repos: $non_local_repos, revs: $rev_count)"
fi

summary || exit 1
