# Spec to Code Map: routing-docs-drift-reduction

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SSF-DRIFT-001 | Routing drift guard | `routing/default.routing.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `scripts/validate-pack.sh`, `tests/routing/test_root_entry_thin_contract.bats` | `rtk bats tests/routing/test_root_entry_thin_contract.bats`; `rtk bash scripts/validate-pack.sh` | Implemented |
| SSF-DRIFT-002 | README quick install focus | `README.md`, `tests/docs/test_docs_drift_reduction.bats`, `scripts/validate-pack.sh` | `rtk bats tests/docs/test_docs_drift_reduction.bats`; `rtk bash scripts/validate-pack.sh` | Implemented |
| SSF-DRIFT-003 | Legacy symlink appendix | `docs/installation.md`, `tests/docs/test_docs_drift_reduction.bats`, `scripts/validate-pack.sh` | `rtk bats tests/docs/test_docs_drift_reduction.bats`; `rtk bash scripts/validate-pack.sh` | Implemented |
| SSF-DRIFT-004 | Workflow-scale status refresh | `engineering/workflow-scale-architecture/spec-to-code-map.md`, `tests/docs/test_docs_drift_reduction.bats`, `scripts/validate-pack.sh` | `rtk bats tests/docs/test_docs_drift_reduction.bats`; `rtk bash scripts/validate-pack.sh` | Implemented |
