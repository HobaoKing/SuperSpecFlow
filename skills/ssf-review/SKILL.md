---
name: ssf-review
description: 阶段四（审）。用户输入 /ssf-review 或由 ssf-build 续接时触发。用工程审查视角 + Superpowers review 接收纪律，输出阻塞项、建议项、记录项，并确认 spec/code/test 同步。
---

# ssf-review — 工程审查

## 目标

在 QA 和发布前，进行对抗式工程审查。

本阶段体现 SuperSpecFlow 路由与适配层：把 OpenSpec、diff、progress 和 evidence 路由到工程、代码、安全视角审查。体现 Superpowers 的价值：处理 review 反馈时先验证事实，不盲目认同。

## 触发

- 显式：`/ssf-review`
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

宿主项目 review 产物默认写入 `.superspecflow/reviews/<change-id>/review-report.md`。读取历史 review 时先读 `.superspecflow/reviews/<change-id>/`，缺失时 fallback 到兼容期旧路径；新写入不得推荐根目录 `reviews/<change-id>/`。

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

同步检查属于 review 产物，默认写入 `.superspecflow/reviews/<change-id>/sync-check.md`。

```markdown
# Sync Check

| Spec ID | Code Implemented | Test Exists | Status |
|---|---:|---:|---|
| SPEC-001 | Yes/No | Yes/No | Pass/Fail |
```

## Step 5 — 自动续接

- 如果有 🔴：要求用户修复后再进入 QA。
- 如果没有 🔴：进入 `ssf-qa`。

## Step 6 — Cross-Agent Verification Handoff

如果用户要求 Claude、Codex 或另一个 agent 独立核验同一个 `<change-id>`，使用轻量文件化 handoff：

```text
.superspecflow/verification/<change-id>/
  request.md
  evidence.md
  reviewer-notes.md
  signoff.md
```

模板来源：

```text
templates/verification-request.md
templates/verification-evidence.md
templates/verification-reviewer-notes.md
templates/verification-signoff.md
```

规则：

1. 主 agent 只负责写入 `request.md` 和 `evidence.md`。
2. `request.md` 必须列出核验范围、目标 Spec ID、OpenSpec 文件、diff 来源、progress 引用和 evidence 引用。
3. `evidence.md` 必须包含可复查的命令、方法、结果摘要、相关文件或产物引用；不得只写结论。
4. review agent 只基于 OpenSpec、diff、progress 和 evidence 做核验，不得把聊天上下文、口头说明或未落盘声明作为核验依据。
5. review agent 可以在 evidence 缺失时写 `reviewer-notes.md` 说明缺口，但不得生成 `signoff.md`。
6. `signoff.md` 只能使用 `approve / changes-requested / blocked`，并必须列出已检查 Spec ID、证据引用、发现和残余风险。
7. progress 不可用时仍可核验 OpenSpec、diff 和 evidence，但必须在 `reviewer-notes.md` 或 `signoff.md` 记录残余风险。
8. 第一版不引入自动 agent 通信、抽象共识协议、双签门禁或多方投票。

## Step 7 — Karpathy Diff Audit

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

## Step 8 — Git Hygiene Review

检查：

```markdown
# Git Hygiene Review

- [ ] 当前分支命名是否合理
- [ ] diff 是否只包含本 change-id
- [ ] 是否有生成物、缓存、日志、secret
- [ ] 是否适合拆成多个 commit
- [ ] commit message 是否需要中文模板
```
