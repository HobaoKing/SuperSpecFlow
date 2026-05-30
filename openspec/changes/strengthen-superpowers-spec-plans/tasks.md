# Tasks: strengthen-superpowers-spec-plans

- [x] T1: Add Superpowers spec discipline contract tests
  - Spec: SSF-SUPERPOWERS-SPEC-001, SSF-SUPERPOWERS-SPEC-002, SSF-SUPERPOWERS-SPEC-003, SSF-SUPERPOWERS-TEST-001, SSF-SUPERPOWERS-N1
  - Files: `tests/workflow/test_spec_discipline_contract.bats`, `scripts/validate-pack.sh`
  - Test: `rtk bats tests/workflow/test_spec_discipline_contract.bats`, `rtk bash scripts/validate-pack.sh`
  - Acceptance: Tests fail when spec instructions/templates omit brainstorming context, assumptions, alternatives, open-question disposition, reviewer result, or blocked/waived evidence.
  - Estimate: 45 min

- [x] T2: Strengthen spec stage instructions and readiness template
  - Spec: SSF-SUPERPOWERS-SPEC-001, SSF-SUPERPOWERS-SPEC-002, SSF-SUPERPOWERS-SPEC-003, SSF-SUPERPOWERS-N1
  - Files: `skills/ssf-spec/SKILL.md`, `commands/ssf-spec.md`, `agents/spec-architect.md`, `templates/spec-readiness-review.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `README.md`
  - Test: `rtk bats tests/workflow/test_spec_discipline_contract.bats`
  - Acceptance: Spec readiness requires brainstorming context or explicit waiver, and review evidence is visible across skill, command, agent, routing, template, and docs.
  - Estimate: 60 min

- [x] T3: Add implementation plan contract tests
  - Spec: SSF-SUPERPOWERS-PLAN-001, SSF-SUPERPOWERS-PLAN-002, SSF-SUPERPOWERS-PLAN-003, SSF-SUPERPOWERS-TEST-001, SSF-SUPERPOWERS-N2
  - Files: `tests/workflow/test_implementation_plan_contract.bats`, `scripts/validate-pack.sh`
  - Test: `rtk bats tests/workflow/test_implementation_plan_contract.bats`, `rtk bash scripts/validate-pack.sh`
  - Acceptance: Tests fail when the implementation plan template or instructions omit strong writing-plans sections and TDD five-step structure.
  - Estimate: 45 min

- [x] T4: Strengthen implementation plan template and build instructions
  - Spec: SSF-SUPERPOWERS-PLAN-001, SSF-SUPERPOWERS-PLAN-002, SSF-SUPERPOWERS-PLAN-003, SSF-SUPERPOWERS-N2
  - Files: `templates/implementation-plan.md`, `skills/ssf-build/SKILL.md`, `commands/ssf-build.md`, `agents/implementation-engineer.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `README.md`
  - Test: `rtk bats tests/workflow/test_implementation_plan_contract.bats`
  - Acceptance: Generated plans are required to include goal, architecture, spec contract, file structure, bite-sized TDD steps, plan review loop, and execution handoff.
  - Estimate: 60 min

- [x] T5: Update map and run full validation
  - Spec: SSF-SUPERPOWERS-TEST-001
  - Files: `engineering/strengthen-superpowers-spec-plans/spec-to-code-map.md`
  - Test: `rtk bash scripts/validate-pack.sh`, `rtk bats tests/workflow/test_spec_discipline_contract.bats tests/workflow/test_implementation_plan_contract.bats`
  - Acceptance: Spec-to-code map records every requirement and targeted validation passes.
  - Estimate: 25 min
