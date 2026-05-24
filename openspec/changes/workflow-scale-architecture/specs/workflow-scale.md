# Spec: workflow-scale

## ADDED Requirements

### Requirement: SSF-WORKFLOW-001 定义两阶段能力架构

系统必须把 workflow scale 能力拆成 `browser-mcp-qa-adapter` 和 `parallel-worktree-spec-clusters` 两个后续 implementation changes，并由 `workflow-scale-architecture` 作为父级架构 contract 约束二者关系。

#### Scenario: 规划 workflow scale 路线
- GIVEN 用户选择先设计总架构再分阶段实现
- WHEN agent 创建 workflow scale OpenSpec
- THEN 系统记录 `workflow-scale-architecture` 作为父级架构 change
- AND 系统记录 `browser-mcp-qa-adapter` 作为第一阶段 implementation change
- AND 系统记录 `parallel-worktree-spec-clusters` 作为第二阶段 implementation change

### Requirement: SSF-WORKFLOW-002 先建立 QA evidence 再扩展并行开发

系统必须规定 `browser-mcp-qa-adapter` 在 `parallel-worktree-spec-clusters` 之前实现，除非用户明确豁免该顺序。

#### Scenario: 制定分阶段实现计划
- GIVEN 两个 implementation changes 都尚未实现
- WHEN agent 规划阶段顺序
- THEN agent 先规划 `browser-mcp-qa-adapter`
- AND agent 再规划 `parallel-worktree-spec-clusters`
- AND agent 说明并行开发汇总依赖可复查的 QA evidence

#### Scenario: 用户明确豁免阶段顺序
- GIVEN 用户要求先实现 `parallel-worktree-spec-clusters`
- WHEN agent 接受该豁免
- THEN agent 必须在对应 child change 的 `proposal.md` 中记录豁免原因
- AND 记录位置必须是 `Rollout Strategy` 或 `Open Questions`
- AND agent 必须说明 QA evidence 尚未落地时的 parent integration 风险

### Requirement: SSF-WORKFLOW-003 定义 QA evidence 为可复查事实来源

系统必须定义 QA evidence 为 Review、Ship、Git 和 Archive 可引用的事实来源，但 QA evidence 不得替代 OpenSpec requirements 或 Spec ID。

#### Scenario: Ship gate 检查 QA 结果
- GIVEN `ssf-qa` 已生成 evidence-backed signoff
- WHEN `ssf-ship` 判断是否可发布
- THEN `ssf-ship` 可以引用 QA evidence 中的浏览器步骤、截图、日志摘要或 blocked 原因
- AND `ssf-ship` 仍必须以 OpenSpec requirements、Spec ID 和 QA signoff 作为发布判断基础

### Requirement: SSF-WORKFLOW-004 定义浏览器 QA 执行状态

系统必须为浏览器/MCP QA 定义标准执行状态：`Automated Browser Passed`、`Manual Verified`、`Blocked: No runnable target`、`Blocked: Tool unavailable` 和 `Failed`。

#### Scenario: 可运行目标和浏览器工具都存在
- GIVEN change 有可执行用户路径
- AND 本地或远程测试目标可访问
- AND 浏览器/MCP 工具可用
- WHEN `ssf-qa` 执行用户路径
- THEN QA signoff 使用 `Automated Browser Passed` 表示自动化浏览器路径通过
- AND evidence 记录执行步骤、结果和证据引用

#### Scenario: 没有可运行目标
- GIVEN change 有可执行用户路径
- AND 没有可访问的测试目标
- WHEN `ssf-qa` 尝试执行浏览器 QA
- THEN QA signoff 使用 `Blocked: No runnable target`
- AND signoff 不得声明浏览器路径已经通过

#### Scenario: 浏览器或 MCP 工具不可用
- GIVEN change 有可执行用户路径
- AND 测试目标可访问
- AND 浏览器或 MCP 工具不可用
- WHEN `ssf-qa` 尝试执行浏览器 QA
- THEN QA signoff 使用 `Blocked: Tool unavailable`
- AND signoff 记录缺失工具和可执行的人工替代验证

### Requirement: SSF-WORKFLOW-005 定义可执行用户路径计划

系统必须要求 `browser-mcp-qa-adapter` 为 `ssf-qa` 增加 `.superspecflow/qa/<change-id>/qa-execution-plan.md`，用于把 acceptance matrix 中的 scenario 转成可执行用户路径。

