# Spec to Code Map: change-backlog-status-cleanup

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SSF-BACKLOG-001 | Existing change status ledger | `openspec/change-ledger.md`, `scripts/validate-change-ledger.sh` | `tests/evidence/test_evidence_lifecycle_contract.bats`, `rtk bash scripts/validate-pack.sh` | Implemented |
| SSF-BACKLOG-002 | Workflow-scale evidence refresh | `openspec/change-ledger.md` | `rtk bash scripts/validate-pack.sh` | Implemented |

## MUST NOT 覆盖

| MUST NOT ID | Guard | Tests |
|---|---|---|
| SSF-BACKLOG-N1 | Archive status requires archive evidence or explicit rationale | `scripts/validate-change-ledger.sh`, `tests/evidence/test_evidence_lifecycle_contract.bats` |
