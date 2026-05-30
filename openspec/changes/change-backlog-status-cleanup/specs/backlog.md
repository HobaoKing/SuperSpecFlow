# Spec: backlog status

## ADDED Requirements

### Requirement: SSF-BACKLOG-001 Existing change status ledger

The system MUST classify existing package changes as `active`, `complete`, `archived`, or `superseded`.

#### Scenario: maintainer checks current status
- GIVEN a change exists under `openspec/changes/`
- WHEN the maintainer opens `openspec/change-ledger.md`
- THEN the change has a status row and evidence notes.

### Requirement: SSF-BACKLOG-002 Workflow-scale evidence refresh

The system MUST avoid stale statements that completed child changes are still future work.

#### Scenario: workflow-scale status is reviewed
- GIVEN child changes are implemented
- WHEN the ledger summarizes workflow-scale status
- THEN the notes mention implemented child changes and remaining evidence gaps separately.

## MUST NOT

- SSF-BACKLOG-N1 The ledger MUST NOT mark a change `archived` without archive evidence or explicit status rationale.
