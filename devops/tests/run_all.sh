#!/usr/bin/env bash
# run_all.sh — Master runner for tooling verification tests.
#
# Usage:
#   bash devops/tests/run_all.sh           # Run all suites
#   bash devops/tests/run_all.sh --ci      # Skip service tests (no Docker)
#
# Discovers and runs all test_*.sh files in this directory, aggregates
# results, and exits non-zero if any suite fails.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CI_MODE=false

if [[ "${1:-}" == "--ci" ]]; then
    CI_MODE=true
    shift
fi

# ── Colors ───────────────────────────────────────────────────────────

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

# ── Run suites ───────────────────────────────────────────────────────

TOTAL_PASS=0
TOTAL_FAIL=0
TOTAL_SKIP=0
SUITE_PASS=0
SUITE_FAIL=0
FAILED_SUITES=()

printf "${_BOLD}${_CYAN}══════════════════════════════════════════════════════${_RESET}\n"
printf "${_BOLD}${_CYAN}  Tooling Verification Test Suite${_RESET}\n"
printf "${_BOLD}${_CYAN}══════════════════════════════════════════════════════${_RESET}\n"

for test_file in "${SCRIPT_DIR}"/test_*.sh; do
    [[ -f "$test_file" ]] || continue

    suite_name=$(basename "$test_file" .sh)

    # Skip service tests in CI mode
    if $CI_MODE && [[ "$suite_name" == "test_services" ]]; then
        printf "\n${_YELLOW}⊘ SKIP${_RESET}  Suite '${suite_name}' (--ci mode)\n"
        continue
    fi

    if bash "$test_file"; then
        SUITE_PASS=$((SUITE_PASS + 1))
    else
        SUITE_FAIL=$((SUITE_FAIL + 1))
        FAILED_SUITES+=("$suite_name")
    fi
done

# ── Aggregate summary ────────────────────────────────────────────────

printf "${_BOLD}${_CYAN}══════════════════════════════════════════════════════${_RESET}\n"
printf "${_BOLD}${_CYAN}  Aggregate Results${_RESET}\n"
printf "${_BOLD}${_CYAN}══════════════════════════════════════════════════════${_RESET}\n"

TOTAL_SUITES=$((SUITE_PASS + SUITE_FAIL))
printf "  Suites passed:  ${_GREEN}%d${_RESET} / %d\n" "$SUITE_PASS" "$TOTAL_SUITES"
printf "  Suites failed:  ${_RED}%d${_RESET} / %d\n" "$SUITE_FAIL" "$TOTAL_SUITES"

if [[ ${#FAILED_SUITES[@]} -gt 0 ]]; then
    printf "\n  ${_RED}Failed suites:${_RESET}\n"
    for s in "${FAILED_SUITES[@]}"; do
        printf "    ${_RED}✗${_RESET} %s\n" "$s"
    done
fi

printf "\n"

if [[ $SUITE_FAIL -gt 0 ]]; then
    printf "${_RED}${_BOLD}RESULT: FAIL${_RESET}\n\n"
    exit 1
else
    printf "${_GREEN}${_BOLD}RESULT: PASS${_RESET}\n\n"
    exit 0
fi
