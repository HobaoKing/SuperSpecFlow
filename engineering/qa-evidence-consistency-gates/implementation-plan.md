# Implementation Plan: qa-evidence-consistency-gates

**Goal:** Prevent QA false-pass states by adding evidence consistency gates.

**Architecture:** Add fixture-based BATS tests for browser, visual, derivation, and parent cluster QA consistency, then update templates and instructions to satisfy those contracts.

**Spec Contract:** `openspec/changes/qa-evidence-consistency-gates/specs/`

**Tech Stack:** Markdown workflow files, Bash validation, BATS tests with temporary fixtures.

---

## Scope Check

- In scope:
  - Browser/MCP QA status consistency.
  - Visual UI QA status consistency.
  - Acceptance matrix derivation guidance and tests.
  - Parent cluster QA summary gate.
- Out of scope:
  - Real browser execution.
  - Real image diff algorithm.
  - Tracking `.superspecflow/` runtime artifacts in Git.

## File Structure

- Create: `tests/qa/test_browser_mcp_qa_state_consistency.bats`.
- Create: `tests/qa/test_visual_ui_qa_state_consistency.bats`.
- Create: `tests/qa/test_qa_plan_derivation_contract.bats`.
- Create: `tests/clusters/test_parent_cluster_qa_summary_contract.bats`.
- Modify: `templates/qa-signoff.md`, `templates/browser-run-report.md`, `templates/visual-comparison-report.md`, `templates/integration-gate.md`.
- Modify: `skills/ssf-qa/SKILL.md`, `skills/ssf-ship/SKILL.md`, `agents/qa-gatekeeper.md`, `agents/release-manager.md`, routing, README.
- Modify: `scripts/validate-pack.sh`.

## Bite-Sized Tasks

### Task 1: Browser QA Consistency

**Spec:** SSF-QA-EVIDENCE-BROWSER-001, SSF-QA-EVIDENCE-BROWSER-002, SSF-QA-EVIDENCE-N1, SSF-QA-EVIDENCE-N2

- [x] **Step 1: 写失败测试**
  Add fixture tests where passed browser status lacks evidence, target, tool, or has failed journey.
- [x] **Step 2: 跑测试确认失败**
  Run: `rtk bats tests/qa/test_browser_mcp_qa_state_consistency.bats`
  Expected: FAIL before consistency language/helpers exist.
- [x] **Step 3: 写最小实现**
  Add template and instruction consistency fields/rules.
- [x] **Step 4: 跑测试确认通过**
  Run: `rtk bats tests/qa/test_browser_mcp_qa_state_consistency.bats`
  Expected: PASS.
- [x] **Step 5: 准备 Git gate**
  Run: `rtk git diff --check`

### Task 2: Visual QA Consistency

**Spec:** SSF-QA-EVIDENCE-VISUAL-001, SSF-QA-EVIDENCE-VISUAL-002, SSF-QA-EVIDENCE-N3, SSF-QA-EVIDENCE-N4

- [x] **Step 1: 写失败测试**
  Add fixture tests for visual pass without baseline approval, actual screenshot, diff result, report, or evidence.
- [x] **Step 2: 跑测试确认失败**
  Run: `rtk bats tests/qa/test_visual_ui_qa_state_consistency.bats`
  Expected: FAIL before consistency rules are present.
- [x] **Step 3: 写最小实现**
  Add template and instruction consistency fields/rules.
- [x] **Step 4: 跑测试确认通过**
  Run: `rtk bats tests/qa/test_visual_ui_qa_state_consistency.bats`
  Expected: PASS.
- [x] **Step 5: 准备 Git gate**
  Run: `rtk git diff --check`

### Task 3: Derivation and Parent Cluster Gates

**Spec:** SSF-QA-EVIDENCE-DERIVE-001, SSF-QA-EVIDENCE-DERIVE-002, SSF-QA-EVIDENCE-CLUSTER-001, SSF-QA-EVIDENCE-N5, SSF-QA-EVIDENCE-N6

- [x] **Step 1: 写失败测试**
  Add derivation and parent cluster summary fixture tests.
- [x] **Step 2: 跑测试确认失败**
  Run: `rtk bats tests/qa/test_qa_plan_derivation_contract.bats tests/clusters/test_parent_cluster_qa_summary_contract.bats`
  Expected: FAIL before templates/instructions expose the stronger rules.
- [x] **Step 3: 写最小实现**
  Update QA and integration-gate templates/instructions.
- [x] **Step 4: 跑测试确认通过**
  Run: `rtk bats tests/qa/test_qa_plan_derivation_contract.bats tests/clusters/test_parent_cluster_qa_summary_contract.bats`
  Expected: PASS.
- [x] **Step 5: 准备 Git gate**
  Run: `rtk git diff --stat && rtk git diff --check`

## Plan Review Loop

Reviewed by prior QA sub-agent analysis; Claude review unavailable due API failure and escalation denial.

## Execution Handoff

Implement inline with fixture tests and pack validation.
