# Proposal: workflow-scale-architecture

## Summary

为 SuperSpecFlow 定义两个后续能力的总架构：一是 MCP / 浏览器 QA 适配，让 `ssf-qa` 可以把规格验收矩阵转成真实用户路径执行证据；二是多 worktree 并行开发规则，让大 change 可以拆成多个 Spec cluster 并行推进，再回到 parent change 做集成验收。

本 change 只锁定架构边界、产物协议、阶段顺序和门禁关系。具体实现拆成两个后续 implementation changes：

- `browser-mcp-qa-adapter`
- `parallel-worktree-spec-clusters`

## Problem

当前 `ssf-qa` 能从 OpenSpec requirements 生成 acceptance matrix、negative tests、risk matrix、regression checklist 和 QA signoff，但它仍以文档生成为主，缺少把用户路径真正跑起来并记录证据的标准协议。Agent 可能给出 QA 结论，却没有浏览器步骤、截图、日志或失败点可复查。

当前 Git / branch 规则能约束单个 change 的提交、PR 和 Spec 映射，但大 change 拆分后缺少 parent / cluster 关系、worktree 隔离、跨 cluster 依赖、集成 gate 和汇总 QA 的规则。并行开发如果没有统一 contract，容易产生重复 spec、冲突分支、无法追溯的 QA 证据和难以回滚的集成提交。

## Goals

- 定义 `browser-mcp-qa-adapter` 的边界：让 `ssf-qa` 从文档 QA 扩展为 evidence-backed 用户路径验收。
- 定义 `parallel-worktree-spec-clusters` 的边界：让大 change 可以拆成多个 cluster，并用 worktree 隔离执行。
- 定义 parent change、child implementation change、Spec cluster、worktree 和 integration gate 的关系。
- 规定 QA evidence 是后续 Review / Ship / Git / Archive 可引用的事实来源之一。
- 规定 worktree 是执行隔离机制，不是发布边界；最终发布责任仍归 parent change。
- 规定两个 implementation changes 的先后顺序：先做浏览器 QA 证据，再做并行 cluster 汇总。
- 明确第一阶段不引入自动调度器、后台执行器或跨 agent 编排服务。

## Non-goals

- 不在本 change 中实现 `ssf-qa` 的浏览器或 MCP 调用逻辑。
- 不在本 change 中实现 worktree 创建、并行调度或自动 merge。
- 不定义具体 MCP server 的 vendor 绑定或浏览器工具内部 API。
- 不要求所有项目都必须具备可运行浏览器目标。
- 不绕过现有 OpenSpec change-id、Spec ID、QA、Ship 或 Git gate。
- 不把多个 cluster 的通过状态等同于 parent change 可发布。

## User Impact

用户在规划大规模流程增强时，可以先通过 parent architecture change 锁定两个 implementation changes 的共同规则，再分阶段实现。后续使用者可以期待：

- `/ssf-qa` 在有可运行目标和浏览器/MCP 工具时生成真实路径执行证据。
- `/ssf-qa` 在目标或工具不可用时给出明确 blocked signoff，而不是假装通过。
- 大 change 可以拆成多个 cluster 独立实现、测试和提交。
- parent change 可以汇总各 cluster 的 QA evidence，并执行最终集成回归。

## Affected Areas

- `openspec/changes/workflow-scale-architecture/`
- 后续 `openspec/changes/browser-mcp-qa-adapter/`
- 后续 `openspec/changes/parallel-worktree-spec-clusters/`
- `skills/ssf-qa/SKILL.md`
- `agents/qa-gatekeeper.md`
- `skills/ssf-spec/SKILL.md`
- `skills/ssf-build/SKILL.md`
- `skills/ssf-git/SKILL.md`
- `skills/ssf-ship/SKILL.md`
- `commands/`
- `routing/AGENTS.routing.md`
- `routing/CLAUDE.routing.md`
- `templates/`
- `scripts/validate-pack.sh`
- `tests/`
- `README.md`
- `docs/branching-strategy.md`

## Success Metrics

- Parent architecture spec 明确两个 implementation changes 的职责、先后顺序和集成关系。
- `browser-mcp-qa-adapter` 有清晰的 QA evidence 文件协议和 blocked 状态语义。
- `parallel-worktree-spec-clusters` 有清晰的 parent / cluster / worktree / integration gate 语义。
- 每个后续 implementation change 都可以独立拥有 OpenSpec proposal、specs、design、tasks、QA 和 commit。
- 汇总 QA / Ship gate 不接受只有聊天结论、没有落盘证据的完成声明。
- 后续实现可以通过自动化测试或 pack validation 检查关键规则是否写入对应 skills、routing、templates 和 docs。
- 本 change 的 tasks 只覆盖父级架构 contract、child OpenSpec 骨架、路线图同步和映射产物，不包含 child implementation 的代码落地。

## Risks

- 浏览器/MCP 工具在不同运行环境中可用性不一致，可能导致 QA 结论频繁变成 blocked。
- 如果 QA evidence 文件协议过重，agent 可能不维护或维护不一致。
- 如果 cluster 拆分规则过宽，可能把强依赖任务错误并行化。
- 多 worktree 增加 Git 操作复杂度，可能放大未提交改动、分支漂移和集成冲突风险。
- Parent / cluster 关系如果不明确，可能出现 cluster 通过但 parent integration 未验证的发布误判。

## Rollout Strategy

采用三阶段 rollout：

1. `workflow-scale-architecture`：只提交总架构 OpenSpec，明确两个后续 change 的 contract。
2. `browser-mcp-qa-adapter`：先增强 `ssf-qa` 的 executable journey、browser run report、QA evidence 和 blocked signoff 规则。
3. `parallel-worktree-spec-clusters`：再增强大 change 拆分、worktree 隔离、cluster status 和 parent integration gate。

`/ssf-qa <parent-change>` 汇总 cluster QA evidence 的联动能力归入 `parallel-worktree-spec-clusters` 的集成验收子阶段，不单独创建第三个 implementation change。该子阶段要求 parent integration browser QA 通过，或写入明确 blocked signoff 后才能进入 ship。

## Open Questions

- 浏览器/MCP QA evidence 第一版是否只记录文本摘要和截图路径，还是也标准化 trace / console / network 摘要字段？
- Spec cluster 第一版是否允许跨仓库 worktree，还是只支持同一 Git 仓库内的多个 worktree？
- Parent change 的最终 PR 是否必须 squash cluster commits，还是保留每个 cluster 的独立 commit 历史？
