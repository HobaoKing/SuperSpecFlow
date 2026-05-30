# Tasks: runtime-gate-validators

- [x] T1: Add failing validator tests
  - Spec: SSF-RUNTIME-GATE-001, SSF-RUNTIME-GATE-002
  - Files: `tests/validators/test_runtime_validators.bats`
  - Test: `rtk bats tests/validators/test_runtime_validators.bats`
  - Acceptance: Missing validator scripts fail tests.

- [x] T2: Implement validators and hook delegation
  - Spec: SSF-RUNTIME-GATE-001, SSF-RUNTIME-GATE-002, SSF-RUNTIME-GATE-003
  - Files: `scripts/validate-commit-message.sh`, `scripts/validate-qa-signoff.sh`, `scripts/validate-change-ledger.sh`, `templates/git-hooks/commit-msg`, `scripts/validate-pack.sh`
  - Test: `rtk bats tests/validators/test_runtime_validators.bats`
  - Acceptance: Bad fixtures fail and complete fixtures pass.
