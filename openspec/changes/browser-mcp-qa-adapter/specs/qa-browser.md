# Spec: qa-browser

## ADDED Requirements

### Requirement: SSF-QA-BROWSER-001 定义 QA execution plan 文件

系统必须定义 `.superspecflow/qa/<change-id>/qa-execution-plan.md`，用于记录从 acceptance matrix 派生的可执行用户路径。

#### Scenario: 生成执行计划
- GIVEN `acceptance-matrix.md` 包含 E2E 或 user journey 场景
- WHEN agent 执行 `/ssf-qa <change-id>`
- THEN agent 生成 `.superspecflow/qa/<change-id>/qa-execution-plan.md`
- AND 每个 journey 引用对应 Spec ID
- AND 每个 journey 记录目标、前置条件、操作步骤、预期结果和证据类型

### Requirement: SSF-QA-BROWSER-002 从 acceptance matrix 派生路径

系统必须从 acceptance matrix 中选择 E2E、user journey 或明确需要真实浏览器验证的场景生成 execution plan。

#### Scenario: Acceptance matrix 同时包含多种测试层级
- GIVEN `acceptance-matrix.md` 包含 Unit、Integration、E2E 和 Manual 测试项
- WHEN agent 生成 `qa-execution-plan.md`
- THEN agent 只把 E2E、user journey 或明确要求浏览器验证的场景转成 journey
- AND agent 不得删除或替代原有 acceptance matrix 条目

### Requirement: SSF-QA-BROWSER-003 记录可运行目标

系统必须要求每个 browser QA journey 记录可运行目标，包括 URL、启动命令、环境说明或 blocked 原因。

#### Scenario: 用户提供本地测试目标
- GIVEN 用户提供可访问 URL
- WHEN agent 生成 execution plan
- THEN journey 记录该 URL
- AND browser run report 使用同一目标执行

#### Scenario: 没有可运行目标
- GIVEN agent 无法识别或访问测试目标
- WHEN agent 准备执行 browser QA
- THEN agent 不执行浏览器路径
- AND `qa-signoff.md` 使用 `Blocked: No runnable target`
- AND `browser-run-report.md` 记录缺失目标和需要用户补充的信息

### Requirement: SSF-QA-BROWSER-004 检测浏览器或 MCP 工具可用性

系统必须在执行 browser QA 前确认浏览器或 MCP 工具可用，并在不可用时写入 blocked signoff。

#### Scenario: 浏览器工具可用
- GIVEN 测试目标可访问
- AND 浏览器或 MCP 工具可用
- WHEN agent 执行 journey
- THEN agent 记录使用的工具名称
- AND agent 写入执行结果和 evidence 引用

#### Scenario: 工具不可用
- GIVEN 测试目标可访问
- AND 浏览器或 MCP 工具不可用
- WHEN agent 准备执行 journey
- THEN agent 不得声明自动化浏览器路径通过
- AND `qa-signoff.md` 使用 `Blocked: Tool unavailable`
- AND agent 记录可执行的人工替代验证步骤

### Requirement: SSF-QA-BROWSER-005 定义 browser run report 文件

系统必须定义 `.superspecflow/qa/<change-id>/browser-run-report.md`，用于记录浏览器/MCP 执行目标、工具、步骤结果、失败点和 evidence 引用。

#### Scenario: Browser QA 执行完成
- GIVEN agent 执行了一个或多个 browser QA journeys
- WHEN 执行结束
- THEN agent 写入 `.superspecflow/qa/<change-id>/browser-run-report.md`
- AND 报告记录 timestamp、agent、target、tool、Spec ID、step result、failure point 和 evidence references

### Requirement: SSF-QA-BROWSER-006 定义 QA evidence 目录

系统必须定义 `.superspecflow/qa/<change-id>/qa-evidence/` 作为浏览器/MCP QA 的证据目录。

#### Scenario: 捕获截图或日志摘要
- GIVEN browser QA 产生截图、trace、console 摘要或 network 摘要
- WHEN agent 保存证据
- THEN agent 将证据写入 `.superspecflow/qa/<change-id>/qa-evidence/`
- AND `browser-run-report.md` 引用证据路径

### Requirement: SSF-QA-BROWSER-007 扩展 QA signoff 状态

系统必须让 `qa-signoff.md` 对 browser QA 使用受控状态：`Automated Browser Passed`、`Manual Verified`、`Blocked: No runnable target`、`Blocked: Tool unavailable` 和 `Failed`。

