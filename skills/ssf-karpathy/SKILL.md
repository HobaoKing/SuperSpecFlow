---
name: ssf-karpathy
description: Karpathy 风格的 AI 编码行为约束。用于写代码、review、重构、修 bug、提交前审查，防止错误假设、过度设计、无关改动和不可验证目标。
---

# ssf-karpathy — 最小、清晰、可验证的 AI 编码纪律

## 来源与定位

本 Skill 吸收 `multica-ai/andrej-karpathy-skills` 的核心思想，并融合到 SuperSpecFlow：

1. 编码前先想清楚，不隐藏假设和困惑。
2. 简单优先，不做投机式抽象。
3. 外科手术式修改，只改必须改的地方。
4. 目标驱动执行，把任务变成可验证结果。

它不是替代 OpenSpec 合同层、Superpowers 执行纪律层或 SuperSpecFlow 路由与适配层，而是作为所有工程动作的底层行为约束。

## 触发

- 显式：`/ssf-karpathy [目标]`
- 隐式：任何实现、修 bug、重构、代码审查、提交前检查
- 自动：`ssf-build` 开始前、`ssf-review` 审查 diff 时、`ssf-git` 提交前

## Gate 1 — Think Before Coding

宿主项目 Karpathy 产物默认写入 `.superspecflow/karpathy/<change-id>/`，例如 `karpathy-preflight.md` 和 `karpathy-diff-audit.md`。读取历史审计时先读 `.superspecflow/karpathy/<change-id>/`，缺失时 fallback 到兼容期旧路径；新写入不得推荐根目录 `karpathy/<change-id>/`。

编码前必须明确：

```markdown
# 编码前判断

## 我理解的目标

## 明确假设

## 可能的歧义

## 更简单的方案

## 需要暂停确认的问题
```

规则：

- 不要默默选择一种解释。
- 有多个合理解释时，列出来。
- 发现更简单方案时，主动指出。
- 困惑时说清楚困惑点，而不是继续写。
- 低风险小改可以简化输出，但不能跳过思考。

## Gate 2 — Simplicity First

实现前问：

```markdown
# 简化检查

- 这是不是满足 spec 的最小实现？
- 有没有为未来需求写抽象？
- 有没有增加未要求的配置、扩展点、框架？
- 有没有把 50 行问题写成 200 行？
- 高级工程师会不会认为这过度设计？
```

禁止：

- 单次使用就抽象。
- 为不存在的未来场景加配置。
- 加需求外功能。
- 写无法触发的错误处理。
- 为了“看起来完整”扩大范围。

## Gate 3 — Surgical Changes

修改已有代码时：

- 只改和 Spec ID / 任务直接相关的行。
- 不顺手重构邻近代码。
- 不顺手改注释、格式、命名。
- 遵循现有风格，即使你更喜欢另一种写法。
- 发现无关坏味道时记录，不擅自修改。
- 只清理你本次改动造成的无用 import、变量、函数。

每个改动都应该能回答：

```text
这行为什么必须改？它对应哪个 Spec ID、测试或 bug 复现？
```

## Gate 4 — Goal-Driven Verification

把命令式任务改写成可验证目标：

| 原始说法 | 转换后目标 |
|---|---|
| 加校验 | 先写无效输入测试，再实现并通过 |
| 修 bug | 先写复现 bug 的失败测试，再修到通过 |
| 重构模块 | 先证明现有测试通过，重构后再次通过 |
| 增加页面 | 定义用户路径、状态和验收结果后再实现 |

多步任务使用：

```markdown
# 目标驱动计划

1. [步骤] → 验证：[检查方式]
2. [步骤] → 验证：[检查方式]
3. [步骤] → 验证：[检查方式]
```

## Karpathy Diff Audit

在 review 或 commit 前输出：

```markdown
# Karpathy Diff Audit

## 假设是否已显式说明
- Pass / Fail

## 是否为最小实现
- Pass / Fail

## 是否存在无关改动
- Pass / Fail

## 每类改动的来源
| 改动 | 对应 Spec / Task / Bug | 是否必要 |
|---|---|---|

## 验证证据

## 需要回滚或拆分的改动
```

## 与 SuperSpecFlow 阶段的关系

- `ssf-think`：用于暴露假设、提出更小 MVP。
- `ssf-spec`：用于把成功标准写成可验证 requirement。
- `ssf-build`：用于限制实现范围和 diff 面积。
- `ssf-review`：用于查出无关改动、过度设计和隐藏假设。
- `ssf-git`：用于保证 commit 只包含一个清晰目标。
- `ssf-ship`：用于避免“看似完成但未验证”的发布。

## 轻量模式

简单拼写、明显一行修复、纯文案改动可以使用轻量模式：

```markdown
目标：
最小改动：
验证：
```

但仍不得引入无关改动。
