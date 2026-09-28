#!/usr/bin/env bash
# test_ray_gun.sh — Verify mutation testing wrapper and dependencies.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "$(dirname "$0")/helpers.sh"

suite_header "Mutation Testing: ray_gun.sh"

RAY_GUN="${REPO_ROOT}/ray_gun.sh"
assert_file_exists "$RAY_GUN" "ray_gun.sh exists"
assert_file_executable "$RAY_GUN" "ray_gun.sh is executable"

suite_header "Mutation Testing: Template config"

COSMIC="${REPO_ROOT}/cosmic-ray.toml"
assert_file_exists "$COSMIC" "cosmic-ray.toml template exists"
assert_file_contains "$COSMIC" 'SET_MODULE_PATH' "cosmic-ray.toml has SET_MODULE_PATH placeholder"
assert_file_contains "$COSMIC" 'SET_MODULE_TAG' "cosmic-ray.toml has SET_MODULE_TAG placeholder"

suite_header "Mutation Testing: CLI dependencies"

assert_command_exists cosmic-ray "cosmic-ray CLI is available"

if command -v cr-report &>/dev/null; then
    pass "cr-report CLI is available"
else
    fail "cr-report CLI is available"
fi

if command -v cr-html &>/dev/null; then
    pass "cr-html CLI is available"
else
    fail "cr-html CLI is available"
fi

assert_command_exists sed "sed is available (required by ray_gun.sh)"
assert_command_exists tput "tput is available (required by ray_gun.sh)"

summary || exit 1
