// @ts-check
import globals from "globals";
import js from "@eslint/js";

/** @type {import("eslint").Linter.Config[]} */
export default [
    // ── Base: eslint recommended rules ──────────────────────────────
    js.configs.recommended,

    // ── Odoo backend (OWL components & services) ────────────────────
    {
        files: ["**/static/src/**/*.js"],
        languageOptions: {
            ecmaVersion: 2022,
            sourceType: "module",
            globals: {
                ...globals.browser,
                owl: "readonly",
                luxon: "readonly",
            },
        },
        rules: {
            // ── Possible errors ─────────────────────────────────────
            "no-unused-vars": [
                "warn",
                {
                    argsIgnorePattern: "^_",
                    varsIgnorePattern: "^_",
                },
            ],
            "no-undef": "error",
            "no-constant-condition": "warn",
            "no-debugger": "error",

            // ── Best practices ──────────────────────────────────────
            eqeqeq: ["error", "smart"],
            "no-eval": "error",
            "no-implied-eval": "error",
            "no-new-func": "error",
            "no-caller": "error",
            "no-extend-native": "error",
            "no-extra-bind": "warn",
            "no-multi-str": "warn",
            "no-new-wrappers": "error",
            "no-throw-literal": "error",
            "prefer-const": "warn",
            "no-var": "error",

            // ── Style (minimal — Prettier handles formatting) ───────
            "no-lonely-if": "warn",
            "prefer-template": "warn",
        },
    },

    // ── Test files (relaxed rules) ──────────────────────────────────
    {
        files: ["**/static/tests/**/*.js"],
        languageOptions: {
            ecmaVersion: 2022,
            sourceType: "module",
            globals: {
                ...globals.browser,
                owl: "readonly",
                luxon: "readonly",
                QUnit: "readonly",
            },
        },
        rules: {
            "no-unused-vars": "off",
        },
    },

    // ── Global ignores ──────────────────────────────────────────────
    {
        ignores: ["node_modules/", "**/static/lib/", "**/static/src/lib/"],
    },
];
