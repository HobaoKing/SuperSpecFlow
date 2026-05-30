# Tasks: high-risk-release-template-hardening

- [x] T1: Add failing high-risk template tests
  - Spec: SSF-HIGH-RISK-001
  - Files: `tests/release/test_high_risk_release_templates.bats`
  - Test: `rtk bats tests/release/test_high_risk_release_templates.bats`
  - Acceptance: Tests fail until templates and validation include required fields.

- [x] T2: Expand templates and validation
  - Spec: SSF-HIGH-RISK-001, SSF-HIGH-RISK-002
  - Files: `templates/risk-matrix.md`, `templates/rollback-plan.md`, `templates/monitoring-plan.md`, `scripts/validate-pack.sh`
  - Test: `rtk bats tests/release/test_high_risk_release_templates.bats`
  - Acceptance: High-risk template fields are present and pack validation checks them.
