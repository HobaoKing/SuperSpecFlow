---
name: ssf-spec
description: 阶段二（规）。用户输入 /ssf:spec 或由 ssf-think 续接时触发。生成 OpenSpec 风格 change contract：proposal.md、design.md、specs/*.md、tasks.md、Spec Readiness Review。
---

# ssf:spec — 写规格锁定需求

## 目标

把产品设计变成工程、测试、发布都能执行的 OpenSpec 风格变更合同。

本阶段体现 OpenSpec 的价值：需求不是聊天上下文，而是可追踪、可审查、可归档的 change artifact。

## 触发

- 显式：`/ssf:spec [change-id]`
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
engineering/<change-id>/
  spec-readiness-review.md
  spec-to-code-map.md
qa/<change-id>/
  acceptance-matrix.md
  risk-matrix.md
```

## 关键规则

- 每个 requirement 必须有稳定 Spec ID，如 `AUTH-001`、`BILLING-002`。
- 必须写 `MUST NOT`，用于测试负向场景。
- 每个 requirement 至少有一个 scenario。
- 高风险变更必须包含 rollback / monitoring / risk matrix 输入。
- 生成完核心文档后，先做 Spec Readiness Review，再进入 build。

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

## Step 6 — 自动续接

用户确认且 readiness 为 Ready 后，进入 `ssf-build`。

## Git Preparation

规格确认后，建议立即准备分支：

```text
/ssf:branch [change-id] [topic]
```

如果要提交规格文档，commit 必须为中文，例如：

```text
规格(会员): 建立续费提醒变更合同

变更编号：add-membership-renewal-reminder
关联规格：MEMBERSHIP-001, MEMBERSHIP-002

变更内容：
- 新增续费提醒 proposal、specs 和 tasks。

验证方式：
- 已完成 Spec Readiness Review。

风险与回滚：
- 仅涉及规格文档，可回滚该提交恢复。
```
