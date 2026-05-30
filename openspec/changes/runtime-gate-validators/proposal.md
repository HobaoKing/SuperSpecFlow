# Proposal: runtime-gate-validators

## Summary

Add executable validators for commit messages, QA signoff state, and change ledger coverage.

## Problem

Several gates are currently expressed in templates and prose but are not enforced on concrete instances.

## Goals

- Validate commit message traceability fields.
- Validate blocked QA signoff waiver requirements.
- Validate change ledger coverage.
- Wire validators into hooks and pack validation.
