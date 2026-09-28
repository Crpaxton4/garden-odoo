#!/usr/bin/env bash
# test_ci_workflows.sh — Validate CI workflow file structure.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "$(dirname "$0")/helpers.sh"

WORKFLOWS="${REPO_ROOT}/.github/workflows"

suite_header "CI Workflows: File existence"

WORKFLOW_FILES=(quality.yml coverage.yml codeql.yml devcontainer.yml)
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
assert_file_contains "$QF" 'python-version.*3\.14' "quality.yml uses Python 3.14"
assert_file_contains "$QF" 'node-version.*22' "quality.yml uses Node 22"

suite_header "CI Workflows: coverage.yml"

CF="${WORKFLOWS}/coverage.yml"
assert_file_contains "$CF" 'push:' "coverage.yml triggers on push"
assert_file_contains "$CF" 'pull_request:' "coverage.yml triggers on pull_request"
assert_file_contains "$CF" 'postgres:17' "coverage.yml has postgres:17 service"
assert_file_contains "$CF" 'python-version.*3\.14' "coverage.yml uses Python 3.14"
assert_file_contains "$CF" 'coverage erase' "coverage.yml erases stale coverage data"
assert_file_contains "$CF" 'coverage report' "coverage.yml generates coverage report"

suite_header "CI Workflows: codeql.yml"

CQLF="${WORKFLOWS}/codeql.yml"
assert_file_contains "$CQLF" 'push:' "codeql.yml triggers on push"
assert_file_contains "$CQLF" 'pull_request:' "codeql.yml triggers on pull_request"
assert_file_contains "$CQLF" 'python' "codeql.yml scans Python"
assert_file_contains "$CQLF" 'javascript' "codeql.yml scans JavaScript"

suite_header "CI Workflows: devcontainer.yml"

DF="${WORKFLOWS}/devcontainer.yml"
assert_file_contains "$DF" 'push:' "devcontainer.yml triggers on push"
assert_file_contains "$DF" '\.devcontainer' "devcontainer.yml watches .devcontainer/ paths"
assert_file_contains "$DF" 'devops/' "devcontainer.yml watches devops/ paths"
assert_file_contains "$DF" 'run_all\.sh --ci' "devcontainer.yml runs tooling tests via run_all.sh --ci"

suite_header "CI Workflows: tooling.yml"

TF="${WORKFLOWS}/tooling.yml"
assert_file_exists "$TF" "workflow 'tooling.yml' exists"
assert_file_contains "$TF" 'push:' "tooling.yml triggers on push"
assert_file_contains "$TF" 'pull_request:' "tooling.yml triggers on pull_request"
assert_file_contains "$TF" 'tests/tooling' "tooling.yml watches tests/tooling/ paths"
assert_file_contains "$TF" 'run_all\.sh --ci' "tooling.yml runs tests via run_all.sh --ci"

summary || exit 1
