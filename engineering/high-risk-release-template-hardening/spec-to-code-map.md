# Spec to Code Map: high-risk-release-template-hardening

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SSF-HIGH-RISK-001 | Structured risk matrix fields | `templates/risk-matrix.md`, `scripts/validate-pack.sh` | `tests/release/test_high_risk_release_templates.bats` | Implemented |
| SSF-HIGH-RISK-002 | Rollback and monitoring drill fields | `templates/rollback-plan.md`, `templates/monitoring-plan.md`, `scripts/validate-pack.sh` | `tests/release/test_high_risk_release_templates.bats` | Implemented |

## MUST NOT 覆盖

| MUST NOT ID | Guard | Tests |
|---|---|---|
| SSF-HIGH-RISK-N1 | High-risk templates require owner and detection fields | `tests/release/test_high_risk_release_templates.bats` |
