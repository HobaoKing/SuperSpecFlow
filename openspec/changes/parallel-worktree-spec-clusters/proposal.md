# Proposal: parallel-worktree-spec-clusters

## Summary

为 SuperSpecFlow 增加 parent change、Spec cluster 和多 worktree 并行开发规则，让大 change 可以拆成多个可审计子范围并行推进，再通过 parent integration gate 汇总 Review、QA、Git 和跨 cluster 回归证据。

本 change 是 `workflow-scale-architecture` 的第二阶段 implementation change。它依赖 `browser-mcp-qa-adapter` 提供的 QA evidence 语义，但不实现浏览器/MCP QA 内部执行逻辑。

## Problem

当前 SuperSpecFlow 的 OpenSpec、Build、QA、Ship 和 Git 规则主要围绕单个 change-id 工作。大 change 拆成多个并行工作时，缺少稳定的 parent / cluster contract、worktree 命名、分支关联、cluster status 和 integration gate。

如果没有这些规则，多个 agent 或开发者可能在不同 worktree 中各自完成局部工作，却无法证明所有 cluster 都映射到 Spec ID、通过 QA、完成 review、没有跨 cluster 回归风险，也无法明确最终发布责任归属。

## Goals

- 定义 parent change 与 Spec cluster 的职责边界。
- 定义 `.superspecflow/clusters/<parent-change>/cluster-plan.md`。
- 定义 `.superspecflow/clusters/<parent-change>/cluster-status.md`。
- 定义 `.superspecflow/clusters/<parent-change>/integration-gate.md`。
- 规定 cluster worktree 和分支命名规则。
- 规定每个 cluster 必须独立保留 OpenSpec、tasks、spec-to-code map、review、QA 和 Git 证据。
- 规定 parent change 最终发布必须经过 integration gate。
- 将 cluster 规则接入 `ssf-spec`、`ssf-build`、`ssf-git`、`ssf-qa`、`ssf-ship`、routing、templates 和 docs。

## Non-goals

- 不实现 browser/MCP QA 内部执行逻辑。
- 不自动创建、删除或清理 worktree。
- 不实现后台调度器、自动 merge 服务或跨 agent 编排服务。
- 不绕过现有 change-id、Spec ID、Review、QA、Ship 或 Git gate。
- 不要求所有 change 都拆成 cluster。
- 不支持第一版跨仓库 cluster；第一版只定义同一 Git 仓库内多 worktree。

## User Impact

用户处理大 change 时，可以先创建 parent change，再拆分多个 Spec cluster。每个 cluster 可以在独立 worktree 中 build、review、qa 和 commit。parent change 通过 `cluster-plan.md` 和 `cluster-status.md` 追踪并行状态，最终由 `integration-gate.md` 汇总证据后再进入 ship。

## Affected Areas

- `openspec/changes/parallel-worktree-spec-clusters/`
- `skills/ssf-spec/SKILL.md`
- `skills/ssf-build/SKILL.md`
- `skills/ssf-git/SKILL.md`
- `skills/ssf-qa/SKILL.md`
- `skills/ssf-ship/SKILL.md`
- `commands/ssf-branch.md`
- `commands/ssf-build.md`
- `commands/ssf-qa.md`
- `commands/ssf-ship.md`
- `templates/cluster-plan.md`
- `templates/cluster-status.md`
- `templates/integration-gate.md`
- `docs/branching-strategy.md`
- `routing/AGENTS.routing.md`
- `routing/CLAUDE.routing.md`
- `scripts/validate-pack.sh`
- `tests/clusters/`
- `README.md`
- `engineering/parallel-worktree-spec-clusters/`

## Success Metrics

- 大 change 何时需要评估 cluster 拆分有明确阈值和记录要求。
- Parent change 与 cluster 的发布责任边界清晰。
- Cluster worktree 和 branch 命名规则不替换普通 change 分支规则。
- Parent QA / Ship gate 能引用每个 cluster 的 QA evidence、review 结论和 commit。
- 没有 `integration-gate.md` 时，parent change 不得被标记为可发布。
- Pack validation 或 contract tests 能发现 cluster templates、routing 或 skill 规则缺失。

## Risks

- 多 worktree 操作可能增加未提交改动、分支漂移和集成冲突风险。
- Cluster 拆分过细会增加协调成本；拆分过粗会失去并行价值。
- Parent / cluster 关系如果不落盘，后续 agent 可能无法判断发布责任。
- 如果 browser QA evidence 尚未完全落地，parent QA 汇总只能记录 blocked 或 manual evidence。

## Rollout Strategy

第一版只定义文件协议、模板和 agent 规则，要求同一 Git 仓库内多 worktree。执行时由用户或 agent 显式创建 worktree，不引入后台调度、自动 merge 或跨 agent 编排。

本 change 默认在 `browser-mcp-qa-adapter` 之后实现。如果用户明确要求先实现本 change，必须在本 proposal 的 Open Questions 或 Rollout Strategy 中记录豁免原因和 QA evidence 尚未落地的 parent integration 风险。

## Open Questions

- Parent change 最终 PR 是否保留 cluster commit 历史，还是 squash 到 parent integration commit？
- Cluster id 命名是否使用纯数字、领域 slug，还是 `<domain>-<sequence>`？
- 第一版是否需要支持跨仓库 cluster？本 proposal 暂定不支持。
