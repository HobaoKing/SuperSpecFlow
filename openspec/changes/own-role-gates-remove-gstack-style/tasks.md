# Tasks: own-role-gates-remove-gstack-style

- [x] T1: Add role-gate source-boundary contract tests
  - Spec: SSF-ROLE-GATE-001, SSF-ROLE-GATE-002, SSF-ROLE-GATE-003, SSF-ROLE-GATE-N1
  - Files: `tests/routing/test_role_gate_source_boundary.bats`, `scripts/validate-pack.sh`
  - Test: `rtk bats tests/routing/test_role_gate_source_boundary.bats`, `rtk bash scripts/validate-pack.sh`
  - Acceptance: Tests fail if runtime files use gstack as an execution style, while source attribution remains allowed.
  - Estimate: 35 min

- [x] T2: Replace runtime gstack wording with SuperSpecFlow role gates
  - Spec: SSF-ROLE-GATE-001, SSF-ROLE-GATE-002, SSF-ROLE-GATE-N1, SSF-ROLE-GATE-N2
  - Files: `AGENTS.md`, `CLAUDE.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `skills/ssf-think/SKILL.md`, `skills/ssf-review/SKILL.md`, `skills/ssf-ship/SKILL.md`, `skills/ssf-git/SKILL.md`, `skills/ssf-karpathy/SKILL.md`, `README.md`
  - Test: `rtk rg -n "gstack 风格|gstack 能力|本阶段体现 gstack|gstack 的发布门禁|gstack 三重审判" AGENTS.md CLAUDE.md routing skills commands agents`
  - Acceptance: Runtime guidance uses SuperSpecFlow-owned role-gate wording and no longer recommends gstack style.
  - Estimate: 45 min

- [x] T3: Update source attribution and docs map
  - Spec: SSF-ROLE-GATE-002, SSF-ROLE-GATE-003
  - Files: `README.md`, `NOTICE.md`, `engineering/own-role-gates-remove-gstack-style/spec-to-code-map.md`
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: Attribution remains only in source sections, and spec-to-code map records coverage.
  - Estimate: 20 min
