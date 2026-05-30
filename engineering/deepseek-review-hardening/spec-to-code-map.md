# Spec to Code Map: deepseek-review-hardening

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SSF-DEEPSEEK-001 | Pack validation temp files | `scripts/validate-pack.sh` | `tests/review/test_deepseek_review_hardening.bats` | Implemented |
| SSF-DEEPSEEK-002 | Portable root instruction entry | `AGENTS.md`, `scripts/validate-pack.sh` | `tests/review/test_deepseek_review_hardening.bats`, `tests/routing/test_root_entry_thin_contract.bats` | Implemented |
| SSF-DEEPSEEK-003 | Command contract coverage | `commands/ssf-branch.md`, `commands/ssf-decision.md`, `commands/ssf-map.md` | `tests/review/test_deepseek_review_hardening.bats` | Implemented |
| SSF-DEEPSEEK-004 | Compatibility dependencies | `docs/compatibility.md` | `tests/review/test_deepseek_review_hardening.bats` | Implemented |
| SSF-DEEPSEEK-005 | Documentation naming consistency | `README.md` | `tests/review/test_deepseek_review_hardening.bats` | Implemented |
| SSF-DEEPSEEK-006 | Research document organization | `docs/research/three-stage-review-poc-2026-05-24.md` | `tests/review/test_deepseek_review_hardening.bats` | Implemented |
| SSF-DEEPSEEK-007 | Automated quality gates | `.github/workflows/validate.yml`, `scripts/validate-pack.sh` | `tests/review/test_deepseek_review_hardening.bats` | Implemented |
| SSF-DEEPSEEK-008 | Change ledger status hygiene | `openspec/change-ledger.md`, `scripts/validate-change-ledger.sh`, `scripts/validate-pack.sh` | `tests/review/test_deepseek_review_hardening.bats`, `tests/evidence/test_evidence_lifecycle_contract.bats` | Implemented |

## MUST NOT 覆盖

| MUST NOT ID | Guard | Tests |
|---|---|---|
| SSF-DEEPSEEK-N1 | No hardcoded shared diff temp path | `tests/review/test_deepseek_review_hardening.bats` |
| SSF-DEEPSEEK-N2 | No user absolute root include | `tests/review/test_deepseek_review_hardening.bats`, `scripts/validate-pack.sh` |
| SSF-DEEPSEEK-N3 | Ledger records gaps instead of fabricating historical evidence | `openspec/change-ledger.md`, `tests/review/test_deepseek_review_hardening.bats` |
