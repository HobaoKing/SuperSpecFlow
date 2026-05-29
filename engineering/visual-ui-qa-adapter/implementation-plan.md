# Implementation Plan: visual-ui-qa-adapter

**Goal:** Implement the protocol-level visual UI QA adapter for Web and mini-program screenshot comparison evidence.

**Architecture:** Extend the existing QA protocol with two new reusable templates, QA skill/agent/command rules, routing documentation, README overview, contract tests, and pack validation. Keep the implementation protocol-only: no image diff algorithm, no Playwright screenshot runner, and no mini-program runner binding.

**Spec Contract:** `openspec/changes/visual-ui-qa-adapter/specs/`

**Tech Stack:** Markdown workflow files, Bash validation, Bats contract tests.

---

## Scope Check

- In scope:
  - Add visual QA runtime templates for execution plan and comparison report.
  - Extend QA signoff with visual status and evidence references.
  - Extend `ssf-qa`, `qa-gatekeeper`, and `/ssf-qa` command rules.
  - Document Web / mini-program platform protocol, baseline lifecycle, automatic/manual visual gate, and sensitive evidence guardrails.
  - Add Bats contract tests and pack validation.
  - Update `tasks.md` and `spec-to-code-map.md`.
- Out of scope:
  - Implementing image comparison algorithms.
  - Running Playwright screenshot capture.
  - Binding WeChat DevTools, a mini-program CLI, simulator, or any concrete runner.
  - Calling Figma, Lanhu, Js.Design, or other design tool APIs.

## File Structure

- Create: `templates/visual-execution-plan.md` — reusable visual QA plan template.
- Create: `templates/visual-comparison-report.md` — reusable visual comparison report template.
- Create: `tests/qa/test_visual_ui_qa_contract.bats` — contract tests for templates, rules, routing, README, and validation wiring.
- Create: `engineering/visual-ui-qa-adapter/spec-to-code-map.md` — requirement-to-implementation trace.
- Modify: `templates/qa-signoff.md` — add visual QA status section.
- Modify: `skills/ssf-qa/SKILL.md` — add visual QA workflow and gates.
- Modify: `agents/qa-gatekeeper.md` — mirror visual QA gate rules.
- Modify: `commands/ssf-qa.md` — expose visual QA outputs.
- Modify: `routing/AGENTS.routing.md` and `routing/CLAUDE.routing.md` — add visual QA routing and artifact rules.
- Modify: `README.md` — document visual QA in the workflow overview.
- Modify: `scripts/validate-pack.sh` — add visual QA contract validation.
- Modify: `openspec/changes/visual-ui-qa-adapter/tasks.md` — mark tasks complete as verified.

## Bite-Sized Tasks

### Task 1: Visual QA Templates

**Spec:** SSF-QA-VISUAL-001, SSF-QA-VISUAL-003, SSF-QA-VISUAL-004, SSF-QA-VISUAL-005, SSF-QA-VISUAL-009, SSF-QA-VISUAL-N1, SSF-QA-VISUAL-N2, SSF-QA-VISUAL-N4, SSF-QA-VISUAL-N7

**Files:**
- Create: `templates/visual-execution-plan.md`
- Create: `templates/visual-comparison-report.md`
- Modify: `templates/qa-signoff.md`
- Test: `tests/qa/test_visual_ui_qa_contract.bats`

- [ ] Step 1: Write failing template contract tests for visual runtime paths, baseline/actual/diff fields, optional reference fields, status enum, and evidence redaction.
- [ ] Step 2: Run `rtk bats tests/qa/test_visual_ui_qa_contract.bats` and confirm it fails because templates and visual status fields do not exist.
- [ ] Step 3: Add minimal templates and QA signoff section.
- [ ] Step 4: Re-run `rtk bats tests/qa/test_visual_ui_qa_contract.bats` and confirm template tests pass or reveal the next missing rule.
- [ ] Step 5: Update `tasks.md` after verification.

### Task 2: QA Skill, Command, And Agent Rules

**Spec:** SSF-QA-VISUAL-001, SSF-QA-VISUAL-002, SSF-QA-VISUAL-003, SSF-QA-VISUAL-004, SSF-QA-VISUAL-005, SSF-QA-VISUAL-006, SSF-QA-VISUAL-007, SSF-QA-VISUAL-008, SSF-QA-VISUAL-N1, SSF-QA-VISUAL-N2, SSF-QA-VISUAL-N3, SSF-QA-VISUAL-N4, SSF-QA-VISUAL-N5, SSF-QA-VISUAL-N6

