# Spec: progress

## ADDED Requirements

### Requirement: SSF-PROGRESS-001 定义 change 级进度目录

系统必须定义 `.superspecflow/progress/<change-id>/` 作为单个 OpenSpec change 的运行时进度目录。

#### Scenario: Agent 开始处理已有 change
- GIVEN agent 准备处理 `<change-id>`
- WHEN agent 需要记录执行进度
- THEN agent 使用 `.superspecflow/progress/<change-id>/` 作为该 change 的进度目录
- AND 该目录不得替代 `openspec/changes/<change-id>/` 的需求契约

### Requirement: SSF-PROGRESS-002 定义 state.json 当前状态协议

系统必须定义 `.superspecflow/progress/<change-id>/state.json` 作为机器可读的当前状态摘要。

#### Scenario: Agent 更新当前任务状态
- GIVEN agent 完成或切换当前工作项
- WHEN agent 更新 progress 状态
- THEN agent 更新 `state.json`
- AND `state.json` 至少记录 `change_id`、`phase`、`status`、`current_task`、`completed_tasks`、`blocked`、`blockers`、`last_updated`、`last_agent`、`last_verification` 和 `openspec.change_path`

### Requirement: SSF-PROGRESS-003 定义 timeline.md 事件记录

系统必须定义 `.superspecflow/progress/<change-id>/timeline.md` 作为 append-oriented 的人类可读事件日志。

#### Scenario: Agent 记录关键执行事件
- GIVEN agent 开始任务、完成任务、遇到阻塞、恢复工作或做出关键决策
- WHEN 该事件影响后续 agent 理解进度
- THEN agent 在 `timeline.md` 追加事件记录
- AND 记录包含时间、agent、事件类型和摘要

### Requirement: SSF-PROGRESS-004 定义 verification.md 验证证据记录

系统必须定义 `.superspecflow/progress/<change-id>/verification.md` 作为验证证据记录文件。

#### Scenario: Agent 运行验证
- GIVEN agent 运行自动化测试、静态检查、烟测或人工检查
- WHEN 验证结果用于支持进度或完成声明
- THEN agent 在 `verification.md` 记录时间、agent、范围、命令或人工方法、结果和输出摘要
- AND agent 在 `state.json.last_verification` 引用最近相关验证记录

### Requirement: SSF-PROGRESS-005 定义 handoff.md 交接恢复摘要

系统必须定义 `.superspecflow/progress/<change-id>/handoff.md` 作为中断、上下文压缩或更换 agent 后的人类可读恢复摘要。

#### Scenario: Agent 准备交接
- GIVEN agent 即将停止且 meaningful work remains
- WHEN agent 更新 progress 交接信息
- THEN agent 更新 `handoff.md`
- AND `handoff.md` 说明当前状态、已完成内容、下一步、新鲜验证、已知风险和建议继续阅读的文件

### Requirement: SSF-PROGRESS-006 恢复时先读 progress 状态

系统必须要求 agent 在中断、上下文压缩或更换 agent 后，先读取 `state.json` 和 `handoff.md`，再读取 OpenSpec 文件。

#### Scenario: 新 agent 恢复已有 change
- GIVEN 新 agent 接手 `<change-id>`
- WHEN `.superspecflow/progress/<change-id>/` 存在
- THEN agent 先读取 `state.json`
- AND agent 再读取 `handoff.md`
- AND agent 随后读取 `openspec/changes/<change-id>/proposal.md`、`design.md`、`tasks.md` 和相关 `specs/*.md`

### Requirement: SSF-PROGRESS-007 恢复时识别进度与 OpenSpec 差异

系统必须要求 agent 在恢复时对比 progress 状态与 OpenSpec tasks / requirements。

#### Scenario: Progress 与 OpenSpec 不一致
- GIVEN `state.json` 或 `handoff.md` 中的状态与 OpenSpec tasks / requirements 不一致
- WHEN agent 恢复工作
- THEN agent 以 OpenSpec 作为需求契约来源
- AND 以 progress 作为执行事实来源
- AND agent 在 `timeline.md` 记录发现的差异和处理结果

