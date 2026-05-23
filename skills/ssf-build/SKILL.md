---
name: ssf-build
description: 阶段三（建）。用户输入 /ssf-build 或由 ssf-spec 续接时触发。按 OpenSpec tasks 执行，使用 Superpowers 风格：理解、计划、TDD、小步实现、验证、更新 spec-to-code-map。
---

# ssf-build — 按规格执行

## 目标

从 OpenSpec change contract 到可验证实现。

本阶段体现 Superpowers 的价值：AI 不凭感觉写代码，而是先理解、再计划、再写失败测试、再最小实现、再验证。

## 触发

- 显式：`/ssf-build`、`/ssf-build all`、`/ssf-build N`
- 隐式：用户要求实现、修 bug、加 API、重构、根据 spec 开发
- 自动：`ssf-spec` readiness 为 Ready 后续接

## 前置条件

如果没有可用 OpenSpec change，先暂停并要求提供 change-id，或进入 `ssf-spec`。

## 强制规则

- 没有 Spec ID，不做行为变更。
- 没有任务映射，不改代码。
- 优先 TDD：能写测试的行为先写失败测试。
- 不做 OpenSpec 之外的功能。
- 发现范围偏差，暂停，不自行扩展。
- 每完成一个 task，更新 tasks.md。
- 维护 `engineering/<change-id>/spec-to-code-map.md`。

## Step 1 — Implementation Plan

先输出：

```markdown
# Implementation Plan: [change-id]

## Scope Boundary
- In scope:
- Out of scope:

## Task Order
1. ...

## Test Strategy
- Unit:
- Integration:
- E2E:
- Negative:

## Files Expected to Change

## Risks / Pause Conditions
```

## Step 2 — Spec-to-Code Map

```markdown
# Spec to Code Map: [change-id]

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SPEC-001 | ... | ... | ... | Planned |
```

## Step 3 — 执行任务

`/ssf-build all`：逐条执行。
`/ssf-build N`：只执行第 N 条。

每个任务遵循：

```text
Read → Plan → Failing Test → Minimal Code → Run Test → Update Map → Update tasks.md
```

每完成一条输出：

```text
✓ Task N done — [一句话说明]
Spec: [SPEC-ID]
Tests: [运行结果]
```

## Step 4 — 暂停条件

以下情况必须暂停：

- 任务和实际代码结构不符
- 需要修改任务范围外文件
- 发现 specs 缺失或冲突
- 存在两个以上合理实现路径
- 发现安全、权限、数据一致性风险
- 测试无法验证 requirement

暂停格式：

```markdown
⚠️ Task N 暂停

## 原因

## 影响的 Spec

## 选项
- A: ...
- B: ...

## 建议
```

## Step 5 — Dev Handoff

任务完成后输出：

```markdown
# Developer Handoff: [change-id]

## Change Summary

## Specs Implemented

## Files Changed

## Tests Added / Updated

## Commands Run

## Known Risks

## Migration / Rollback

## QA Focus Areas
```

## Step 6 — 自动续接

用户确认后进入 `ssf-review`。

## Karpathy Integration — 编码纪律门禁

在 Step 1 前，必须运行轻量 Karpathy preflight：

```markdown
# Karpathy Preflight

## 我理解的目标

## 明确假设

## 可能的歧义

## 更简单的方案

## 本次最小可行改动
```

执行时遵守：

- 不做无关重构。
- 不修改与 Spec ID 无关的文件。
- 不为了未来扩展写抽象。
- 每个变更行都应能追溯到 Spec ID、测试或 bug 复现。
- 发现无关坏味道，记录到 follow-up，不直接改。

## Git Integration — 小步中文提交

每完成一个可验证 task，建议进入：

```text
/ssf-commit [change-id]
```

如果用户明确开启自动提交，提交前仍必须执行：

1. `git status --short`
2. `git diff --stat`
3. `git diff --check`
4. `git diff --staged --stat`
5. 确认 staged diff 只包含本 task
6. 使用中文 commit message

不得在未展示 staged diff 摘要的情况下提交。