**Files:**
- Modify: `skills/ssf-qa/SKILL.md`
- Modify: `agents/qa-gatekeeper.md`
- Modify: `commands/ssf-qa.md`
- Test: `tests/qa/test_visual_ui_qa_contract.bats`

- [ ] Step 1: Add failing tests for visual QA rule strings in skill, command, and agent.
- [ ] Step 2: Run the focused Bats test and confirm missing-rule failures.
- [ ] Step 3: Add minimal protocol rules for visual execution plan, comparison report, platform fields, baseline gates, and automatic/manual status boundaries.
- [ ] Step 4: Re-run focused tests.
- [ ] Step 5: Update `tasks.md` and spec-to-code map.

### Task 3: Baseline And Mini-Program Boundary

**Spec:** SSF-QA-VISUAL-002, SSF-QA-VISUAL-006, SSF-QA-VISUAL-007, SSF-QA-VISUAL-N6, SSF-QA-VISUAL-N8

**Files:**
- Modify: `skills/ssf-qa/SKILL.md`
- Modify: `agents/qa-gatekeeper.md`
- Modify: `templates/visual-execution-plan.md`
- Modify: `templates/visual-comparison-report.md`
- Test: `tests/qa/test_visual_ui_qa_contract.bats`

- [ ] Step 1: Add failing tests for baseline lifecycle, actual-not-baseline promotion guard, mini-program protocol-only boundary, and no concrete runner binding.
- [ ] Step 2: Run focused tests and confirm failures.
- [ ] Step 3: Add minimal baseline lifecycle and mini-program boundary wording.
- [ ] Step 4: Re-run focused tests.
- [ ] Step 5: Update `tasks.md` and spec-to-code map.

### Task 4: Routing And README

**Spec:** SSF-QA-VISUAL-002, SSF-QA-VISUAL-005, SSF-QA-VISUAL-008, SSF-QA-VISUAL-010, SSF-QA-VISUAL-N3, SSF-QA-VISUAL-N5, SSF-QA-VISUAL-N8

**Files:**
- Modify: `routing/AGENTS.routing.md`
- Modify: `routing/CLAUDE.routing.md`
- Modify: `README.md`
- Test: `tests/qa/test_visual_ui_qa_contract.bats`

- [ ] Step 1: Add failing tests for routing and README visual QA protocol documentation.
- [ ] Step 2: Run focused tests and confirm missing documentation failures.
- [ ] Step 3: Add minimal routing and README sections.
- [ ] Step 4: Re-run focused tests.
- [ ] Step 5: Update `tasks.md` and spec-to-code map.

### Task 5: Pack Validation

**Spec:** SSF-QA-VISUAL-001, SSF-QA-VISUAL-002, SSF-QA-VISUAL-003, SSF-QA-VISUAL-004, SSF-QA-VISUAL-005, SSF-QA-VISUAL-006, SSF-QA-VISUAL-007, SSF-QA-VISUAL-008, SSF-QA-VISUAL-009, SSF-QA-VISUAL-010, SSF-QA-VISUAL-N1, SSF-QA-VISUAL-N2, SSF-QA-VISUAL-N3, SSF-QA-VISUAL-N4, SSF-QA-VISUAL-N5, SSF-QA-VISUAL-N6, SSF-QA-VISUAL-N7, SSF-QA-VISUAL-N8

**Files:**
- Modify: `scripts/validate-pack.sh`
- Modify: `tests/qa/test_visual_ui_qa_contract.bats`
- Create: `engineering/visual-ui-qa-adapter/spec-to-code-map.md`
- Test: `rtk bash scripts/validate-pack.sh`

- [ ] Step 1: Add failing tests that require `check_visual_ui_qa_contract` and stable validation signals.
- [ ] Step 2: Run focused tests and confirm validation wiring failure.
- [ ] Step 3: Add minimal validation function and spec-to-code map.
- [ ] Step 4: Run `rtk bats tests/qa/test_visual_ui_qa_contract.bats`, `rtk bash scripts/validate-pack.sh`, and `rtk bash scripts/test.sh`.
- [ ] Step 5: Update `tasks.md` to complete after fresh verification.
