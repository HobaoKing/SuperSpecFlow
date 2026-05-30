# Implementation Plan: strengthen-superpowers-spec-plans

**Goal:** Make spec readiness and implementation plans consistently enforce Superpowers discipline.

**Architecture:** Add Superpowers contract tests, then update spec/build templates and instructions so generated artifacts match the strong workflow.

**Spec Contract:** `openspec/changes/strengthen-superpowers-spec-plans/specs/`

**Tech Stack:** Markdown workflow files, Bash validation, BATS tests.

---

## Scope Check

- In scope:
  - Spec readiness context/review evidence.
  - Strong implementation plan template and build instructions.
  - Commands, agents, routing, README synchronization.
  - Pack validation checks.
- Out of scope:
  - Rewriting historical implementation plans.
  - Adding a real external reviewer integration.

## File Structure

- Create: `tests/workflow/test_spec_discipline_contract.bats` — spec-stage contract tests.
- Create: `tests/workflow/test_implementation_plan_contract.bats` — plan-template contract tests.
- Modify: `templates/spec-readiness-review.md`, `templates/implementation-plan.md`.
- Modify: `skills/ssf-spec/SKILL.md`, `skills/ssf-build/SKILL.md`, `commands/ssf-spec.md`, `commands/ssf-build.md`.
- Modify: `agents/spec-architect.md`, `agents/implementation-engineer.md`, `routing/*.routing.md`, `README.md`.
- Modify: `scripts/validate-pack.sh`.

## Bite-Sized Tasks

### Task 1: Spec Discipline Contract

**Spec:** SSF-SUPERPOWERS-SPEC-001, SSF-SUPERPOWERS-SPEC-002, SSF-SUPERPOWERS-SPEC-003, SSF-SUPERPOWERS-N1

- [x] **Step 1: 写失败测试**
  Add BATS checks for brainstorming context, assumptions, alternatives, open-question disposition, reviewer result, and blocked/waived evidence.
- [x] **Step 2: 跑测试确认失败**
  Run: `rtk bats tests/workflow/test_spec_discipline_contract.bats`
  Expected: FAIL because current templates/instructions are incomplete.
- [x] **Step 3: 写最小实现**
  Update spec skill, command, agent, routing, README, readiness template, and validation.
- [x] **Step 4: 跑测试确认通过**
  Run: `rtk bats tests/workflow/test_spec_discipline_contract.bats`
  Expected: PASS.
- [x] **Step 5: 准备 Git gate**
  Run: `rtk git diff --check`

### Task 2: Implementation Plan Contract

**Spec:** SSF-SUPERPOWERS-PLAN-001, SSF-SUPERPOWERS-PLAN-002, SSF-SUPERPOWERS-PLAN-003, SSF-SUPERPOWERS-N2

- [x] **Step 1: 写失败测试**
  Add BATS checks for the strong plan header, file structure, bite-sized TDD steps, plan review loop, and execution handoff.
- [x] **Step 2: 跑测试确认失败**
  Run: `rtk bats tests/workflow/test_implementation_plan_contract.bats`
  Expected: FAIL because current `templates/implementation-plan.md` is thin.
- [x] **Step 3: 写最小实现**
  Rewrite implementation plan template and synchronize build command/agent/routing/docs.
- [x] **Step 4: 跑测试确认通过**
  Run: `rtk bats tests/workflow/test_implementation_plan_contract.bats`
  Expected: PASS.
- [x] **Step 5: 准备 Git gate**
  Run: `rtk git diff --stat && rtk git diff --check`

## Plan Review Loop

Reviewed by prior sub-agent analysis; Claude review unavailable due API failure and escalation denial.

## Execution Handoff

Implement inline with targeted contract tests, then run pack validation.
