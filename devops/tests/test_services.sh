#!/usr/bin/env bash
# test_services.sh — Verify PostgreSQL and Odoo service connectivity.
# Non-destructive. Gracefully skips when services are unreachable.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "$(dirname "$0")/helpers.sh"

suite_header "Services: PostgreSQL"

# PostgreSQL reachable on db:5432
if command -v pg_isready &>/dev/null; then
    if pg_isready -h db -p 5432 -U odoo -q 2>/dev/null; then
        pass "PostgreSQL is reachable on db:5432"

        # Check odoo database exists
        if PGPASSWORD=odoo psql -h db -U odoo -lqt 2>/dev/null | grep -qw odoo; then
            pass "database 'odoo' exists"
        else
            fail "database 'odoo' exists"
        fi
    else
        skip "PostgreSQL is not reachable on db:5432 — skipping DB checks"
    fi
else
    skip "pg_isready not available — skipping PostgreSQL checks"
fi

suite_header "Services: Odoo Web"

# Odoo web interface responds
if curl -sS --connect-timeout 3 -o /dev/null -w '%{http_code}' http://localhost:8069/ 2>/dev/null | grep -qE '^(200|303)$'; then
    pass "Odoo web responds on localhost:8069 (HTTP 200/303)"
else
    skip "Odoo web is not responding on localhost:8069 — skipping"
fi

summary || exit 1
