# Spec to Code Map: own-role-gates-remove-gstack-style

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SSF-ROLE-GATE-001 | Runtime guidance removes gstack role-gate attribution; SuperSpecFlow-owned role-gate wording superseded by `SSF-LAYER-003` | `AGENTS.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `skills/ssf-think/SKILL.md`, `skills/ssf-review/SKILL.md`, `skills/ssf-ship/SKILL.md`, `skills/ssf-git/SKILL.md`, `skills/ssf-karpathy/SKILL.md`, `README.md` | `tests/routing/test_role_gate_source_boundary.bats`, `rtk bash scripts/validate-pack.sh` | Superseded by `clarify-superspecflow-layer-boundary` for layer wording |
| SSF-ROLE-GATE-002 | Source attribution remains bounded | `README.md`, `NOTICE.md`, `scripts/validate-pack.sh` | `tests/routing/test_role_gate_source_boundary.bats` | Implemented |
| SSF-ROLE-GATE-003 | Validation enforces attribution boundary | `scripts/validate-pack.sh` | `tests/routing/test_role_gate_source_boundary.bats`, `rtk bash scripts/validate-pack.sh` | Implemented |
| SSF-ROLE-GATE-N1 | Runtime instructions do not use gstack execution wording | `scripts/validate-pack.sh`, runtime docs | `tests/routing/test_role_gate_source_boundary.bats` | Implemented |
| SSF-ROLE-GATE-N2 | Proprietary role-gate wording can be removed only if phase checks remain intact | Runtime docs and skills | `tests/routing/test_role_gate_source_boundary.bats` | Superseded by `SSF-LAYER-N2` |
