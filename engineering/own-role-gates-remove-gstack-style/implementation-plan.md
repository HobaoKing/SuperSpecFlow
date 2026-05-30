# Implementation Plan: own-role-gates-remove-gstack-style

**Goal:** Remove runtime gstack recommended-method wording while preserving SuperSpecFlow-owned role gates.

**Architecture:** Add boundary tests first, then update runtime wording and validation. Keep source attribution in `NOTICE.md` and README design-source section.

**Spec Contract:** `openspec/changes/own-role-gates-remove-gstack-style/specs/`

**Tech Stack:** Markdown workflow files, Bash validation, BATS tests.

---

## Scope Check

- In scope:
  - Runtime wording in routing, skills, commands, agents, root instructions, README.
  - Validation for gstack attribution boundary.
  - Spec-to-code map.
- Out of scope:
  - Removing source attribution from `NOTICE.md`.
  - Replacing role gates with a different workflow.

## File Structure

- Create: `tests/routing/test_role_gate_source_boundary.bats` — verifies execution files do not recommend gstack style.
- Modify: `scripts/validate-pack.sh` — adds pack-level attribution boundary validation.
- Modify: `AGENTS.md`, `CLAUDE.md`, `routing/*.routing.md`, `skills/ssf-*.md`, `README.md` — replaces runtime attribution.
- Create: `engineering/own-role-gates-remove-gstack-style/spec-to-code-map.md` — records implementation mapping.

## Bite-Sized Tasks

### Task 1: Boundary Tests

**Spec:** SSF-ROLE-GATE-001, SSF-ROLE-GATE-002, SSF-ROLE-GATE-003, SSF-ROLE-GATE-N1

- [x] **Step 1: 写失败测试**
  Add BATS assertions that runtime files reject execution-level gstack phrases and source files allow attribution.
- [x] **Step 2: 跑测试确认失败**
  Run: `rtk bats tests/routing/test_role_gate_source_boundary.bats`
  Expected: FAIL because runtime files still contain gstack execution wording.
- [x] **Step 3: 写最小实现**
  Add `check_gstack_attribution_boundary` to `scripts/validate-pack.sh`.
- [x] **Step 4: 跑测试确认通过**
  Run: `rtk bats tests/routing/test_role_gate_source_boundary.bats`
  Expected: PASS after wording updates.
- [x] **Step 5: 准备 Git gate**
  Run: `rtk git diff --check`

### Task 2: Runtime Wording

**Spec:** SSF-ROLE-GATE-001, SSF-ROLE-GATE-N2

- [x] **Step 1: 写失败测试**
  Ensure validation fails on `gstack 风格`, `gstack 能力`, and related phrases in runtime files.
- [x] **Step 2: 跑测试确认失败**
  Run: `rtk bash scripts/validate-pack.sh`
  Expected: FAIL before wording changes.
- [x] **Step 3: 写最小实现**
  Replace runtime wording with `SuperSpecFlow 角色门禁` language.
- [x] **Step 4: 跑测试确认通过**
  Run: `rtk bash scripts/validate-pack.sh`
  Expected: PASS.
- [x] **Step 5: 准备 Git gate**
  Run: `rtk git diff --stat && rtk git diff --check`

## Plan Review Loop

Reviewed by prior sub-agent analysis; no separate Claude review available because external Claude escalation was denied.

## Execution Handoff

Implement inline with TDD because changes touch shared workflow files and require integrated validation.
