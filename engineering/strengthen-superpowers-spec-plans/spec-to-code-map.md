# Spec to Code Map: strengthen-superpowers-spec-plans

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SSF-SUPERPOWERS-SPEC-001 | Spec stage preserves brainstorming context | `skills/ssf-spec/SKILL.md`, `commands/ssf-spec.md`, `agents/spec-architect.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `README.md` | `tests/workflow/test_spec_discipline_contract.bats` | Implemented |
| SSF-SUPERPOWERS-SPEC-002 | Spec readiness includes review evidence | `templates/spec-readiness-review.md`, `skills/ssf-spec/SKILL.md` | `tests/workflow/test_spec_discipline_contract.bats` | Implemented |
| SSF-SUPERPOWERS-SPEC-003 | Spec review loop has fallback evidence | `skills/ssf-spec/SKILL.md`, `agents/spec-architect.md`, `templates/spec-readiness-review.md` | `tests/workflow/test_spec_discipline_contract.bats` | Implemented |
| SSF-SUPERPOWERS-PLAN-001 | Implementation plan template matches strong structure | `templates/implementation-plan.md`, `skills/ssf-build/SKILL.md` | `tests/workflow/test_implementation_plan_contract.bats` | Implemented |
| SSF-SUPERPOWERS-PLAN-002 | Tasks use executable TDD steps | `templates/implementation-plan.md`, `commands/ssf-build.md`, `agents/implementation-engineer.md` | `tests/workflow/test_implementation_plan_contract.bats` | Implemented |
| SSF-SUPERPOWERS-PLAN-003 | Plan review loop synchronized | `templates/implementation-plan.md`, `skills/ssf-build/SKILL.md`, `commands/ssf-build.md`, `agents/implementation-engineer.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `README.md` | `tests/workflow/test_implementation_plan_contract.bats`, `rtk bash scripts/validate-pack.sh` | Implemented |
| SSF-SUPERPOWERS-TEST-001 | Validation prevents drift | `scripts/validate-pack.sh` | `tests/workflow/test_spec_discipline_contract.bats`, `tests/workflow/test_implementation_plan_contract.bats` | Implemented |
| SSF-SUPERPOWERS-N1 | No ready spec without context or waiver | `templates/spec-readiness-review.md`, `skills/ssf-spec/SKILL.md` | `tests/workflow/test_spec_discipline_contract.bats` | Implemented |
| SSF-SUPERPOWERS-N2 | No thin implementation plan | `templates/implementation-plan.md`, `scripts/validate-pack.sh` | `tests/workflow/test_implementation_plan_contract.bats` | Implemented |
