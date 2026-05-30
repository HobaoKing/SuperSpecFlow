# Proposal: workflow-hardening-program

## Summary

Define a parent hardening program that closes the gaps found by the multi-agent review: durable evidence lifecycle, root routing hardening, host portability, runtime validators, backlog status cleanup, and high-risk release gates.

## Problem

The package has healthy contract tests, but several completion and release promises are still enforced mostly by prose. Root instruction files can drift from centralized routing, local `.superspecflow/` evidence is ignored, external host assumptions are brittle, and high-risk release templates are thin.

## Goals

- Split the hardening work into child changes with explicit dependencies.
- Keep existing `workflow-scale-architecture` scoped to its original browser/cluster roadmap.
- Make evidence, routing, validation, install portability, backlog status, and release templates independently testable.

## Non-goals

- Do not introduce a real browser runner or image diff implementation.
- Do not require host projects to commit `.superspecflow/`.
- Do not change the slash command names.

## Child Changes

1. `evidence-lifecycle-root-routing`
2. `install-host-portability`
3. `runtime-gate-validators`
4. `change-backlog-status-cleanup`
5. `high-risk-release-template-hardening`

## Success Metrics

- `rtk bash scripts/validate-pack.sh` and `rtk bash scripts/test.sh` pass.
- Each child has OpenSpec tasks, a spec-to-code map, and focused tests.
- The root instruction files remain thin entries into centralized routing.
