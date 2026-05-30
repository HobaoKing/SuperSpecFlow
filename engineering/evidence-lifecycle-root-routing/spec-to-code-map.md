# Spec to Code Map: evidence-lifecycle-root-routing

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SSF-EVIDENCE-001 | Thin root instruction files | `AGENTS.md`, `CLAUDE.md`, `scripts/validate-pack.sh` | `tests/routing/test_root_entry_thin_contract.bats` | Implemented |
| SSF-EVIDENCE-002 | Intake artifact namespace | `templates/intake-gate.md`, `scripts/_ssf_init_apply.sh`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `README.md`, `docs/installation.md` | `tests/evidence/test_evidence_lifecycle_contract.bats`, `tests/init/test_ssf_init_zero_touch.bats`, `tests/artifacts/test_artifact_path_contract.bats` | Implemented |
| SSF-EVIDENCE-003 | Package change ledger | `openspec/change-ledger.md`, `scripts/validate-change-ledger.sh`, `scripts/validate-pack.sh` | `tests/evidence/test_evidence_lifecycle_contract.bats` | Implemented |

## MUST NOT 覆盖

| MUST NOT ID | Guard | Tests |
|---|---|---|
| SSF-EVIDENCE-N1 | Root files reject duplicated routing content | `tests/routing/test_root_entry_thin_contract.bats` |
| SSF-EVIDENCE-N2 | `.superspecflow/` remains ignored and untracked | `tests/artifacts/test_artifact_path_contract.bats`, `scripts/validate-pack.sh` |
| SSF-EVIDENCE-N3 | Ledger described as summary only | `openspec/change-ledger.md` |
