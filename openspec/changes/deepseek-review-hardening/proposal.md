# Proposal: deepseek-review-hardening

## Summary

Resolve the DeepSeek review feedback as one traceable hardening change.

## Problem

The previous workflow hardening pass left several quality gaps: one real temp-file race, one non-portable root include, missing command-specific contract tests, incomplete compatibility requirements, a stale README template name, misplaced PoC research notes, missing CI/shellcheck automation, and an over-broad active state in the change ledger.

## Goals

- Remove temp-file races from pack validation.
- Keep root instruction files portable across machines.
- Add bats contracts for `/ssf-branch`, `/ssf-decision`, and `/ssf-map`.
- Document runtime/test dependencies and platform expectations.
- Align OpenSpec naming documentation with actual `design.md` usage.
- Move PoC research notes into a research namespace.
- Add CI automation for validation, tests, and shellcheck.
- Refresh the change ledger so completed implementation contracts are not left as stale active work.

## Non-goals

- Do not fabricate historical Review/QA/Ship/Archive artifacts.
- Do not require Bash 4 when current runtime scripts are compatible with macOS Bash 3.2 patterns.
