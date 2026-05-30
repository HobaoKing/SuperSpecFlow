# Spec: runtime validators

## ADDED Requirements

### Requirement: SSF-RUNTIME-GATE-001 Commit message validator

The system MUST provide a reusable validator for commit title and body traceability fields.

#### Scenario: message misses traceability
- GIVEN a commit message lacks `变更编号` or `关联规格`
- WHEN validation runs
- THEN validation fails with a field-specific error.

### Requirement: SSF-RUNTIME-GATE-002 QA signoff blocked waiver validator

The system MUST reject QA signoffs that recommend ship while blocked without explicit waiver evidence.

#### Scenario: blocked QA recommends ship
- GIVEN Browser or Visual QA status is blocked
- WHEN the recommendation is `Ship` or `Ship with monitoring`
- THEN `Blocked Waiver` evidence is required.

### Requirement: SSF-RUNTIME-GATE-003 Change ledger validator

The system MUST validate that every package OpenSpec change is represented in the change ledger.

#### Scenario: change is missing from ledger
- GIVEN `openspec/changes/<change-id>` exists
- WHEN ledger validation runs
- THEN validation fails if no row exists for `<change-id>`.

## MUST NOT

- SSF-RUNTIME-GATE-N1 Validators MUST NOT replace manual review; they only enforce structural gates.
