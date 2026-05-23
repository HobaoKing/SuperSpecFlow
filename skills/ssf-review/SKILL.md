---
name: ssf-review
description: 阶段四（审）。用户输入 /ssf:review 或由 ssf-build 续接时触发。用 gstack 风格工程审查 + Superpowers 风格 review 接收纪律，输出阻塞项、建议项、记录项，并确认 spec/code/test 同步。
---

# ssf:review — 工程审查

## 目标

在 QA 和发布前，进行对抗式工程审查。

本阶段体现 gstack 的价值：由工程经理、代码 reviewer、安全 reviewer 的视角审查。体现 Superpowers 的价值：处理 review 反馈时先验证事实，不盲目认同。

## 触发

- 显式：`/ssf:review`
- 隐式：用户要求代码审查、PR review、检查问题、工程评审
- 自动：`ssf-build` 完成后续接

## Step 1 — Engineering Manager Review

检查：

```markdown
## Engineering Manager Review

1. 是否严格实现 proposal/spec？通过 / 有问题
2. 是否有过度设计？通过 / 有问题
3. 模块边界是否清晰？通过 / 有问题
4. 数据流是否正确？通过 / 有问题
5. 错误处理是否完整？通过 / 有问题
6. 测试是否覆盖核心行为和 MUST NOT？通过 / 有问题
7. 是否引入不必要依赖？通过 / 有问题
```

## Step 2 — Code Review Report

```markdown
# Review Report: [change-id]

## 🔴 必须修（阻塞发版）
- [问题] @ [文件:行号]
  - Spec: [SPEC-ID]
  - 风险:
  - 建议修法:

## 🟡 建议改（不阻塞）
- [问题] @ [文件:行号]
  - 建议:

## 🟢 记录即可
- [观察]
```

检查维度：

- bug 风险
- 权限 / 安全 / 注入 / 密钥
- 数据一致性
- 边界条件
- 性能
- 可读性
- 过度抽象
- 测试缺口

## Step 3 — Review Feedback Handling Rule

如果用户要求修 review：

1. 先复述每条 review 的技术含义。
2. 验证代码事实是否支持该反馈。
3. 判断是否应采纳。
4. 对采纳项给出最小修复方案。
5. 修完后运行相关测试。

不得直接说“你说得对，我马上改”。

## Step 4 — Spec / Code / Test Sync

```markdown
# Sync Check

| Spec ID | Code Implemented | Test Exists | Status |
|---|---:|---:|---|
| SPEC-001 | Yes/No | Yes/No | Pass/Fail |
```

## Step 5 — 自动续接

- 如果有 🔴：要求用户修复后再进入 QA。
- 如果没有 🔴：进入 `ssf-qa`。

## Step 6 — Karpathy Diff Audit

在 review 报告后增加：

```markdown
# Karpathy Diff Audit

## 是否隐藏假设
- Pass / Fail

## 是否过度设计
- Pass / Fail

## 是否存在无关改动
- Pass / Fail

## 每类改动的必要性
| 改动 | 对应 Spec / Task / Bug | 是否必要 |
|---|---|---|

## 建议拆分的 commit

## 建议回滚的无关改动
```

任何无法映射到 Spec ID、任务或测试的行为改动，至少标为 🟡；如果影响正确性、安全或发布，标为 🔴。

## Step 7 — Git Hygiene Review

检查：

```markdown
# Git Hygiene Review

- [ ] 当前分支命名是否合理
- [ ] diff 是否只包含本 change-id
- [ ] 是否有生成物、缓存、日志、secret
- [ ] 是否适合拆成多个 commit
- [ ] commit message 是否需要中文模板
```
