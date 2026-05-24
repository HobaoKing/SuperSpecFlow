# Technical Design: workflow-scale-architecture

## Architecture Summary

`workflow-scale-architecture` 是一个父级架构 change，用来约束两个后续 implementation changes：

```text
workflow-scale-architecture
  ├─ browser-mcp-qa-adapter
  └─ parallel-worktree-spec-clusters
```

第一阶段先让 QA 证据可复查。`browser-mcp-qa-adapter` 扩展 `ssf-qa`，把 acceptance matrix 转成可执行用户路径，并在可运行目标和浏览器/MCP 工具存在时执行真实路径。执行结果写入 QA runtime 目录，作为 Review、Ship、Git 和 Archive 可引用的事实来源。

第二阶段再让大 change 可并行。`parallel-worktree-spec-clusters` 扩展 OpenSpec / Build / Git / QA 规则，让 parent change 可以拆出多个 Spec cluster，每个 cluster 在独立 worktree 中执行，但最终必须回到 parent integration gate 做跨 cluster 回归和发布判断。

## Phase Model

### Phase 0: Parent Architecture

本 change 只定义架构合同，不实现行为：

- 固定两个后续 change 的名称、顺序和依赖关系。
- 固定 QA evidence 与 cluster integration 的共同术语。
- 固定不允许跳过的 gate。

### Phase 1: Browser / MCP QA Adapter

目标：`ssf-qa` 从文档 QA 升级为 evidence-backed QA。

新增建议产物：

```text
.superspecflow/qa/<change-id>/
  acceptance-matrix.md
  negative-test-matrix.md
  risk-matrix.md
  regression-checklist.md
  exploratory-test-notes.md
  qa-execution-plan.md
  browser-run-report.md
  qa-signoff.md
  qa-evidence/
```

最小可用行为：

1. 从 acceptance matrix 找出 E2E / user journey 场景。
2. 生成 `qa-execution-plan.md`，记录入口、前置数据、步骤、预期和证据类型。
3. 检测是否存在可运行目标和浏览器/MCP 工具。
4. 可执行时运行真实用户路径并写入 `browser-run-report.md`。
5. 不可执行时写明确 blocked signoff。

### Phase 2: Parallel Worktree Spec Clusters

目标：大 change 可拆分、并行、汇总和发布。

新增建议产物：

```text
.superspecflow/clusters/<parent-change>/
  cluster-plan.md
  cluster-status.md
  integration-gate.md
```

推荐 cluster 命名：

```text
<parent-change>/<cluster-id>
```

推荐分支命名：

```text
ssf/<parent-change>-<cluster-id>-<short-slug>
```

非 cluster 工作继续沿用现有 `ssf/<change-id>-<中文或拼音短描述>` 规则；cluster 场景只是在现有规则上叠加 `<cluster-id>` 段，后续 `parallel-worktree-spec-clusters` 不应替换普通 change 的分支命名规则。

推荐 worktree 命名：

```text
../<repo>-worktrees/<parent-change>/<cluster-id>
```

最小可用行为：

1. Parent change 先定义整体目标、non-goals、跨 cluster 约束和最终 gate。
2. `cluster-plan.md` 定义 cluster 拆分、依赖、worktree、分支和集成顺序。
3. 每个 cluster 独立执行 `ssf-build`、`ssf-review`、`ssf-qa` 和 `ssf-git`。
4. `cluster-status.md` 追踪每个 cluster 的当前状态和证据引用。
5. Parent integration worktree 汇总各 cluster，并运行跨 cluster 回归。
6. `integration-gate.md` 成为 parent ship gate 的输入。

### Phase 3: Linked Parent QA

目标：`/ssf-qa <parent-change>` 自动汇总 cluster evidence。

Phase 3 不是单独的第三个 implementation change，而是 `parallel-worktree-spec-clusters` 的集成验收子阶段，对应 SSF-WORKFLOW-012 和 SSF-WORKFLOW-014。第一版不需要自动调度 cluster，只需要定义读取与汇总规则：

1. 读取 parent `cluster-plan.md`。
2. 读取每个 cluster 的 QA signoff、browser run report 和 evidence。
3. 检查跨 cluster 依赖、冲突和回归风险。
4. 执行 parent integration QA，或记录为什么 blocked。
5. 生成 parent QA signoff 和 integration gate 结论。

## Data Flow

### Browser QA Data Flow

```text
OpenSpec requirements
  → acceptance-matrix.md
  → qa-execution-plan.md
  → browser/MCP execution
  → qa-evidence/
  → browser-run-report.md
  → qa-signoff.md
  → ssf-ship input
```

OpenSpec requirements 仍是需求来源。QA evidence 只证明某次执行结果，不改变需求本身。

### Cluster Data Flow

