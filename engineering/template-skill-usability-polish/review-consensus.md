# Review Consensus: template-skill-usability-polish

## Scope Reviewed

Skeletal templates and `ssf-build` / `ssf-retro` / `ssf-archive` usability changes.

## Reviewers

- Chandrasekhar: CHANGES_REQUESTED; require validate-pack guardrails, exact template scope, preserved ssf-build grep contracts, and final archive continuation step.
- Kant: CHANGES_REQUESTED; require adding table-only templates to scope or explicitly excluding them, plus focused tests and retained build gates.
- Leibniz: CHANGES_REQUESTED; require Batch 4-specific Bats, validate-pack markers, build cross-references with local gates, retro probing questions, and archive Step 7 continuation.

## Consensus

Add light local guidance without bloating templates. Scope covers `acceptance-matrix.md`, `proposal.md`, `design.md`, `risk-matrix.md`, `negative-test-matrix.md`, `spec-to-code-map.md`, `sync-check.md`, and `tasks.md`. Cross-reference related skills only after preserving explicit mandatory gates. Do not weaken TDD, Spec ID, review, QA, Ship, Git, or verification rules.

## Required Tests

- Template guidance markers are present.
- `ssf-build` still contains required TDD, Plan Review Loop, progress, and `/ssf-commit` handoff markers.
- `ssf-retro` contains probing questions.
- `ssf-archive` contains automatic continuation heading/rule.
