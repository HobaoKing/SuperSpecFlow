# Tasks: clarify-superspecflow-layer-boundary

- [x] T1: Add failing layer-boundary routing tests
  - Spec: SSF-LAYER-001, SSF-LAYER-002, SSF-LAYER-003, SSF-LAYER-004, SSF-LAYER-005, SSF-LAYER-006, SSF-LAYER-N1, SSF-LAYER-N3
  - Files: `tests/routing/test_role_gate_source_boundary.bats`, `scripts/validate-pack.sh`
  - Test: `rtk bats tests/routing/test_role_gate_source_boundary.bats`
  - Acceptance: Tests fail on the current `SuperSpecFlow 角色门禁` framing and require the three layer labels.
  - Estimate: 35 min

- [x] T2: Replace runtime role-gate framing with layer-boundary framing
  - Spec: SSF-LAYER-001, SSF-LAYER-002, SSF-LAYER-003, SSF-LAYER-004, SSF-LAYER-N1, SSF-LAYER-N2
  - Files: `README.md`, `AGENTS.md`, `CLAUDE.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `skills/ssf-think/SKILL.md`, `skills/ssf-review/SKILL.md`, `skills/ssf-ship/SKILL.md`, `skills/ssf-git/SKILL.md`, `skills/ssf-karpathy/SKILL.md`, `docs/installation.md`, `docs/compatibility.md`
  - Test: `rtk bats tests/routing/test_role_gate_source_boundary.bats`
  - Acceptance: Runtime guidance names OpenSpec/Superpowers/SuperSpecFlow layers correctly while preserving phase checks.
  - Estimate: 75 min

- [x] T3: Update pack validation for the layer boundary
  - Spec: SSF-LAYER-005, SSF-LAYER-006, SSF-LAYER-N1, SSF-LAYER-N3
  - Files: `scripts/validate-pack.sh`
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: Pack validation rejects old role-gate framing, requires new layer labels, and still enforces the gstack attribution boundary.
  - Estimate: 35 min

- [x] T4: Record supersession of old role-gate contract
  - Spec: SSF-LAYER-003, SSF-LAYER-005, SSF-LAYER-N1
  - Files: `openspec/changes/own-role-gates-remove-gstack-style/specs/role-gates.md`, `engineering/own-role-gates-remove-gstack-style/spec-to-code-map.md`, `engineering/clarify-superspecflow-layer-boundary/spec-to-code-map.md`
  - Test: `rtk rg -n "Superseded|SSF-LAYER" openspec/changes/own-role-gates-remove-gstack-style engineering/own-role-gates-remove-gstack-style engineering/clarify-superspecflow-layer-boundary`
  - Acceptance: Historical change remains auditable but no longer requires runtime `SuperSpecFlow 角色门禁` wording.
  - Estimate: 30 min

- [x] T5: Run full verification and update task status
  - Spec: SSF-LAYER-005, SSF-LAYER-006
  - Files: `openspec/changes/clarify-superspecflow-layer-boundary/tasks.md`
  - Test: `rtk bats tests/routing/test_role_gate_source_boundary.bats`, `rtk bash scripts/validate-pack.sh`
  - Acceptance: Targeted tests and pack validation pass; task checklist reflects completed work.
  - Estimate: 20 min

- [x] T6: Address opencode conditional review feedback
  - Spec: SSF-LAYER-007, SSF-LAYER-008
  - Files: `README.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `tests/routing/test_role_gate_source_boundary.bats`, `scripts/validate-pack.sh`, `engineering/clarify-superspecflow-layer-boundary/consultation-notes.md`, `engineering/clarify-superspecflow-layer-boundary/spec-to-code-map.md`
  - Test: `rtk bats tests/routing/test_role_gate_source_boundary.bats`, `rtk bash scripts/validate-pack.sh`
  - Acceptance: Runtime docs define routing input/output and Superpowers discipline traceability; validation checks those positive contract markers.
  - Estimate: 35 min
