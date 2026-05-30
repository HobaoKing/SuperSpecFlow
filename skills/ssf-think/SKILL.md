---
name: ssf-think
description: 阶段一（想）。用户输入 /ssf-think 或描述新想法/新功能时触发。用 Superpowers brainstorming 纪律做价值、体验、范围反问，产出 Product Change Brief、Decision Record 和 design.md，然后进入 ssf-spec。
---

# ssf-think — 想清楚再动手

## 目标

把一句模糊想法变成可进入 OpenSpec 的产品决策。

本阶段体现 SuperSpecFlow 路由与适配层：先用 Superpowers brainstorming 纪律理解价值、体验和范围，再把结果整理成 OpenSpec proposal 输入。

## 触发

- 显式：`/ssf-think [idea]`
- 隐式：用户描述新产品、新功能、用户流程、MVP、体验设计、需求边界

## 输出产物

- Product Change Brief
- Product Decision Record
- User Journey
- Non-goals
- Success Metrics
- `design.md`
- OpenSpec proposal 输入

## 关键规则

- 不写代码。
- 不直接进入实现。
- 先挑战价值，再设计方案。
- 默认每次只问一个关键问题；如果用户明确说“快速模式”，可以一次性给出完整分析。
- 对高风险领域（支付、权限、用户数据、数据库、订阅、生产发布）自动提高门禁级别。

## Step 1 — 六个强迫性问题

默认逐一提问，每次只问一个。

1. 真正痛点是什么？不是功能描述，而是用户现在因为什么受苦。
2. 用户是谁？他们现在如何绕过或解决这个问题？
3. 如果只能做最小可验证版本，它长什么样？
4. 最大风险是什么？产品、技术、市场、合规均可。
5. 成功怎么衡量？上线后什么指标证明做对了？
6. 为什么不做？机会成本、复杂度、时机、替代方案是什么？

用户说「跳过 / 不知道 / 下一个」时记录为 `TBD`。

## Step 2 — 产品视角检查

六问完成后，输出以下三段。

```markdown
## CEO Court
- 值不值得做：Yes / No / Maybe
- 最大价值假设：
- 最小可验证版本：
- 可能砍掉的范围：

## Designer Court
- 核心用户路径：
- 空状态：
- 错误状态：
- 加载状态：
- 体验风险：

## Product Court
- 本次必须做：
- 本次不做：
- 成功指标：
- 仍需确认：
```

## Step 3 — 2-3 个方向

给出 2-3 个方向，每个方向包含：

```markdown
### 方向 N：[名称]
核心思路：
优点：
缺点：
适合场景：
建议优先级：P0/P1/P2
```

如果用户没有明确选择，推荐一个最小版本，但标明是假设。

## Step 4 — Product Change Brief

```markdown
# Product Change Brief: [feature-name]

## Problem

## Target Users

## Current Behavior

## Desired Behavior

## MVP Scope

## Non-goals

## User Journey

## Success Metrics

## Risks

## Open Questions
```

## Step 5 — Decision Record

```markdown
# Decision: [title]

## Context

## Options

## Decision

## Why

## Consequences

## Follow-ups
```

## Step 6 — design.md

```markdown
# Design: [feature-name]

## 问题陈述

## 选定方案

## 核心用户路径

## 核心设计决策

## 不做什么

## 成功标准

## 风险与缓解

## 开放问题
```

输出后问：

```text
design.md 确认吗？确认后进入 /ssf-spec。
```

## Step 6.5 — Design Document Review Loop

用户确认 design.md 之后、进入 ssf-spec 之前，使用 Agent tool 起 general-purpose 子代理对 design.md 做独立评审：

- Reviewer prompt：`~/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.5/skills/brainstorming/spec-document-reviewer-prompt.md`
- 传给子代理：
  - 待审：本阶段产出的 `design.md`
  - 上游：Product Change Brief 和 Decision Record
- 循环：
  - ✅ Approved → 进入 Step 7 自动续接
  - ❌ Issues Found → 修复后与用户对齐，再重新 dispatch，最多 3 轮
  - 超过 3 轮 → 交人工裁决

注意：reviewer prompt 是英文，针对单一 design.md 结构（跟本阶段产物吻合度较高）。如反复给出与项目中文化或产品视角检查无关的反馈，记录 follow-up。

## Step 7 — 自动续接

用户回复「确认 / OK / 好 / 继续」后，进入 `ssf-spec`。
