# Spec: superpowers-spec-plans

## ADDED Requirements

### Requirement: SSF-SUPERPOWERS-SPEC-001 Spec stage preserves brainstorming context

The spec stage MUST preserve upstream thinking context or explicitly record why it is waived before declaring a change ready.

#### Scenario: Upstream think output exists
- GIVEN `ssf-think` or equivalent brainstorming output exists
- WHEN `/ssf-spec <change-id>` runs
- THEN the spec process references the upstream source
- AND records goal, assumptions, alternatives, non-goals, and open questions

#### Scenario: Upstream think output is missing
- GIVEN no upstream brainstorming context exists
- WHEN the agent prepares an OpenSpec change
- THEN it records a waiver reason or asks one key question
- AND it does not silently claim full readiness

### Requirement: SSF-SUPERPOWERS-SPEC-002 Spec readiness includes Superpowers review evidence

Spec readiness review MUST include assumptions, alternatives, open-question disposition, testability, and reviewer evidence.

#### Scenario: Spec readiness is written
- GIVEN proposal, specs, design, and tasks exist
- WHEN the agent writes spec readiness review
- THEN it includes brainstorming context, assumption audit, alternatives considered, open questions disposition, reviewer result, and blocked or waived evidence

### Requirement: SSF-SUPERPOWERS-SPEC-003 Spec document review loop has fallback evidence

The spec document review loop MUST record reviewer result, iteration count, and fallback evidence when the reviewer is unavailable.

#### Scenario: Reviewer approves
- GIVEN a reviewer is available
- WHEN the reviewer approves the spec
- THEN readiness review records the reviewer result and evidence

#### Scenario: Reviewer unavailable
- GIVEN no reviewer tool or prompt is available
- WHEN the agent cannot run the review loop
- THEN it records `Blocked` or `Waived` evidence
- AND explains residual risk

### Requirement: SSF-SUPERPOWERS-PLAN-001 Implementation plan template matches strong plan structure

The implementation plan template MUST include the strong plan sections required by the build skill.

#### Scenario: Agent opens implementation plan template
- GIVEN the agent needs to create an implementation plan
- WHEN it reads `templates/implementation-plan.md`
- THEN the template includes goal, architecture, spec contract, tech stack, scope check, file structure, bite-sized tasks, plan review loop, and execution handoff

### Requirement: SSF-SUPERPOWERS-PLAN-002 Implementation tasks use executable TDD steps

Each implementation task MUST require complete TDD steps with concrete commands and expected failure/pass evidence.

#### Scenario: Agent creates a task plan
- GIVEN a task maps to a Spec ID
- WHEN the task is written in an implementation plan
- THEN it includes `Step 1: 写失败测试`
- AND `Step 2` includes a concrete command and `Expected: FAIL with`
- AND `Step 3` requires minimal implementation
- AND `Step 4` includes a concrete command and `Expected: PASS`
- AND `Step 5` prepares Git gate without committing directly

### Requirement: SSF-SUPERPOWERS-PLAN-003 Plan review loop is synchronized

Plan review loop requirements MUST appear in the template, build skill, build command, implementation agent, routing, and README.

#### Scenario: Maintainer validates the pack
- GIVEN all workflow files are present
- WHEN validation runs
- THEN it verifies plan review loop language across the relevant files

### Requirement: SSF-SUPERPOWERS-TEST-001 Validation prevents spec/plan discipline drift

The pack MUST include tests and validation checks that fail when Superpowers spec or plan discipline is weakened.

#### Scenario: Template loses TDD steps
- GIVEN `templates/implementation-plan.md` omits `Expected: FAIL with`
- WHEN validation runs
- THEN validation fails

#### Scenario: Spec readiness loses assumptions
- GIVEN `templates/spec-readiness-review.md` omits assumption audit
- WHEN validation runs
- THEN validation fails

## MODIFIED Requirements

无。

## REMOVED Requirements

无。

## MUST NOT

- SSF-SUPERPOWERS-N1 The system MUST NOT declare a non-trivial spec ready without brainstorming context or explicit waiver evidence.
- SSF-SUPERPOWERS-N2 The system MUST NOT generate a thin implementation plan that only lists task order and test strategy without executable TDD steps and review loop.

## MUST NOT Violation Signals

| MUST NOT | 可观察违规现象 |
|---|---|
| SSF-SUPERPOWERS-N1 | `spec-readiness-review.md` has Ready recommendation but no brainstorming context, assumptions, alternatives, or waiver. |
| SSF-SUPERPOWERS-N2 | `templates/implementation-plan.md` lacks bite-sized TDD steps, expected fail/pass commands, or plan review loop. |
