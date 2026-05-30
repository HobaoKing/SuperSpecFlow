# Spec to Code Map: runtime-gate-validators

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SSF-RUNTIME-GATE-001 | Commit message validator | `scripts/validate-commit-message.sh`, `templates/git-hooks/commit-msg` | `tests/validators/test_runtime_validators.bats` | Implemented |
| SSF-RUNTIME-GATE-002 | QA signoff blocked waiver and automated evidence validator | `scripts/validate-qa-signoff.sh` | `tests/validators/test_runtime_validators.bats` | Implemented |
| SSF-RUNTIME-GATE-003 | Change ledger validator | `scripts/validate-change-ledger.sh`, `scripts/validate-pack.sh` | `tests/evidence/test_evidence_lifecycle_contract.bats` | Implemented |

## MUST NOT 覆盖

| MUST NOT ID | Guard | Tests |
|---|---|---|
| SSF-RUNTIME-GATE-N1 | Validators remain structural and do not replace review | `openspec/changes/runtime-gate-validators/specs/validators.md` |
