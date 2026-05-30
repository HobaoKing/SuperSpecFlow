# Spec: evidence lifecycle

## ADDED Requirements

### Requirement: SSF-EVIDENCE-001 Thin root instruction files

The system MUST keep repository root `AGENTS.md` and `CLAUDE.md` as thin entries into centralized routing.

#### Scenario: maintainer opens root instructions
- GIVEN a maintainer opens a root instruction file
- WHEN they look for SuperSpecFlow routing
- THEN the file points to the corresponding `routing/*.routing.md`
- AND it does not duplicate the full Intake Gate table or slash command set.

### Requirement: SSF-EVIDENCE-002 Intake artifact namespace

The system MUST define an intake artifact namespace for host runtime evidence.

#### Scenario: agent records an intake decision
- GIVEN a formal change has a change-id
- WHEN Intake Gate output needs to be preserved
- THEN the runtime artifact path is `.superspecflow/intake/<change-id>/intake-gate.md`.

### Requirement: SSF-EVIDENCE-003 Package change ledger

The system MUST keep a committable ledger of package OpenSpec change status.

#### Scenario: maintainer reviews package status
- GIVEN `openspec/changes/*` contains active change contracts
- WHEN `validate-pack` runs
- THEN every change is listed in `openspec/change-ledger.md`.

## MUST NOT

- SSF-EVIDENCE-N1 Root instruction files MUST NOT contain the complete routing contract.
- SSF-EVIDENCE-N2 SuperSpecFlow package source MUST NOT commit `.superspecflow/` runtime instances.
- SSF-EVIDENCE-N3 The ledger MUST NOT replace OpenSpec specs or tasks.