### Requirement: SSF-PROGRESS-008 更新 progress 时保持状态时间戳

系统必须要求 agent 修改任一 progress 文件后同步更新 `state.json.last_updated`。

#### Scenario: Agent 写入验证记录
- GIVEN agent 修改 `verification.md`
- WHEN 修改完成
- THEN agent 更新 `state.json.last_updated`
- AND `last_updated` 表示该 progress 状态最近更新时间

### Requirement: SSF-PROGRESS-009 完成声明必须引用 fresh verification

系统必须要求 agent 在声称任务、阶段或 change 完成前，写入或引用 fresh verification。

#### Scenario: Agent 声称任务完成
- GIVEN agent 准备声明某个任务完成
- WHEN 最新相关文件、行为或任务范围已经变更
- THEN agent 必须先运行或执行适用验证
- AND 在 `verification.md` 写入或引用该验证
- AND 该验证时间必须晚于最新相关变更

### Requirement: SSF-PROGRESS-010 验证记录必须限定适用范围

系统必须要求 verification 记录说明其适用范围，并让完成声明受该范围约束。

#### Scenario: Agent 只运行文档检查
- GIVEN agent 只运行针对文档的检查
- WHEN agent 记录验证结果
- THEN `verification.md` 说明验证范围仅覆盖文档或指定文件
- AND agent 不得据此声明代码行为、测试套件或发布状态已经验证

### Requirement: SSF-PROGRESS-011 明确运行时实例提交边界

系统必须明确 SuperSpecFlow 本仓库只提交进度协议规格，不提交 `.superspecflow/progress/` 运行时实例。

#### Scenario: 用户准备提交 SuperSpecFlow 仓库改动
- GIVEN 用户在 SuperSpecFlow 本仓库中工作
- WHEN 用户准备提交 `progress-tracking` change
- THEN Git 改动只包含 `openspec/changes/progress-tracking/` 下的规格文件
- AND 不包含 `.superspecflow/progress/` 运行时实例

#### Scenario: 宿主项目采用 progress 协议
- GIVEN 宿主项目使用 `.superspecflow/progress/` 记录执行状态
- WHEN 宿主项目决定是否提交这些文件
- THEN 是否提交由宿主项目策略决定
- AND SuperSpecFlow 协议不强制宿主项目提交或忽略 `.superspecflow/progress/`

### Requirement: SSF-PROGRESS-012 提供 progress 文件模板

系统必须在 SuperSpecFlow 包源码中提供 progress 文件模板，供 agent 创建宿主项目运行时 progress 文件时引用。

#### Scenario: Agent 需要创建 progress 文件
- GIVEN agent 需要为 `<change-id>` 创建 `.superspecflow/progress/<change-id>/`
- WHEN agent 查找可复用模板
- THEN 系统提供 `templates/progress-state.json`
- AND 系统提供 `templates/progress-timeline.md`
- AND 系统提供 `templates/progress-verification.md`
- AND 系统提供 `templates/progress-handoff.md`
- AND 模板本身作为包源码提交，不作为宿主项目运行时实例提交

## MODIFIED Requirements

无。

## REMOVED Requirements

无。

## MUST NOT

- SSF-PROGRESS-N1 系统不得把 progress 文件当作 OpenSpec 需求契约的替代品。
- SSF-PROGRESS-N2 Agent 不得在恢复已有 change 时跳过 `state.json` 和 `handoff.md` 直接只读 OpenSpec。
- SSF-PROGRESS-N3 Agent 不得使用早于最新相关变更的 verification 记录声明完成。
- SSF-PROGRESS-N4 Agent 不得用窄范围验证声明宽范围完成状态。
- SSF-PROGRESS-N5 SuperSpecFlow 本仓库不得提交 `.superspecflow/progress/` 运行时实例。
- SSF-PROGRESS-N6 第一版不得实现自动调度、UI 或跨 agent 签核。
- SSF-PROGRESS-N7 第一版不得实现自动调度器、UI 或跨 agent 签核机制。
