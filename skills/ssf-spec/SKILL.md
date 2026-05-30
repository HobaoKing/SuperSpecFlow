---
name: ssf-spec
description: 阶段二（规）。用户输入 /ssf-spec 或由 ssf-think 续接时触发。生成 OpenSpec 风格 change contract：proposal.md、design.md、specs/*.md、tasks.md、Spec Readiness Review。
---

# ssf-spec — 写规格锁定需求

## 目标

把产品设计变成工程、测试、发布都能执行的 OpenSpec 风格变更合同。

本阶段体现 OpenSpec 的价值：需求不是聊天上下文，而是可追踪、可审查、可归档的 change artifact。

## 触发

- 显式：`/ssf-spec [change-id]`
- 隐式：用户要求写规格、OpenSpec、acceptance criteria、拆任务、准备开发
- 自动：`ssf-think` 确认后续接

## 推荐目录

```text
openspec/changes/<change-id>/
  proposal.md
  design.md
  tasks.md
  specs/
    <domain>.md
.superspecflow/engineering/<change-id>/
  spec-readiness-review.md
.superspecflow/maps/<change-id>/
  spec-to-code-map.md
.superspecflow/qa/<change-id>/
  acceptance-matrix.md
  risk-matrix.md
```

`openspec/` 是可提交的 change contract。宿主项目运行时产物写入 `.superspecflow/`；如果是在 SuperSpecFlow 本仓库实现包源码变更，则本仓库工程交付物保留在 `engineering/<change-id>/`，不迁移、不标为非法路径。

## 关键规则

- 生成 proposal 前必须做 Superpowers Spec Discipline：记录 Brainstorming Context、Assumption Audit、Alternatives Considered、Open Questions Disposition。
- 如果没有上游 `ssf-think` 或 brainstorming context，必须记录 Blocked / Waived Evidence，或先问一个关键问题。
- 每个 requirement 必须有稳定 Spec ID，如 `AUTH-001`、`BILLING-002`。
- 必须写 `MUST NOT`，用于测试负向场景。
- 每个 requirement 至少有一个 scenario。
- 高风险变更必须包含 rollback / monitoring / risk matrix 输入。
- 生成完核心文档后，先做 Spec Readiness Review，再进入 build。
- 如果 change 预计超过 8 个 tasks、超过 6 个 Spec IDs，或横跨两个以上相对独立子系统，必须评估是否拆成 Spec cluster。
- 需要拆分时，parent change 记录整体目标和最终 gate，并使用 `.superspecflow/clusters/<parent-change>/cluster-plan.md` 记录 cluster id、Spec IDs、依赖、worktree、owner、分支、QA expectations 和 integration order。
- 不拆分时，必须在 proposal、design 或 implementation plan 中记录原因。

## Step 0 — Superpowers Spec Discipline

```markdown
## Brainstorming Context
- Upstream Think / Design Source:
- Goal:
- Non-goals:
- Waiver Reason if no upstream context:

## Assumption Audit
- Assumption:
- Evidence:
- Risk if wrong:

## Alternatives Considered
- Option:
- Reason accepted / rejected:

## Open Questions Disposition
| Question | Decision / Disposition | Owner | Blocks Ready? |
|---|---|---|---:|

## Blocked / Waived Evidence
- Reviewer / Tool unavailable:
- Waiver reason:
- Residual risk:
```

## Step 1 — proposal.md

```markdown
# Proposal: [change-id]

## Summary

## Problem

## Goals

## Non-goals

## User Impact

## Affected Areas

## Success Metrics

## Risks

## Rollout Strategy

## Open Questions
```

输出后问：`proposal.md 确认吗？确认后生成 specs。`

## Step 2 — specs/*.md

至少生成一个领域 spec 文件：

```markdown
# Spec: [domain]

## ADDED Requirements

### Requirement: [SPEC-ID] [requirement title]

系统必须 [可验证行为]。

#### Scenario: [happy path]
- GIVEN ...
- WHEN ...
- THEN ...

#### Scenario: [edge case]
- GIVEN ...
- WHEN ...
- THEN ...

## MODIFIED Requirements

### Requirement: [SPEC-ID] ...

## REMOVED Requirements

### Requirement: [SPEC-ID] ...

## MUST NOT

- [SPEC-ID-N1] 系统不得 ...
- [SPEC-ID-N2] 系统不得 ...
```

输出后问：`specs 确认吗？确认后生成 design.md 和 tasks.md。`

## Step 3 — design.md

```markdown
# Technical Design: [change-id]

## Architecture Summary

## Data Flow

## API / Interface Changes

## Data Model Changes

## Security / Permission Considerations

## Failure Modes

## Observability

## Migration Plan

## Rollback Plan

## Alternatives Considered
```

低风险纯前端/文案修改可简化，但必须说明为什么简化。

## Step 4 — tasks.md

任务必须小、可验证、映射 Spec ID。

```markdown
# Tasks: [change-id]

- [ ] T1: [动词开头的任务]
  - Spec: [SPEC-ID]
  - Files: `path/to/file`
  - Test: [测试文件或验证命令]
  - Acceptance: [可直接验证的标准]
  - Estimate: N min

- [ ] T2: ...
```

## Step 5 — Spec Readiness Review

```markdown
# Spec Readiness Review: [change-id]

## Brainstorming Context

## Assumption Audit

## Alternatives Considered

## Open Questions Disposition

## Spec Document Review Loop

## Reviewer Result

## Blocked / Waived Evidence

## Ready Checklist
- [ ] Problem clear
- [ ] Scope clear
- [ ] Non-goals clear
- [ ] Requirements have Spec IDs
- [ ] Scenarios cover happy and negative paths
- [ ] Acceptance criteria testable
- [ ] Risks identified
- [ ] Rollback possible or not needed

## Blockers

## Questions

## Recommendation
- Ready to implement / Needs clarification / Needs design review
```

如果 Recommendation 不是 `Ready to implement`，不要自动进入 build。

## Step 5.5 — Spec Document Review Loop

Spec Readiness Review 通过后，使用 Agent tool 起 general-purpose 子代理对 spec 产物做独立评审：

- Reviewer prompt：`~/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.5/skills/brainstorming/spec-document-reviewer-prompt.md`
- 传给子代理：
  - 待审：`openspec/changes/<change-id>/proposal.md`、`openspec/changes/<change-id>/specs/*.md`、`openspec/changes/<change-id>/design.md`
  - 上游：ssf-think 输出的 `design.md`（产品决策）
- 循环：
  - ✅ Approved → 进入 Step 6 自动续接
  - ❌ Issues Found → 修复后重新 dispatch，最多 3 轮
  - 超过 3 轮 → 交人工裁决

注意：reviewer prompt 是英文 + 针对 superpowers 单一 design.md 结构。读 SuperSpecFlow 多文件结构（proposal/specs/design/tasks）和中文 SPEC-ID 时可能给出偏向通用结构的反馈。如果连续两轮出现明显不适配（例如要求把多文件合并、不识别 MUST NOT 语义），记录 follow-up，跳过本步并恢复纯人工 Spec Readiness Review。

如果 reviewer prompt、Agent tool 或宿主环境不可用，不得静默跳过；必须在 Spec Readiness Review 的 `Blocked / Waived Evidence` 记录原因、残余风险和人工替代检查。

## Step 6 — 自动续接

用户确认且 readiness 为 Ready 后，进入 `ssf-build`。

## Git Preparation

规格确认后，建议立即准备分支：

```text
/ssf-branch [change-id] [topic]
```

如果要提交规格文档，commit 必须为中文，例如：

```text
spec(openspec:members): 建立续费提醒变更合同

变更编号：add-membership-renewal-reminder
关联规格：MEMBERSHIP-001, MEMBERSHIP-002

变更内容：
- 新增续费提醒 proposal、specs 和 tasks。

验证方式：
- 已完成 Spec Readiness Review。

风险与回滚：
- 仅涉及规格文档，可回滚该提交恢复。
```
