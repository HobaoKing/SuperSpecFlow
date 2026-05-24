# Proposal: artifact-path-migration

## Summary

将 SuperSpecFlow 本地运行产物从分散的 `engineering/<change-id>/`、`qa/<change-id>/`、`release/<change-id>/`、`archive/<change-id>/`、`retro/` 等目录逐步迁移到 `.superspecflow/` 命名空间下，同时保留旧路径读取兼容期，并明确 `openspec/` 继续作为可提交的需求契约目录，不参与本次迁移。

## Problem

当前运行产物路径散落在仓库根目录，容易与源码、OpenSpec change contract 和宿主项目文档混在一起。不同阶段和 agent 对产物路径的理解也不完全一致，后续 Git 门禁、验证脚本和多 agent 协作很难统一判断哪些文件应该提交、哪些只是本地 workflow 产物。

## Goals

- 推荐所有新运行产物写入 `.superspecflow/` 下的阶段化路径。
- 保留旧路径读取兼容期，避免硬断已有用户和历史项目。
- 明确 `openspec/` 不迁移，仍为可提交的 change contract。
- 为后续修改 skills、agents、commands、templates 和 validation 提供可追踪任务。
- 统一工程、评审、QA、发布、归档、复盘、决策、映射和 Karpathy 审计产物路径。

## Non-goals

- 不迁移、重命名或隐藏 `openspec/`。
- 不在本 change 中实现代码、脚本、命令或模板修改。
- 不删除旧路径中的历史产物。
- 不强制一次性搬迁已有项目文件。
- 不改变 Think、Spec、Build、Review、QA、Ship、Git、Archive、Retro 阶段语义。

## User Impact

新项目和新运行产物将默认使用 `.superspecflow/` 下的统一路径；已有项目在兼容期内仍可被读取旧路径产物。用户会看到旧路径不再作为推荐写入位置，但历史产物不会因为升级流程包而立即失效。

## Affected Areas

- `skills/`
- `agents/`
- `commands/`
- `templates/`
- `scripts/`
- `tests/`
- `.gitignore`
- Git / validation 门禁

## Success Metrics

- 新产物路径全部指向 `.superspecflow/` 下的规范位置。
- 读取逻辑以新路径优先，旧路径 fallback。
- 文档和门禁明确 `openspec/` 仍可提交，不被误判为运行时产物。
- 后续 tasks 能覆盖 skills、agents、commands、templates 和 validation 的迁移面。
- 迁移后旧路径历史产物仍可被发现并用于兼容读取。

## Risks

- 涉及面大，路径常量可能分散在多个 skill、agent、command、template 和验证脚本中。
- 过早禁止旧路径会中断已有用户和历史项目。
- `.superspecflow/` 同时承载安装软链和运行产物时，文档和 Git 门禁需要清楚区分本地产物与可提交契约。
- 如果验证规则过宽，可能误伤宿主项目正常提交的 `openspec/`。

## Rollout Strategy

分阶段迁移。第一阶段只确立新路径契约和兼容策略；后续实现阶段按 skills / agents / commands / templates / validation 逐步替换写入路径，并让读取逻辑优先查找新路径、再回退旧路径。兼容期内不删除旧路径，也不要求用户立即搬迁历史产物。

## Open Questions

- 旧路径读取兼容期的结束条件和版本窗口需要由主控 release 计划决定。
- 是否提供自动迁移命令复制旧产物到 `.superspecflow/`，需要在后续实现阶段评估。