#### Scenario: 从 acceptance matrix 生成执行计划
- GIVEN `acceptance-matrix.md` 包含 E2E 或用户路径级 scenario
- WHEN `ssf-qa` 准备执行浏览器 QA
- THEN agent 生成 `.superspecflow/qa/<change-id>/qa-execution-plan.md`
- AND 每个可执行路径引用对应 Spec ID
- AND 每个路径说明入口 URL、前置数据、操作步骤、预期结果和证据类型

### Requirement: SSF-WORKFLOW-006 定义浏览器执行报告

系统必须要求 `browser-mcp-qa-adapter` 为 `ssf-qa` 增加 `.superspecflow/qa/<change-id>/browser-run-report.md`，用于记录浏览器/MCP 执行步骤、实际结果、失败点和证据引用。

#### Scenario: 浏览器路径执行完成
- GIVEN `ssf-qa` 执行了一个用户路径
- WHEN 执行结束
- THEN agent 写入 `.superspecflow/qa/<change-id>/browser-run-report.md`
- AND 记录目标、工具、步骤、结果、失败点、截图或日志摘要引用
- AND 结果状态与 `qa-signoff.md` 保持一致

### Requirement: SSF-WORKFLOW-007 定义 QA evidence 目录

系统必须要求浏览器/MCP QA 证据默认写入 `.superspecflow/qa/<change-id>/qa-evidence/`，并由 QA 文档引用证据路径。

#### Scenario: 记录截图或日志摘要
- GIVEN `ssf-qa` 生成截图、trace、console 摘要或 network 摘要
- WHEN agent 需要保存证据
- THEN agent 将证据写入 `.superspecflow/qa/<change-id>/qa-evidence/`
- AND `browser-run-report.md` 或 `qa-signoff.md` 引用对应路径

### Requirement: SSF-WORKFLOW-008 定义 parent change 与 Spec cluster

系统必须定义 parent change 负责整体目标、跨 cluster 约束和最终发布 gate；Spec cluster 负责一个可独立实现、验证和提交的子范围。

#### Scenario: 大 change 被拆成多个 cluster
- GIVEN 一个 change 过大，无法由单个 agent 或单个工作区可靠完成
- WHEN agent 拆分该 change
- THEN agent 创建或引用 parent change
- AND agent 定义多个 Spec cluster
- AND 每个 cluster 有自己的范围、Spec ID、任务、测试和交付证据
- AND parent change 保留最终 integration gate

#### Scenario: Agent 评估是否需要 cluster 拆分
- GIVEN 一个 change 预计包含超过 8 个 tasks
- OR 一个 change 预计包含超过 6 个 Spec IDs
- OR 一个 change 横跨两个以上相对独立的子系统
- WHEN agent 进入 `ssf-spec` 或 `ssf-build` 前置判断
- THEN agent 必须评估是否拆成 Spec cluster
- AND 如果不拆分，必须在 parent proposal、design 或 implementation plan 中记录原因

### Requirement: SSF-WORKFLOW-009 定义 worktree 为执行隔离机制

系统必须规定 worktree 只用于隔离并行执行环境，不得把 worktree 视为独立发布边界。

#### Scenario: 为 cluster 创建 worktree
- GIVEN parent change 拆出一个 cluster
- WHEN agent 为该 cluster 创建 worktree
- THEN worktree 名称和分支必须关联 parent change 与 cluster id
- AND cluster 的提交、QA 和 review 仍必须映射到 Spec ID
- AND parent change 仍负责最终集成和发布判断

### Requirement: SSF-WORKFLOW-010 定义 cluster plan

系统必须要求 `parallel-worktree-spec-clusters` 增加 `.superspecflow/clusters/<parent-change>/cluster-plan.md`，用于描述 cluster 拆分、依赖、worktree、owner、集成顺序和验收边界。

#### Scenario: 规划 cluster 拆分
- GIVEN parent change 需要拆成多个 cluster
- WHEN agent 进入 cluster planning
- THEN agent 生成 `.superspecflow/clusters/<parent-change>/cluster-plan.md`
- AND 每个 cluster 记录 cluster id、目标、Spec IDs、依赖、worktree、分支、验证策略和集成顺序

### Requirement: SSF-WORKFLOW-011 定义 cluster status

系统必须要求 `parallel-worktree-spec-clusters` 增加 `.superspecflow/clusters/<parent-change>/cluster-status.md`，用于记录每个 cluster 的分支、worktree、阶段、测试、QA、review、commit 和阻塞状态。

