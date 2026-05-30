# Tasks: evidence-lifecycle-root-routing

- [x] T1: Add failing root thin-entry tests
  - Spec: SSF-EVIDENCE-001
  - Files: `tests/routing/test_root_entry_thin_contract.bats`
  - Test: `rtk bats tests/routing/test_root_entry_thin_contract.bats`
  - Acceptance: Tests fail before root files and validation are updated.

- [x] T2: Add intake and ledger tests
  - Spec: SSF-EVIDENCE-002, SSF-EVIDENCE-003
  - Files: `tests/evidence/test_evidence_lifecycle_contract.bats`
  - Test: `rtk bats tests/evidence/test_evidence_lifecycle_contract.bats`
  - Acceptance: Tests require intake path, init namespace, and ledger coverage.

- [x] T3: Thin root files and add lifecycle artifacts
  - Spec: SSF-EVIDENCE-001, SSF-EVIDENCE-002, SSF-EVIDENCE-003
  - Files: `AGENTS.md`, `CLAUDE.md`, `templates/intake-gate.md`, `scripts/_ssf_init_apply.sh`, `openspec/change-ledger.md`
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: Root files no longer duplicate complete routing and ledger covers all changes.
