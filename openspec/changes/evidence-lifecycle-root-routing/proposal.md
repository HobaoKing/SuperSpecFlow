# Proposal: evidence-lifecycle-root-routing

## Summary

Make root instruction files thin entries, define an intake/evidence lifecycle namespace, and add a committable OpenSpec change ledger for the SuperSpecFlow package repository.

## Problem

Root `AGENTS.md` and `CLAUDE.md` duplicate routing content that should live in `routing/*.routing.md`. Completion evidence in `.superspecflow/` is intentionally ignored, so the package repository needs a committable summary ledger for change status and evidence gaps.

## Goals

- Thin root instruction files.
- Add `.superspecflow/intake/<change-id>/intake-gate.md` as the runtime intake artifact path.
- Add `openspec/change-ledger.md` for package-repo status.
- Validate root thinness and ledger coverage.

## Non-goals

- Do not force host projects to commit `.superspecflow/`.
- Do not move existing ignored local evidence into Git.
