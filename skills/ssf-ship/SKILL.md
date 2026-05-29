---
name: ssf-ship
description: 阶段五（发）。用户输入 /ssf-ship 或由 ssf-qa 续接时触发。检查 QA signoff、release blockers、rollback、monitoring、PR 描述，给出 ship/no-ship。
---

# ssf-ship — 发布门禁

## 目标

把“代码完成”转成“可以安全发布”。

本阶段体现 gstack 的 Release Manager 价值：不是生成 PR 文案，而是做发布风险判断。

## 触发

- 显式：`/ssf-ship [change-id]`
- 隐式：用户说 ship、deploy、release、merge、上线、发版、PR 描述
- 自动：`ssf-qa` 推荐 Ship 后续接

## 关键规则

- 有 release blocker 不能 ship。
- 高风险功能必须有 rollback 和 monitoring。
- 如果 QA signoff 不存在，先回到 `ssf-qa`。
- 不假设用户已运行测试；必须列出已知证据和未知项。
- 发布运行时产物默认写入 `.superspecflow/release/<change-id>/`。
- 读取历史发布产物时先读 `.superspecflow/release/<change-id>/`，缺失时 fallback 到兼容期旧路径；新写入不得推荐根目录 `release/<change-id>/`。
- Parent change 有 Spec cluster 时，必须读取 `.superspecflow/clusters/<parent-change>/integration-gate.md`。
- 缺少 integration gate、cluster QA evidence、review 结论或 commit evidence 时，不得推荐 Ship。

## Step 1 — Release Checklist

```markdown
# Release Checklist: [change-id]

- [ ] OpenSpec tasks completed
- [ ] spec-to-code-map updated
- [ ] Review has no 🔴 blockers
- [ ] QA signoff exists
- [ ] Tests pass
- [ ] Negative tests covered
- [ ] No secrets / unsafe env changes
- [ ] Migration plan ready or not needed
- [ ] Rollback plan ready
- [ ] Monitoring plan ready
- [ ] CHANGELOG / docs updated or scheduled
```

未确认项标 `❌`，并说明阻塞或非阻塞。

## Step 2 — Rollback Plan

```markdown
# Rollback Plan: [change-id]

## Rollback Trigger

## Rollback Steps

## Data Considerations

## Owner

## Verification After Rollback
```

## Step 3 — Monitoring Plan

```markdown
# Monitoring Plan: [change-id]

## Metrics

## Logs

## Alerts

## First 24h Watch Items
```

## Step 4 — PR Description

```markdown
# PR: [change-id]

## Summary

## Specs Implemented

## Changes

## Tests

## Risks

## Rollback

## Screenshots / Recording

## Review Checklist
- [ ] Logic correct
- [ ] Tests adequate
- [ ] Security checked
- [ ] Docs updated
```

## Step 5 — Ship Decision

```markdown
# Ship Decision: [change-id]

Recommendation: Ship / Ship with monitoring / Do not ship

## Why

## Required Before Merge

## Optional Follow-ups
```

## Step 6 — Spec Cluster Integration Gate

如果 `<change-id>` 是 parent change 且存在 `.superspecflow/clusters/<change-id>/`：

1. 读取 `integration-gate.md`。
2. 检查每个 cluster 的 Spec IDs、QA evidence、review 结论、commit evidence、blocker 和跨 cluster 回归。
3. 缺少 integration gate 或任一 cluster evidence 时，Recommendation 必须是 `Do not ship` 或 `Ship blocked by cluster integration gate`。
4. Worktree 只作为执行隔离机制，不得作为发布边界。

## Step 7 — 自动续接

只有 recommendation 为 `Ship` 或 `Ship with monitoring` 时，用户确认后才进入 `ssf-archive`。
如果 recommendation 为 `Do not ship`、`Ship blocked by cluster integration gate`、`Ship blocked by Git hygiene` 或任何 blocked 状态，停下并列出 blockers，不得自动归档。

## Step 8 — Git / PR Gate

发布前必须检查 Git 和 PR：

```markdown
# Git / PR Gate: [change-id]

- [ ] 当前分支符合命名规范
- [ ] 工作区干净，或未提交内容已解释
- [ ] 所有 commit 标题符合 `<英文类型>(<英文范围>): <中文摘要>` 规范，正文为中文
- [ ] commit 正文包含 change-id、Spec ID、验证方式、风险与回滚
- [ ] PR 标题符合 commit 标题规范（英文类型 + 英文范围 + 中文摘要）
- [ ] PR 正文包含变更摘要、测试、风险、回滚、QA 结果
- [ ] 无无关改动或已拆分
```

建议运行：

```bash
git status --short
git log --oneline --decorate -n 10
git diff --stat origin/develop...HEAD
```

如果目标分支不是 `develop`，替换为实际 base 分支。

如果 Git / PR Gate 不通过，Recommendation 必须是 `Do not ship` 或 `Ship blocked by Git hygiene`。