```text
Parent OpenSpec
  → cluster-plan.md
  → cluster OpenSpec/tasks/maps
  → cluster worktrees
  → cluster review/QA/commits
  → cluster-status.md
  → integration-gate.md
  → parent QA/Ship/Git
```

Cluster 可以并行执行，但 parent integration gate 必须串行确认最终状态。

## API / Interface Changes

本 change 不实现代码 API。后续 changes 应扩展以下人机接口：

- `/ssf-qa <change-id>`：支持生成 execution plan、browser run report 和 evidence-backed signoff。
- `/ssf-spec <change-id>`：支持提示大 change 拆分为 parent / cluster。
- `/ssf-build <cluster-change>`：支持在 cluster worktree 中执行并更新 cluster status。
- `/ssf-branch <change-id>`：支持 parent / cluster 分支和 worktree 命名建议。
- `/ssf-ship <parent-change>`：支持读取 integration gate 和 cluster QA evidence。

## Data Model Changes

### QA Execution Plan

`qa-execution-plan.md` 应至少记录：

- Change ID
- Target URL or runnable target
- Tooling mode: browser, MCP, manual, blocked
- Spec IDs
- Journey name
- Preconditions
- Steps
- Expected results
- Evidence to capture

### Browser Run Report

`browser-run-report.md` 应至少记录：

- Run timestamp
- Agent
- Target
- Tool used
- Journey results
- Step-level pass/fail
- Screenshot / trace / console / network references
- Failure point
- Follow-up required

### Cluster Plan

`cluster-plan.md` 应至少记录：

- Parent change
- Cluster IDs
- Goal and non-goals per cluster
- Spec IDs per cluster
- Dependencies
- Worktree path
- Branch
- Integration order
- QA expectations

### Integration Gate

`integration-gate.md` 应至少记录：

- Parent change
- Cluster status summary
- QA evidence summary
- Cross-cluster regression results
- Conflicts and resolutions
- Release blockers
- Residual risk
- Ship recommendation

## Security / Permission Considerations

Browser QA evidence 可能包含本地 URL、截图、控制台日志、网络摘要和测试数据。Agent 不得保存 secret、token、凭据、生产客户数据或敏感日志。若证据来自真实环境，必须在 signoff 中标记环境和脱敏状态。

Worktree 并行开发会增加本地路径和分支数量。Agent 在创建、删除或清理 worktree 前必须检查未提交改动，不得执行破坏性清理，除非用户明确批准。

## Failure Modes

- 没有可运行目标：`ssf-qa` 使用 `Blocked: No runnable target`，并列出需要用户提供的目标或启动命令。
- 浏览器/MCP 工具不可用：`ssf-qa` 使用 `Blocked: Tool unavailable`，并给出人工验证替代步骤。
- 用户路径失败：`ssf-qa` 使用 `Failed`，记录失败步骤、证据和阻塞影响。
- Cluster 依赖未满足：parent integration gate 标记 blocker，不允许进入 ship。
- Cluster QA 缺失：parent QA 标记 blocker，不接受 cluster 只靠口头完成声明。
- Worktree 与分支漂移：cluster status 标记风险，进入 integration 前必须重新审计 Git 状态。

## Observability

第一版 observability 通过文件协议提供：

- QA 层：`qa-execution-plan.md`、`browser-run-report.md`、`qa-evidence/`、`qa-signoff.md`
- Cluster 层：`cluster-plan.md`、`cluster-status.md`、`integration-gate.md`
- Git 层：commit message、PR description、git status audit

后续 pack validation 应检查关键 skill、routing、template 和 docs 是否包含这些协议名和 blocked 状态。

## Migration Plan

无既有运行时数据需要迁移。现有 `ssf-qa` 产物保持兼容，新增 QA execution 和 evidence 文件只在后续 `browser-mcp-qa-adapter` 中引入。

现有 branch strategy 保持兼容，新增 worktree / cluster 规则只在后续 `parallel-worktree-spec-clusters` 中引入。

## Rollback Plan

回滚本 change 只会移除总架构 OpenSpec，不影响已实现代码。后续 implementation changes 应分别提供自己的 rollback plan。

如果后续 `browser-mcp-qa-adapter` 失败，可以回滚到文档 QA 模式。

如果后续 `parallel-worktree-spec-clusters` 失败，可以回滚到单 change / 单 branch 开发模式。

## Alternatives Considered

- 一次性实现两个能力：拒绝。影响面过大，QA evidence 和并行汇总应分阶段验证。
- 先做 worktree cluster，再做 browser QA：拒绝。并行开发会放大验收证据不足的问题，应先建立可复查 QA evidence。
- 只做文档模板，不接入 `ssf-qa` / `ssf-build` / `ssf-git`：拒绝。能力必须进入执行流程，否则无法形成门禁。
- 引入后台调度器自动分配 cluster：拒绝。第一版应保持文件协议和人工确认，避免过早引入复杂运行时。
