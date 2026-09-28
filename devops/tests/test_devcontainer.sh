#!/usr/bin/env bash
# test_devcontainer.sh — Validate devcontainer structure and consistency.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "$(dirname "$0")/helpers.sh"

DEVCONTAINER_DIR="${REPO_ROOT}/.devcontainer"

suite_header "Devcontainer: Lifecycle hooks"

HOOKS_DIR="${REPO_ROOT}/devops/devcontainer"
HOOK_SCRIPTS=(
    onCreateCommand.sh
    postCreateCommand.sh
    postAttachCommand.sh
)

for hook in "${HOOK_SCRIPTS[@]}"; do
    hook_path="${HOOKS_DIR}/${hook}"
    assert_file_exists "$hook_path" "hook '$hook' exists"
    assert_file_executable "$hook_path" "hook '$hook' is executable"
done

suite_header "Devcontainer: compose.yml"

COMPOSE="${DEVCONTAINER_DIR}/compose.yml"
assert_file_exists "$COMPOSE"
assert_file_contains "$COMPOSE" 'ghcr\.io/.*devcontainer' "compose.yml references GHCR devcontainer image"
assert_file_contains "$COMPOSE" 'postgres:17' "compose.yml uses postgres:17"
assert_file_contains "$COMPOSE" 'POSTGRES_USER.*odoo' "compose.yml sets POSTGRES_USER=odoo"

suite_header "Devcontainer: Dockerfile"

DOCKERFILE="${DEVCONTAINER_DIR}/Dockerfile"
assert_file_exists "$DOCKERFILE"
assert_file_contains "$DOCKERFILE" 'FROM odoo:19' "Dockerfile uses FROM odoo:19 base"
assert_file_contains "$DOCKERFILE" 'cli\.github\.com' "Dockerfile installs GitHub CLI (gh)"
assert_file_contains "$DOCKERFILE" 'virtualenv.*--system-site-packages' "Dockerfile creates venv with system site-packages"
assert_file_contains "$DOCKERFILE" 'requirements-dev\.txt' "Dockerfile installs requirements-dev.txt"

suite_header "Devcontainer: devcontainer.json"

DC_JSON="${DEVCONTAINER_DIR}/devcontainer.json"
assert_file_exists "$DC_JSON"
assert_file_contains "$DC_JSON" 'dockerComposeFile.*compose\.yml' "devcontainer.json points at compose.yml"
for hook in "${HOOK_SCRIPTS[@]}"; do
    assert_file_contains "$DC_JSON" "devops/devcontainer/${hook}" "devcontainer.json wires '$hook' from devops/devcontainer/"
done

suite_header "Devcontainer: Extension superset check"

# Every extension in .vscode/extensions.json must appear in devcontainer.json
VSCODE_EXT="${REPO_ROOT}/.vscode/extensions.json"
if [[ -f "$VSCODE_EXT" ]] && [[ -f "$DC_JSON" ]]; then
    all_present=true
    while IFS= read -r ext; do
        ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
        if ! grep -qi "$ext_lower" "$DC_JSON" 2>/dev/null; then
            fail "extension '$ext' is in extensions.json but missing from devcontainer.json"
            all_present=false
        fi
    done < <(grep -oP '"[^"]+\.[^"]+"' "$VSCODE_EXT" | tr -d '"' | grep -v '^\s*$')
    if $all_present; then
        pass "all extensions.json entries present in devcontainer.json"
    fi
else
    skip "extensions superset check: required files not found"
fi

summary || exit 1
