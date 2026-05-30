# Spec: high-risk release gates

## ADDED Requirements

### Requirement: SSF-HIGH-RISK-001 Structured risk matrix fields

The system MUST include owner, mitigation, detection, waiver, and residual risk fields in the risk matrix template.

#### Scenario: high-risk change is prepared
- GIVEN a change involves payment, auth, data, security, or production release
- WHEN QA creates a risk matrix
- THEN the matrix captures ownership, mitigation, detection, waiver, and residual risk.

### Requirement: SSF-HIGH-RISK-002 Rollback and monitoring drill fields

The system MUST include rollback drill and alert ownership fields.

#### Scenario: release manager prepares ship gate
- GIVEN a high-risk release is being evaluated
- WHEN rollback and monitoring plans are created
- THEN the plans identify decision owners, detection queries, alert owners, and rollback drill evidence.

## MUST NOT

- SSF-HIGH-RISK-N1 High-risk templates MUST NOT rely only on generic notes without ownership and detection fields.
