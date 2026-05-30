# Spec to Code Map: workflow-hardening-program

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SSF-HARDENING-001 | Parent hardening program | `openspec/changes/workflow-hardening-program/` | `rtk bash scripts/validate-pack.sh` | Implemented |
| SSF-HARDENING-002 | Child changes remain independently verifiable | `openspec/changes/evidence-lifecycle-root-routing/`, `openspec/changes/install-host-portability/`, `openspec/changes/runtime-gate-validators/`, `openspec/changes/change-backlog-status-cleanup/`, `openspec/changes/high-risk-release-template-hardening/` | `rtk bash scripts/test.sh` | Implemented |

## MUST NOT 覆盖

| MUST NOT ID | Guard | Tests |
|---|---|---|
| SSF-HARDENING-N1 | Child changes split independent scopes | `openspec/changes/workflow-hardening-program/proposal.md` |
| SSF-HARDENING-N2 | Existing workflow-scale parent not repurposed | `openspec/change-ledger.md` |
