# Implementation Plan: [change-id]

Path: `.superspecflow/engineering/[change-id]/implementation-plan.md`

**Goal:** [一句话目标]

**Architecture:** [2-3 句架构方向]

**Spec Contract:** `openspec/changes/[change-id]/specs/`

**Tech Stack:** [关键技术、库、版本]

---

## Scope Check
- In scope:
- Out of scope:

## File Structure
- Create: `path/to/new-file.ext` — [单一职责]
- Modify: `path/to/existing.ext` — [本次变更职责]
- Test: `tests/path/file.test.ext` — [测试覆盖范围]

## Bite-Sized Tasks

### Task N: [Component Name]

**Spec:** [SPEC-ID]

**Files:**
- Create: `path/to/file.ext`
- Modify: `path/to/existing.ext:line`
- Test: `tests/path/file.test.ext`

- [ ] **Step 1: 写失败测试**

  ```text
  [完整测试代码，禁止省略]
  ```

- [ ] **Step 2: 跑测试确认失败**

  Run: `[具体测试命令]`
  Expected: FAIL with "[具体失败信息]"

- [ ] **Step 3: 写最小实现**

  ```text
  [完整最小实现，禁止省略]
  ```

- [ ] **Step 4: 跑测试确认通过**

  Run: `[同 Step 2 或对应验证命令]`
  Expected: PASS

- [ ] **Step 5: 准备 Git gate**

  ```bash
  git status --short
  git diff --stat
  git diff --check
  git add <paths>
  git diff --staged --stat
  git diff --staged --check
  ```

  然后进入 `/ssf-commit [change-id]`，不得在 implementation plan 中直接提交。

## Plan Review Loop
- Reviewer:
- Iteration Count:
- Result: Approved / Changes Requested / Blocked / Waived
- Evidence:
- Blocked / Waived Evidence:

## Execution Handoff
- Mode: Subagent-Driven / Inline
- Reason:
- Next Command:

## Risks / Pause Conditions
