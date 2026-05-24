# Spec: spec-clusters

## ADDED Requirements

### Requirement: SSF-CLUSTER-001 定义 parent change

系统必须定义 parent change 作为大 change 的整体目标、跨 cluster 约束和最终发布责任载体。

#### Scenario: 创建 parent change
- GIVEN 一个 change 预计需要拆分多个并行子范围
- WHEN agent 进入 `ssf-spec`
- THEN agent 创建或引用 parent change
- AND parent change 记录整体目标、non-goals、跨 cluster 依赖和最终 gate
- AND parent change 不得被单个 cluster 的通过状态替代

### Requirement: SSF-CLUSTER-002 定义 Spec cluster

系统必须定义 Spec cluster 为 parent change 下可独立实现、验证和提交的子范围。

#### Scenario: 定义 cluster
- GIVEN parent change 需要拆分
- WHEN agent 定义 Spec cluster
- THEN 每个 cluster 记录 cluster id、目标、non-goals、Spec IDs、依赖、测试策略和交付证据
- AND 每个 cluster 必须能独立进入 build、review、qa 和 git gate

### Requirement: SSF-CLUSTER-003 定义拆分评估阈值

系统必须要求 agent 在 change 预计超过 8 个 tasks、超过 6 个 Spec IDs，或横跨两个以上相对独立子系统时评估是否拆成 Spec cluster。

#### Scenario: 大 change 进入 spec
- GIVEN change 预计超过 8 个 tasks
- OR change 预计超过 6 个 Spec IDs
- OR change 横跨两个以上相对独立子系统
- WHEN agent 进入 `ssf-spec`
- THEN agent 必须评估 cluster 拆分
- AND 如果不拆分，必须在 proposal、design 或 implementation plan 中记录原因

### Requirement: SSF-CLUSTER-004 定义 cluster plan

系统必须定义 `.superspecflow/clusters/<parent-change>/cluster-plan.md`，用于记录 cluster 拆分、依赖、worktree、owner、分支、集成顺序和验收边界。

#### Scenario: 规划 cluster
- GIVEN parent change 已确认需要 cluster
- WHEN agent 生成 cluster plan
- THEN agent 写入 `.superspecflow/clusters/<parent-change>/cluster-plan.md`
- AND 每个 cluster 记录 cluster id、Spec IDs、依赖、worktree path、branch、owner、QA expectations 和 integration order

### Requirement: SSF-CLUSTER-005 定义 cluster status

系统必须定义 `.superspecflow/clusters/<parent-change>/cluster-status.md`，用于记录每个 cluster 的阶段、worktree、分支、验证、review、QA、commit 和阻塞状态。

#### Scenario: Cluster 状态变化
- GIVEN cluster 完成 build、review、QA、commit 或遇到 blocker
- WHEN agent 更新 parent change 状态
- THEN agent 更新 `.superspecflow/clusters/<parent-change>/cluster-status.md`
- AND 状态引用该 cluster 的 evidence、commit、review 或 blocker

### Requirement: SSF-CLUSTER-006 定义 integration gate

系统必须定义 `.superspecflow/clusters/<parent-change>/integration-gate.md`，用于汇总 cluster 证据、跨 cluster 回归、冲突解决、release blockers 和 ship 建议。

#### Scenario: Parent change 准备 ship
- GIVEN parent change 有一个或多个 cluster
- WHEN agent 准备执行 `ssf-ship`
- THEN agent 必须读取 `.superspecflow/clusters/<parent-change>/integration-gate.md`
- AND integration gate 汇总每个 cluster 的 Spec IDs、QA evidence、review 结论、commit、阻塞项和跨 cluster 回归结果
- AND 缺少 integration gate 时不得推荐 parent change ship

### Requirement: SSF-CLUSTER-007 定义 worktree 命名规则

系统必须定义 cluster worktree 命名规则，并要求 worktree 只作为执行隔离机制。

#### Scenario: 为 cluster 创建 worktree
- GIVEN cluster 需要独立工作区
- WHEN agent 推荐或创建 worktree
- THEN worktree path 使用 `../<repo>-worktrees/<parent-change>/<cluster-id>` 或项目明确指定的等价路径
- AND worktree 不得被视为发布边界
- AND agent 在创建或清理 worktree 前必须检查未提交改动

### Requirement: SSF-CLUSTER-008 定义 cluster 分支命名规则

系统必须定义 cluster 分支命名规则，并保留普通 change 的既有分支命名规则。

