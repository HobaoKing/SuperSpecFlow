# Spec to Code Map: template-skill-usability-polish

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SSF-USABILITY-001 | Skeletal template guidance | `templates/acceptance-matrix.md`, `templates/proposal.md`, `templates/design.md`, `templates/risk-matrix.md`, `templates/negative-test-matrix.md`, `templates/spec-to-code-map.md`, `templates/sync-check.md`, `templates/tasks.md`, `tests/usability/test_template_skill_usability.bats`, `scripts/validate-pack.sh` | `rtk bats tests/usability/test_template_skill_usability.bats`; `rtk bash scripts/validate-pack.sh` | Implemented |
| SSF-USABILITY-002 | Build skill cross-reference | `skills/ssf-build/SKILL.md`, `tests/usability/test_template_skill_usability.bats`, `scripts/validate-pack.sh` | `rtk bats tests/usability/test_template_skill_usability.bats`; existing git/artifact/plan contract Bats | Implemented |
| SSF-USABILITY-003 | Retro probing questions | `skills/ssf-retro/SKILL.md`, `tests/usability/test_template_skill_usability.bats`, `scripts/validate-pack.sh` | `rtk bats tests/usability/test_template_skill_usability.bats`; `rtk bash scripts/validate-pack.sh` | Implemented |
| SSF-USABILITY-004 | Archive continuation consistency | `skills/ssf-archive/SKILL.md`, `tests/usability/test_template_skill_usability.bats`, `scripts/validate-pack.sh` | `rtk bats tests/usability/test_template_skill_usability.bats`; `rtk bash scripts/validate-pack.sh` | Implemented |
