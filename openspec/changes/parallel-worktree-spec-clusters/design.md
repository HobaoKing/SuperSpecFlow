# Technical Design: parallel-worktree-spec-clusters

## Architecture Summary

`parallel-worktree-spec-clusters` 为大 change 增加 parent / cluster 文件协议。Parent change 负责整体目标、跨 cluster 约束和最终发布责任；Spec cluster 负责独立实现、验证和提交的子范围。

新增 cluster runtime namespace：

```text
.superspecflow/clusters/<parent-change>/
  cluster-plan.md
  cluster-status.md
  integration-gate.md
```

Worktree 是执行隔离机制，不是发布边界。所有发布判断必须回到 parent integration gate。

## Data Flow

```text
Parent OpenSpec
  → cluster-plan.md
  → cluster OpenSpec / tasks / maps
  → cluster worktrees and branches
  → cluster build / review / QA / commit
  → cluster-status.md
  → integration-gate.md
  → parent QA / Ship / Git
```

Cluster 可以并行执行，但 parent integration 必须串行确认冲突、回归和发布风险。

## API / Interface Changes

### `ssf-spec`

- 在大 change 达到拆分阈值时提示 cluster planning。
- 生成或要求 `cluster-plan.md`。
- 保持 parent change 与 child cluster 的 Spec ID 映射。

### `ssf-build`

- 在 cluster worktree 中执行时读取 parent `cluster-plan.md`。
- 每个 cluster 独立维护 tasks、spec-to-code map 和验证证据。
- 完成 build/review/QA/commit 后更新 `cluster-status.md`。

### `ssf-git`

- 为 cluster 分支推荐 `ssf/<parent-change>-<cluster-id>-<short-slug>`。
- 环境不支持 slash branch 时，允许等价无 slash 形式。
- 提交仍必须包含 change-id、Spec ID、验证方式、风险与回滚。

### `ssf-qa`

- 对 cluster change 执行普通 QA。
- 对 parent change 汇总 cluster QA evidence，并记录 parent integration 回归。

### `ssf-ship`

- Parent change 场景必须读取 integration gate。
- Cluster evidence 不完整时不得推荐 ship。

## Data Model Changes

### Cluster Plan

`cluster-plan.md` 最小字段：

- Parent change
- Cluster id
- Cluster goal
- Non-goals
- Spec IDs
- Dependencies
- Worktree path
- Branch
- Owner / agent
- QA expectations
- Integration order

### Cluster Status

`cluster-status.md` 最小字段：

- Cluster id
- Worktree path
- Branch
- Phase
- Build status
- Review status
- QA status
- Commit / PR reference
- Blockers
- Last verification

### Integration Gate

`integration-gate.md` 最小字段：

- Parent change
- Cluster summary
- Evidence reviewed
- Cross-cluster regression
- Conflicts and resolutions
- Release blockers
- Residual risk
- Ship recommendation

## Security / Permission Considerations

Worktree 操作会增加本地目录和分支数量。Agent 在创建 worktree 前应审计当前分支和工作区；在清理 worktree 前必须获得用户明确批准并检查未提交改动。

Cluster evidence 可能引用 QA artifacts、commit、PR 或本地路径。不得写入 secret、token、凭据或生产客户数据。

## Failure Modes

- Cluster plan missing：暂停 parent build/ship，要求先生成 cluster plan。
- Cluster status stale：进入 integration 前重新审计 Git status、commit 和 QA evidence。
- Cluster dependency missing：integration gate 标记 blocker。
- Cluster QA missing：parent QA 标记 blocker。
- Merge conflict：integration gate 记录冲突和解决结果，未解决前 no-ship。
- Worktree cleanup unsafe：停止清理并要求用户确认。

## Observability

第一版通过文件协议提供可观察性：

- `cluster-plan.md` 说明如何拆。
- `cluster-status.md` 说明各 cluster 做到哪里。
- `integration-gate.md` 说明 parent 是否可以进入 ship。

后续 pack validation 应检查 templates、routing、skills 和 docs 中的关键路径与 gate 规则。

## Migration Plan

现有单 change 流程保持不变。只有达到拆分阈值或用户明确选择 cluster 模式时，才创建 `.superspecflow/clusters/<parent-change>/`。

普通分支命名规则保持兼容；cluster 分支命名是叠加规则。

## Rollback Plan

回滚本 change 的实现后，SuperSpecFlow 回到单 change / 单 branch 工作流。已生成的 `.superspecflow/clusters/<parent-change>/` 属于宿主项目运行时产物，可按宿主项目策略保留或删除。

## Alternatives Considered

- 用多个独立 change 替代 parent / cluster：拒绝，缺少 parent integration gate 会让最终发布责任不清。
- 自动调度 worktree 并自动 merge：拒绝，第一版需要文件协议和人工确认，不引入后台调度器。
- 支持跨仓库 cluster：拒绝，第一版先限定同一 Git 仓库，避免跨仓库发布责任和证据路径复杂化。
- 把 cluster status 写进 OpenSpec tasks：拒绝，tasks 是计划与完成状态，cluster status 需要汇总 worktree、分支、QA、review 和 commit evidence。
