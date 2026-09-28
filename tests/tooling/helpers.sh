#!/usr/bin/env bash
# helpers.sh — Shared test harness for tooling verification.
#
# Source this file at the top of each test_*.sh script:
#   REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
#   source "$(dirname "$0")/helpers.sh"
#
# Provides colored pass/fail/skip output, assertion helpers, and a
# summary function that exits non-zero when any test has failed.

set -euo pipefail

# ── State ────────────────────────────────────────────────────────────

_PASS_COUNT=0
_FAIL_COUNT=0
_SKIP_COUNT=0
_SUITE_NAME="${SUITE_NAME:-$(basename "${BASH_SOURCE[1]:-unknown}" .sh)}"

# ── Colors (disabled when stdout is not a terminal) ──────────────────

if [[ -t 1 ]]; then
    _GREEN='\033[0;32m'
    _RED='\033[0;31m'
    _YELLOW='\033[0;33m'
    _CYAN='\033[0;36m'
    _BOLD='\033[1m'
    _RESET='\033[0m'
else
    _GREEN='' _RED='' _YELLOW='' _CYAN='' _BOLD='' _RESET=''
fi

# ── Output helpers ───────────────────────────────────────────────────

pass() {
    _PASS_COUNT=$((_PASS_COUNT + 1))
    printf "${_GREEN}  ✓ PASS${_RESET}  %s\n" "$*"
}

fail() {
    _FAIL_COUNT=$((_FAIL_COUNT + 1))
    printf "${_RED}  ✗ FAIL${_RESET}  %s\n" "$*"
}

skip() {
    _SKIP_COUNT=$((_SKIP_COUNT + 1))
    printf "${_YELLOW}  ⊘ SKIP${_RESET}  %s\n" "$*"
}

suite_header() {
    printf "\n${_BOLD}${_CYAN}── %s ──${_RESET}\n" "$1"
}

# ── Assertion helpers ────────────────────────────────────────────────

assert_command_exists() {
    local cmd="$1"
    local label="${2:-command '$cmd' is available}"
    if command -v "$cmd" &>/dev/null; then
        pass "$label"
    else
        fail "$label"
    fi
}

assert_version_match() {
    local cmd="$1"
    local pattern="$2"
    local label="${3:-$cmd version matches '$pattern'}"
    local version_output
    if ! version_output=$("$cmd" --version 2>&1); then
        fail "$label (command failed)"
        return
    fi
    if echo "$version_output" | grep -qE "$pattern"; then
        pass "$label"
    else
        fail "$label (got: $(echo "$version_output" | head -1))"
    fi
}

assert_python_import() {
    local module="$1"
    local label="${2:-Python module '$module' is importable}"
    if python3 -c "import $module" &>/dev/null; then
        pass "$label"
    else
        fail "$label"
    fi
}

assert_file_exists() {
    local filepath="$1"
    local label="${2:-file '$filepath' exists}"
    if [[ -f "$filepath" ]]; then
        pass "$label"
    else
        fail "$label"
    fi
}

assert_dir_exists() {
    local dirpath="$1"
    local label="${2:-directory '$dirpath' exists}"
    if [[ -d "$dirpath" ]]; then
        pass "$label"
    else
        fail "$label"
    fi
}

assert_file_executable() {
    local filepath="$1"
    local label="${2:-file '$filepath' is executable}"
    if [[ -x "$filepath" ]]; then
        pass "$label"
    else
        fail "$label"
    fi
}

assert_file_contains() {
    local filepath="$1"
    local pattern="$2"
    local label="${3:-'$filepath' contains '$pattern'}"
    if [[ ! -f "$filepath" ]]; then
        fail "$label (file not found)"
        return
    fi
    if grep -qE "$pattern" "$filepath"; then
        pass "$label"
    else
        fail "$label"
    fi
}

assert_file_not_contains() {
    local filepath="$1"
    local pattern="$2"
    local label="${3:-'$filepath' does not contain '$pattern'}"
    if [[ ! -f "$filepath" ]]; then
        fail "$label (file not found)"
        return
    fi
    if grep -qE "$pattern" "$filepath"; then
        fail "$label"
    else
        pass "$label"
    fi
}

assert_service_reachable() {
    local host="$1"
    local port="$2"
    local label="${3:-service '$host:$port' is reachable}"
    if (echo >/dev/tcp/"$host"/"$port") 2>/dev/null; then
        pass "$label"
        return 0
    else
        skip "$label (not reachable — skipping dependent checks)"
        return 1
    fi
}

# ── Summary ──────────────────────────────────────────────────────────

summary() {
    # Disable ERR trap — summary intentionally returns non-zero on failures
    trap - ERR
    local total=$((_PASS_COUNT + _FAIL_COUNT + _SKIP_COUNT))
    printf "\n${_BOLD}── Summary: %s ──${_RESET}\n" "$_SUITE_NAME"
    printf "  ${_GREEN}Passed: %d${_RESET}  " "$_PASS_COUNT"
    printf "${_RED}Failed: %d${_RESET}  " "$_FAIL_COUNT"
    printf "${_YELLOW}Skipped: %d${_RESET}  " "$_SKIP_COUNT"
    printf "Total: %d\n\n" "$total"

    if [[ $_FAIL_COUNT -gt 0 ]]; then
        return 1
    fi
    return 0
}

# Export counts for the master runner to aggregate
export_counts() {
    echo "${_PASS_COUNT}:${_FAIL_COUNT}:${_SKIP_COUNT}"
}

# ── Trap for unexpected exits ────────────────────────────────────────

_on_error() {
    printf "\n${_RED}ERROR${_RESET}: %s aborted unexpectedly (line %s)\n" \
        "$_SUITE_NAME" "${BASH_LINENO[0]:-?}"
    summary || true
    exit 1
}

trap _on_error ERR
