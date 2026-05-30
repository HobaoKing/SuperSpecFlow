# Spec: hardening

## ADDED Requirements

### Requirement: SSF-HARDENING-001 Parent hardening program

The system MUST define a parent change for workflow hardening instead of adding unrelated scope to `workflow-scale-architecture`.

#### Scenario: agent plans hardening work
- GIVEN the hardening work spans routing, evidence, install, validators, backlog, and release templates
- WHEN the agent prepares OpenSpec contracts
- THEN the parent change lists the child changes and dependency order
- AND `workflow-scale-architecture` remains scoped to browser/MCP QA and Spec clusters.

### Requirement: SSF-HARDENING-002 Child changes remain independently verifiable

The system MUST keep each hardening child independently testable.

#### Scenario: maintainer reviews child work
- GIVEN a child change exists
- WHEN the maintainer checks its tasks and spec-to-code map
- THEN the child has focused files, tests, and status evidence.

## MUST NOT

- SSF-HARDENING-N1 The system MUST NOT merge all hardening work into one unbounded implementation change.
- SSF-HARDENING-N2 The system MUST NOT redefine `workflow-scale-architecture` to cover this hardening program.
