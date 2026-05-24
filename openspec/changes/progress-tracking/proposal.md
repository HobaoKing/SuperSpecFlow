# Proposal: progress-tracking

## Summary

为 SuperSpecFlow 定义 `.superspecflow/progress/<change-id>/` 的最小文件协议，让长任务可以记录当前状态、时间线、验证证据和交接信息，并为后续 cross-agent verification 提供事实底座。

## Problem

长任务在上下文压缩、中断或更换 agent 后，当前进度、已完成任务、验证证据和下一步动作容易只存在于对话上下文中。后续 agent 需要重新推断状态，容易重复工作、跳过验证，或基于过期结论继续执行。

SuperSpecFlow 目前有 OpenSpec change contract，但缺少运行时进度协议来描述“这个 change 当前做到哪里”。需要一个小而稳定的文件约定，补足 OpenSpec 与实际执行过程之间的状态记录。

## Goals

- 定义 `.superspecflow/progress/<change-id>/state.json` 的当前状态协议。
- 定义 `timeline.md`、`verification.md`、`handoff.md` 的记录职责。
- 明确 agent 在开始、恢复、验证完成声明和交接时的读写规则。
- 明确上下文中断、上下文压缩或更换 agent 后的恢复顺序。
- 明确 SuperSpecFlow 本仓库不提交运行时进度实例。
- 为 `cross-agent-verification` 提供可引用的进度事实来源。

## Non-goals

- 不实现自动调度、自动恢复或后台守护进程。
- 不引入 UI、仪表盘或可视化进度页面。
- 不定义跨 agent 签核、审批或投票机制。
- 不改变 OpenSpec proposal / design / tasks / specs 的结构。
- 不实现代码、脚本、测试或命令行为变更。

## User Impact

执行长任务的 agent 可以把当前阶段、任务状态、验证命令和交接摘要写入 `.superspecflow/progress/<change-id>/`。当上下文丢失或换 agent 时，新 agent 先读进度协议，再读 OpenSpec change contract，从而减少重复探索并避免无证据的完成声明。

宿主项目可以按自身策略决定是否提交 `.superspecflow/progress/`。SuperSpecFlow 本仓库只提交协议规格，不提交运行时实例。

## Affected Areas

- `openspec/changes/progress-tracking/`
- 后续 `cross-agent-verification` change 的事实输入
- 后续 agent routing / command / skill 行为说明

## Success Metrics

- 规格明确四个必需文件的职责和最小字段。
- 规格明确恢复流程：先读 `state.json` 和 `handoff.md`，再读 OpenSpec。
- 规格明确完成声明前必须有 fresh verification 写入或引用。
- 规格明确本仓库不得提交 `.superspecflow/progress/` 运行时实例。
- 后续 change 可以引用本协议作为 cross-agent verification 的事实底座。

## Risks

- 如果字段过多，agent 会倾向于不维护或维护不一致。
- 如果 fresh verification 定义不清，后续 agent 可能引用过期验证证据。
- 如果宿主项目提交策略不明确，进度文件可能被误认为 SuperSpecFlow 本仓库应提交的源码。

## Rollout Strategy

第一版只发布 OpenSpec 协议。后续 change 再把该协议接入 routing、commands、skills、验证门禁或跨 agent 检查流程。

## Open Questions

- 是否需要为 `state.json` 增加机器可校验 schema 文件由后续 change 决定。
- 宿主项目默认是否提交 `.superspecflow/progress/` 由宿主项目策略决定，本协议不强制。
