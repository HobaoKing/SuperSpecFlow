---
name: ssf-archive
description: 阶段六（档）。用户输入 /ssf-archive 或由 ssf-ship 续接时触发。归档 OpenSpec change、同步文档、更新 decision ledger，并用 Diataxis 检查文档缺口。
---

# ssf-archive — 归档与组织记忆

## 目标

把一次变更从“对话和代码”沉淀为长期组织记忆。

本阶段体现 OpenSpec 的 archive 价值：已完成的变更要变成可追踪历史，而不是散落在聊天记录里。

## 触发

- 显式：`/ssf-archive [change-id]`
- 隐式：用户要求归档、更新文档、整理本次变更
- 自动：`ssf-ship` 确认后续接

## 产物路径

宿主项目 archive 运行时产物默认写入 `.superspecflow/archive/<change-id>/`。Decision records 默认写入 `.superspecflow/decisions/`。读取历史归档产物时先读 `.superspecflow/archive/<change-id>/`，缺失时 fallback 到兼容期旧路径；新写入不得推荐根目录 `archive/<change-id>/`。

## Step 1 — Archive Summary

```markdown
# Archive Summary: [change-id]

- Date:
- Summary:
- Specs:
- Implementation:
- Tests:
- QA Result:
- Ship Decision:
- Residual Risk:
- Status: Archived / Pending Archive
```

## Step 2 — Documentation Updates

逐一更新：

```markdown
## Update: [doc path]

### Proposed Change

### Why

### Text to Add / Modify
```

默认扫描：

- README.md
- CHANGELOG.md
- ARCHITECTURE.md
- API docs
- user guide
- runbook

## Step 3 — Decision Ledger Update

```markdown
# Decision Record: [title]

## Context

## Decision

## Why

## Consequences

## Linked Change
openspec/changes/[change-id]
```

## Step 4 — Diataxis 文档缺口

```markdown
# Documentation Coverage

- Tutorial: ✅/❌
- How-to: ✅/❌
- Reference: ✅/❌
- Explanation: ✅/❌

## Recommended Additions
1. ...
```

## Step 5 — Completion Summary

输出：

```text
✅ [change-id] archive artifacts complete.
继续 Step 6 记录 Git / PR archive，再进入自动续接。
```

## Step 6 — Git / PR Archive

归档时补充 Git 记录：

```markdown
# Git / PR Archive

## Branch

## Commits
| Commit | 中文标题 | Spec IDs | Tests |
|---|---|---|---|

## PR

## Merge / Release Reference

## Rollback Reference
```

如果 commit 或 PR 没有中文内容，标记为流程缺口，并在 `ssf-retro` 中提出修复建议。

## Step 7 — 自动续接

归档、ledger、文档覆盖和 Git / PR archive 都完成后，进入：

```text
/ssf-retro [change-id]
```

如果用户明确结束本轮，不继续 `/ssf-retro`，记录该决定和原因；否则不得在 Step 6 前宣布 cycle complete。
