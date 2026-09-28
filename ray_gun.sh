#!/usr/bin/env bash
# ray_gun.sh — Run Cosmic Ray mutation testing for an Odoo 19.0 module.
#
# Usage:
#   ./ray_gun.sh <module_name> [session=<path>]
#
# Examples:
#   ./ray_gun.sh garden_harvest
#   ./ray_gun.sh garden_sale session=previous-run.sqlite
#
# Creates a dated session DB, initialises mutations, baselines, executes,
# and generates an HTML report.  Shows live progress during execution.

set -euo pipefail

# ── Arguments ────────────────────────────────────────────────────────

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <module_name> [session=<path>]"
    echo "  module_name  Odoo module to mutate (e.g. garden_harvest)"
    echo "  session=     Optional path to an existing session DB to resume"
    exit 1
fi

MODULE="$1"
MODULE_DIR="${MODULE}/models/"
SESSION_DB="${MODULE}_mutations-$(date +%F).sqlite"

if [[ "${2:-}" == session=* ]]; then
    SESSION_DB="${2#session=}"
fi

# ── Validate module exists ───────────────────────────────────────────

if [[ ! -d "$MODULE_DIR" ]]; then
    echo "Error: Module directory '$MODULE_DIR' not found."
    echo "Make sure you run this from the repository root."
    exit 1
fi

# ── Generate a per-run config from the template ──────────────────────

CONFIG_FILE=".cosmic-ray-${MODULE}.toml"

sed -e "s|module-path = \"SET_MODULE_PATH\"|module-path = \"${MODULE_DIR}\"|" \
    -e "s|/SET_MODULE_TAG|/${MODULE}|" \
    cosmic-ray.toml > "$CONFIG_FILE"

echo "Module:  $MODULE"
echo "Config:  $CONFIG_FILE"
echo "Session: $SESSION_DB"
echo ""

# ── Initialise (skip if session DB already exists) ───────────────────

if [[ ! -f "$SESSION_DB" ]]; then
    echo "Initialising mutations..."
    cosmic-ray init "$CONFIG_FILE" "$SESSION_DB"
else
    echo "Resuming existing session: $SESSION_DB"
fi

# ── Baseline ─────────────────────────────────────────────────────────

echo "Running baseline (unmutated tests must pass)..."
cosmic-ray baseline --report "$CONFIG_FILE" "$SESSION_DB"
echo ""

# ── Execute mutations ────────────────────────────────────────────────

echo "Executing mutation tests..."
cosmic-ray exec "$CONFIG_FILE" "$SESSION_DB" &
EXEC_PID=$!

# ── Live progress (alternate screen buffer) ──────────────────────────

tput civis 2>/dev/null || true          # Hide cursor
tput smcup 2>/dev/null || true          # Alternate buffer
trap 'tput rmcup 2>/dev/null || true; tput cnorm 2>/dev/null || true' EXIT

while kill -0 "$EXEC_PID" 2>/dev/null; do
    tput cup 0 0 2>/dev/null || true    # Move to top-left
    echo "── Mutation Testing: $MODULE ($(date +%H:%M:%S)) ──"
    echo ""
    cr-report "$SESSION_DB" 2>/dev/null | tail -n 40
    sleep 5
done

wait "$EXEC_PID"

tput rmcup 2>/dev/null || true          # Restore screen
tput cnorm 2>/dev/null || true          # Show cursor
trap - EXIT

# ── Final report ─────────────────────────────────────────────────────

echo ""
echo "── Final Results ──"
cr-report "$SESSION_DB"

# ── HTML report ──────────────────────────────────────────────────────

REPORT_FILE="${MODULE}_mutations_report.html"
cr-html "$SESSION_DB" > "$REPORT_FILE"
echo ""
echo "HTML report: $REPORT_FILE"

# ── Cleanup temp config ──────────────────────────────────────────────

rm -f "$CONFIG_FILE"