#### Scenario: 自动化路径通过
- GIVEN 所有 browser QA journeys 已执行
- AND 结果符合预期
- WHEN agent 写入 QA signoff
- THEN browser QA 状态为 `Automated Browser Passed`
- AND signoff 引用 `browser-run-report.md` 与 `qa-evidence/`

#### Scenario: 用户路径失败
- GIVEN 任一 browser QA journey 的实际结果不符合预期
- WHEN agent 写入 QA signoff
- THEN browser QA 状态为 `Failed`
- AND signoff 引用失败步骤和 evidence

### Requirement: SSF-QA-BROWSER-008 保持 QA 文档一致

系统必须保持 `qa-execution-plan.md`、`browser-run-report.md` 和 `qa-signoff.md` 的状态一致。

#### Scenario: Browser run report 记录失败
- GIVEN `browser-run-report.md` 包含 failed journey
- WHEN agent 写入 `qa-signoff.md`
- THEN signoff 不得声明 `Automated Browser Passed`
- AND signoff 必须记录 failed 或 blocked 的影响范围

### Requirement: SSF-QA-BROWSER-009 提供可复用模板

系统必须提供 QA execution plan 和 browser run report 模板，并更新 QA signoff 模板的 browser QA 状态段落。

#### Scenario: Agent 创建 QA runtime 文件
- GIVEN agent 需要创建 browser QA 相关运行时文件
- WHEN agent 查找模板
- THEN 系统提供 `templates/qa-execution-plan.md`
- AND 系统提供 `templates/browser-run-report.md`
- AND `templates/qa-signoff.md` 包含 browser QA 状态枚举

### Requirement: SSF-QA-BROWSER-010 接入 routing 和 pack validation

系统必须把 browser/MCP QA 文件协议接入 `ssf-qa`、`qa-gatekeeper`、routing 和 pack validation。

#### Scenario: Pack validation 检查 QA adapter 规则
- GIVEN browser MCP QA adapter 已实现
- WHEN 运行 `rtk bash scripts/validate-pack.sh`
- THEN validation 检查 `ssf-qa`、`qa-gatekeeper`、routing 和 templates 包含 browser QA 关键协议

## MODIFIED Requirements

无。

## REMOVED Requirements

无。

## MUST NOT

- SSF-QA-BROWSER-N1 系统不得在没有 `browser-run-report.md` 或人工验证记录时声明 browser QA 已通过。
- SSF-QA-BROWSER-N2 系统不得在没有可运行目标时声明 `Automated Browser Passed`。
- SSF-QA-BROWSER-N3 系统不得在浏览器/MCP 工具不可用时声明 `Automated Browser Passed`。
- SSF-QA-BROWSER-N4 系统不得把 `qa-execution-plan.md` 当作 acceptance matrix 的替代品。
- SSF-QA-BROWSER-N5 系统不得把 secret、token、凭据、生产客户数据或敏感日志写入 `qa-evidence/`。
- SSF-QA-BROWSER-N6 本 change 不得实现 Spec cluster、worktree 并行或 parent integration gate。
- SSF-QA-BROWSER-N7 第一版不得自动执行生产环境真实世界动作。

## MUST NOT Violation Signals

| MUST NOT | 可观察违规现象 |
|---|---|
| SSF-QA-BROWSER-N1 | `qa-signoff.md` 声明 browser QA 通过，但没有 `browser-run-report.md`、`qa-evidence/` 引用或 manual verification 记录。 |
| SSF-QA-BROWSER-N2 | `qa-signoff.md` 使用 `Automated Browser Passed`，但 `qa-execution-plan.md` 或 `browser-run-report.md` 记录 target 缺失。 |
| SSF-QA-BROWSER-N3 | `qa-signoff.md` 使用 `Automated Browser Passed`，但 `browser-run-report.md` 记录 browser/MCP 工具不可用。 |
| SSF-QA-BROWSER-N4 | `acceptance-matrix.md` 被删除、覆盖，或 execution plan 中没有原始 Spec ID 映射。 |
| SSF-QA-BROWSER-N5 | `qa-evidence/` 包含 secret、token、凭据、生产客户数据或未脱敏敏感日志。 |
| SSF-QA-BROWSER-N6 | 本 change 修改 cluster/worktree/integration gate 协议或 templates。 |
| SSF-QA-BROWSER-N7 | Browser QA 自动触发支付、发布、邮件发送、外部 webhook 或其它生产真实世界动作。 |
