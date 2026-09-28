#!/usr/bin/env bash
# test_ci_workflows.sh — Validate CI workflow file structure.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "$(dirname "$0")/helpers.sh"

WORKFLOWS="${REPO_ROOT}/.github/workflows"

suite_header "CI Workflows: File existence"

WORKFLOW_FILES=(quality.yml codeql.yml devcontainer.yml)
for wf in "${WORKFLOW_FILES[@]}"; do
    assert_file_exists "${WORKFLOWS}/${wf}" "workflow '${wf}' exists"
done

suite_header "CI Workflows: quality.yml"

QF="${WORKFLOWS}/quality.yml"
assert_file_contains "$QF" 'push:' "quality.yml triggers on push"
assert_file_contains "$QF" 'pull_request:' "quality.yml triggers on pull_request"
for tool in "black --check" "isort --check" "eslint" "prettier" "stylelint" "markdownlint"; do
    assert_file_contains "$QF" "$tool" "quality.yml runs $tool"
done
assert_file_contains "$QF" 'python-version.*3\.12' "quality.yml uses Python 3.12 (matches odoo:19.0 image)"
assert_file_contains "$QF" 'node-version.*22' "quality.yml uses Node 22"

suite_header "CI Workflows: codeql.yml"

CQLF="${WORKFLOWS}/codeql.yml"
assert_file_contains "$CQLF" 'push:' "codeql.yml triggers on push"
assert_file_contains "$CQLF" 'pull_request:' "codeql.yml triggers on pull_request"
assert_file_contains "$CQLF" 'python' "codeql.yml scans Python"
assert_file_contains "$CQLF" 'javascript' "codeql.yml scans JavaScript"

suite_header "CI Workflows: devcontainer.yml"

DF="${WORKFLOWS}/devcontainer.yml"
assert_file_contains "$DF" 'push:' "devcontainer.yml triggers on push"
assert_file_contains "$DF" 'pull_request:' "devcontainer.yml triggers on pull_request"
assert_file_contains "$DF" '\.devcontainer' "devcontainer.yml watches .devcontainer/ paths"
assert_file_contains "$DF" 'devops/' "devcontainer.yml watches devops/ paths"
assert_file_contains "$DF" 'run_all\.sh --ci' "devcontainer.yml runs tooling tests via run_all.sh --ci"
assert_file_contains "$DF" "push: .*github\.event_name == 'push'" "devcontainer.yml only publishes the image on push"

summary || exit 1