#### Scenario: 更新 cluster 执行状态
- GIVEN 某个 cluster 完成 build、review、QA 或 commit
- WHEN agent 更新 parent change 状态
- THEN agent 更新 `.superspecflow/clusters/<parent-change>/cluster-status.md`
- AND 状态引用该 cluster 的 evidence、commit 或 blocker

### Requirement: SSF-WORKFLOW-012 定义 parent integration gate

系统必须要求 `parallel-worktree-spec-clusters` 增加 `.superspecflow/clusters/<parent-change>/integration-gate.md`，用于汇总所有 cluster 的验收结果、跨 cluster 回归、冲突解决、剩余风险和 ship 建议。

#### Scenario: 所有 cluster 准备合入 parent
- GIVEN 所有 cluster 标记为 ready for integration
- WHEN agent 准备进入 parent ship gate
- THEN agent 生成或更新 `.superspecflow/clusters/<parent-change>/integration-gate.md`
- AND `.superspecflow/clusters/<parent-change>/integration-gate.md` 汇总每个 cluster 的 Spec IDs、QA evidence、review 结论、commit、阻塞项和跨 cluster 回归结果
- AND 没有 integration gate 时不得把 parent change 标记为可发布

### Requirement: SSF-WORKFLOW-013 定义 child changes 独立可审计

系统必须要求每个 implementation change 和每个 Spec cluster 都保留独立的 OpenSpec、tasks、spec-to-code map、QA 和 Git 证据，除非用户明确选择轻量模式且 Intake Gate 允许。

#### Scenario: cluster 完成一个可验证任务
- GIVEN cluster agent 完成一个 task
- WHEN agent 准备提交或交接
- THEN agent 更新该 cluster 对应的 tasks 和 spec-to-code map
- AND 记录验证证据
- AND commit 信息引用对应 change-id 和 Spec IDs

### Requirement: SSF-WORKFLOW-014 定义 parent 汇总 QA 规则

系统必须要求 `/ssf-qa <parent-change>` 汇总 cluster QA evidence，并额外执行或记录 parent integration 级回归。

#### Scenario: parent change 进入 QA
- GIVEN parent change 有多个 cluster
- WHEN agent 执行 `/ssf-qa <parent-change>`
- THEN agent 读取每个 cluster 的 QA signoff 和 evidence
- AND agent 检查跨 cluster 依赖和回归风险
- AND agent 记录 parent integration 级 QA 结论

## MODIFIED Requirements

无。

## REMOVED Requirements

无。

## MUST NOT

- SSF-WORKFLOW-N1 系统不得用没有落盘 evidence 的聊天结论替代 QA signoff。
- SSF-WORKFLOW-N2 `ssf-qa` 不得在没有可运行目标或工具不可用时声明 `Automated Browser Passed`。
- SSF-WORKFLOW-N3 Worktree 不得被当作发布边界；发布责任必须回到 parent change。
- SSF-WORKFLOW-N4 Cluster 通过不得自动等同于 parent change 可发布。
- SSF-WORKFLOW-N5 多 cluster 并行不得绕过 change-id、Spec ID、Review、QA、Ship 或 Git gate。
- SSF-WORKFLOW-N6 第一版不得实现后台调度器、自动 merge 服务或跨 agent 编排服务。

## MUST NOT Violation Signals

| MUST NOT | 可观察违规现象 |
|---|---|
| SSF-WORKFLOW-N1 | `qa-signoff.md` 声明通过，但找不到 `browser-run-report.md`、`qa-evidence/` 引用或明确人工验证记录。 |
| SSF-WORKFLOW-N2 | `qa-signoff.md` 使用 `Automated Browser Passed`，但同时记录目标不可访问、浏览器/MCP 工具缺失或没有执行步骤。 |
| SSF-WORKFLOW-N3 | `ssf-ship` 仅基于某个 worktree 的状态判断可发布，未引用 parent change 和 `.superspecflow/clusters/<parent-change>/integration-gate.md`。 |
| SSF-WORKFLOW-N4 | 所有 cluster 标记通过后，parent change 未执行或未记录跨 cluster 回归就进入 ship。 |
| SSF-WORKFLOW-N5 | Cluster commit、QA 或 review 缺少 change-id、Spec ID 或对应 gate 记录。 |
| SSF-WORKFLOW-N6 | 第一版引入后台守护进程、自动 merge 服务、跨 agent 编排服务或要求 agent 自动通信。 |
