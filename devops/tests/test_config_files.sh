#!/usr/bin/env bash
# test_config_files.sh — Validate all project configuration files.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "$(dirname "$0")/helpers.sh"

suite_header "Config: pyproject.toml"

PYPROJECT="${REPO_ROOT}/pyproject.toml"
assert_file_exists "$PYPROJECT"
assert_file_contains "$PYPROJECT" '\[tool\.coverage\.run\]' "pyproject.toml has [tool.coverage.run]"
assert_file_contains "$PYPROJECT" 'fail_under\s*=\s*80' "pyproject.toml has fail_under = 80"
assert_file_contains "$PYPROJECT" 'branch\s*=\s*true' "pyproject.toml has branch = true"
assert_file_contains "$PYPROJECT" '\[tool\.isort\]' "pyproject.toml has [tool.isort]"
assert_file_contains "$PYPROJECT" 'profile\s*=\s*"black"' "pyproject.toml has isort profile = black"
assert_file_contains "$PYPROJECT" '\[tool\.coverage\.report\]' "pyproject.toml has [tool.coverage.report]"
assert_file_contains "$PYPROJECT" '\[tool\.coverage\.html\]' "pyproject.toml has [tool.coverage.html]"
assert_file_contains "$PYPROJECT" '\[tool\.coverage\.xml\]' "pyproject.toml has [tool.coverage.xml]"

suite_header "Config: cosmic-ray.toml"

COSMIC="${REPO_ROOT}/cosmic-ray.toml"
assert_file_exists "$COSMIC"
assert_file_contains "$COSMIC" '\[cosmic-ray\]' "cosmic-ray.toml has [cosmic-ray] section"
assert_file_contains "$COSMIC" 'timeout' "cosmic-ray.toml has timeout setting"
assert_file_contains "$COSMIC" 'module-path' "cosmic-ray.toml has module-path setting"
assert_file_contains "$COSMIC" 'SET_MODULE_PATH' "cosmic-ray.toml has SET_MODULE_PATH placeholder"
assert_file_contains "$COSMIC" '\[cosmic-ray\.distributor\]' "cosmic-ray.toml has [cosmic-ray.distributor]"
assert_file_contains "$COSMIC" 'excluded-modules' "cosmic-ray.toml has excluded-modules"

suite_header "Config: .pylintrc"

PYLINTRC="${REPO_ROOT}/.pylintrc"
assert_file_exists "$PYLINTRC"
assert_file_contains "$PYLINTRC" 'pylint_odoo' ".pylintrc loads pylint_odoo plugin"
assert_file_contains "$PYLINTRC" '19\.0' ".pylintrc sets valid_odoo_versions = 19.0"

suite_header "Config: eslint.config.mjs"

ESLINT_CFG="${REPO_ROOT}/eslint.config.mjs"
assert_file_exists "$ESLINT_CFG"
# Verify it is parseable JS
if node -e "import('${ESLINT_CFG}')" &>/dev/null; then
    pass "eslint.config.mjs is valid JavaScript (ESM)"
else
    # Fallback: syntax check only
    if node --check "$ESLINT_CFG" &>/dev/null; then
        pass "eslint.config.mjs passes syntax check"
    else
        fail "eslint.config.mjs is valid JavaScript"
    fi
fi

suite_header "Config: package.json"

PKG="${REPO_ROOT}/package.json"
assert_file_exists "$PKG"
for dep in eslint prettier stylelint markdownlint-cli2; do
    assert_file_contains "$PKG" "\"${dep}\"" "package.json has devDependency '$dep'"
done

suite_header "Config: .pre-commit-config.yaml"

PRECOMMIT="${REPO_ROOT}/.pre-commit-config.yaml"
assert_file_exists "$PRECOMMIT"
# Validate YAML syntax
if python3 -c "import yaml; yaml.safe_load(open('${PRECOMMIT}'))" &>/dev/null; then
    pass ".pre-commit-config.yaml is valid YAML"
else
    fail ".pre-commit-config.yaml is valid YAML"
fi
# Check all expected hook IDs
for hook_id in trailing-whitespace end-of-file-fixer check-yaml check-xml \
               check-added-large-files check-merge-conflict debug-statements \
               mixed-line-ending black isort pylint prettier eslint stylelint; do
    assert_file_contains "$PRECOMMIT" "id: ${hook_id}" ".pre-commit-config.yaml has hook '$hook_id'"
done

suite_header "Config: odoo.conf"

ODOO_CONF="${REPO_ROOT}/.devcontainer/config/odoo.conf"
assert_file_exists "$ODOO_CONF"
for key in db_host addons_path db_user db_password; do
    assert_file_contains "$ODOO_CONF" "$key" "odoo.conf has required key '$key'"
done

summary || exit 1
