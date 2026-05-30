# Tasks: template-skill-usability-polish

- [x] T1: Add template guidance tests
  - Spec: SSF-USABILITY-001
  - Files: focused Bats tests
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: skeletal templates contain local guidance markers.

- [x] T2: Add light guidance to skeletal templates
  - Spec: SSF-USABILITY-001
  - Files: `templates/acceptance-matrix.md`, `templates/proposal.md`, `templates/design.md`, `templates/risk-matrix.md`, `templates/negative-test-matrix.md`, `templates/spec-to-code-map.md`, `templates/sync-check.md`, `templates/tasks.md`
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: templates guide agents without bloating.

- [x] T3: Thin `ssf-build` duplicated discipline
  - Spec: SSF-USABILITY-002
  - Files: `skills/ssf-build/SKILL.md`
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: build still requires TDD, Spec ID, plan review, progress, and `/ssf-commit` handoff.

- [x] T4: Strengthen `ssf-retro`
  - Spec: SSF-USABILITY-003
  - Files: `skills/ssf-retro/SKILL.md`
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: retro includes probing questions.

- [x] T5: Add archive automatic continuation heading
  - Spec: SSF-USABILITY-004
  - Files: `skills/ssf-archive/SKILL.md`
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: archive has explicit automatic continuation heading/rule.