#### Scenario: Cluster 创建分支
- GIVEN agent 为 cluster 创建分支
- WHEN 该工作属于 parent change 的 cluster
- THEN 分支名使用 `ssf/<parent-change>-<cluster-id>-<short-slug>` 或环境不支持 slash 时使用等价无 slash 形式
- AND 非 cluster 工作继续使用现有 `ssf/<change-id>-<short-slug>`、`spec/<change-id>-<short-slug>` 或 `process/<change-id>-<short-slug>` 规则

### Requirement: SSF-CLUSTER-009 保持 cluster 独立可审计

系统必须要求每个 cluster 保留独立 OpenSpec、tasks、spec-to-code map、review、QA 和 Git 证据。

#### Scenario: Cluster 完成可验证任务
- GIVEN cluster 完成一个 task
- WHEN agent 准备提交或交接
- THEN agent 更新该 cluster 的 tasks 和 spec-to-code map
- AND 记录验证证据
- AND commit 信息引用 cluster change-id 和 Spec IDs

### Requirement: SSF-CLUSTER-010 定义 parent QA 汇总

系统必须要求 `/ssf-qa <parent-change>` 汇总 cluster QA evidence，并额外执行或记录 parent integration 级回归。

#### Scenario: Parent change 进入 QA
- GIVEN parent change 有多个 cluster
- WHEN agent 执行 `/ssf-qa <parent-change>`
- THEN agent 读取 `cluster-plan.md` 和 `cluster-status.md`
- AND agent 汇总每个 cluster 的 QA signoff、browser run report、evidence 和 blocker
- AND agent 记录 parent integration 级回归结果或 blocked reason

### Requirement: SSF-CLUSTER-011 定义 parent ship gate

系统必须要求 `ssf-ship` 在 parent change 场景中读取 integration gate，并在 cluster evidence 不完整时阻断发布。

#### Scenario: Cluster evidence 缺失
- GIVEN parent change 有 cluster
- AND 任一 cluster 缺少 QA signoff、review 结论或 commit evidence
- WHEN agent 执行 `ssf-ship`
- THEN ship recommendation 必须是 no-ship 或 blocked
- AND agent 记录缺失证据和修复路径

### Requirement: SSF-CLUSTER-012 接入 routing 和 pack validation

系统必须将 cluster 文件协议和 gate 规则接入 routing、skills、templates、docs 和 pack validation。

#### Scenario: Pack validation 检查 cluster 规则
- GIVEN parallel worktree Spec clusters 已实现
- WHEN 运行 `rtk bash scripts/validate-pack.sh`
- THEN validation 检查 cluster templates、routing 和相关 skills 包含 cluster plan、cluster status、integration gate 和 worktree 边界规则

## MODIFIED Requirements

无。

## REMOVED Requirements

无。

## MUST NOT

- SSF-CLUSTER-N1 系统不得把 worktree 当作发布边界。
- SSF-CLUSTER-N2 系统不得把所有 cluster 通过自动等同于 parent change 可发布。
- SSF-CLUSTER-N3 多 cluster 并行不得绕过 change-id、Spec ID、Review、QA、Ship 或 Git gate。
- SSF-CLUSTER-N4 缺少 `.superspecflow/clusters/<parent-change>/integration-gate.md` 时不得推荐 parent ship。
- SSF-CLUSTER-N5 第一版不得实现后台调度器、自动 merge 服务或跨 agent 编排服务。
- SSF-CLUSTER-N6 第一版不得支持跨仓库 cluster，除非后续 change 明确定义跨仓库 contract。
- SSF-CLUSTER-N7 Agent 不得删除或清理 worktree，除非用户明确批准且已检查未提交改动。

## MUST NOT Violation Signals

| MUST NOT | 可观察违规现象 |
|---|---|
| SSF-CLUSTER-N1 | `ssf-ship` 仅引用 worktree 状态，未引用 parent change 和 integration gate。 |
| SSF-CLUSTER-N2 | Cluster status 全部通过后，parent change 未记录 integration regression 就进入 ship。 |
| SSF-CLUSTER-N3 | Cluster commit、QA 或 review 缺少 change-id、Spec ID 或对应 gate 记录。 |
| SSF-CLUSTER-N4 | 缺少 `integration-gate.md` 时，`ship-decision.md` 推荐 ship。 |
| SSF-CLUSTER-N5 | 第一版新增后台守护进程、自动 merge 服务或 agent 自动通信要求。 |
| SSF-CLUSTER-N6 | 第一版要求读取或写入另一个 Git 仓库的 cluster 产物。 |
| SSF-CLUSTER-N7 | Agent 在未检查 status 或未获批准时删除 worktree。 |
