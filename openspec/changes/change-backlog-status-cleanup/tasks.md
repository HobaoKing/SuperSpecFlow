# Tasks: change-backlog-status-cleanup

- [x] T1: Add all current changes to the ledger
  - Spec: SSF-BACKLOG-001
  - Files: `openspec/change-ledger.md`
  - Test: `rtk bats tests/evidence/test_evidence_lifecycle_contract.bats`
  - Acceptance: Every current `openspec/changes/*` directory has a ledger row.

- [x] T2: Refresh stale workflow-scale evidence wording
  - Spec: SSF-BACKLOG-002
  - Files: `openspec/change-ledger.md`
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: Ledger notes that `browser-mcp-qa-adapter` and `parallel-worktree-spec-clusters` are implemented rather than pending.
