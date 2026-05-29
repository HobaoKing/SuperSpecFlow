# Spec: visual-ui

## ADDED Requirements

### Requirement: SSF-QA-VISUAL-001 定义视觉 QA 执行计划

系统必须定义 `.superspecflow/qa/<change-id>/visual-execution-plan.md`，用于记录从 acceptance matrix 派生的 UI 视觉验收、截图对比和 UI 1:1 还原场景。

#### Scenario: 从验收矩阵生成视觉计划
- GIVEN `acceptance-matrix.md` 包含 UI 还原、截图对比、视觉回归或设计对齐场景
- WHEN agent 执行 `/ssf-qa <change-id>`
- THEN agent 生成 `.superspecflow/qa/<change-id>/visual-execution-plan.md`
- AND 每个视觉场景引用对应 Spec ID
- AND 每个视觉场景记录 platform、route/page、viewport/device、baseline policy、actual screenshot source、comparison mode、expected result 和 evidence path
- AND 若场景需要设计稿或参考图，记录 optional reference image/design source

#### Scenario: 不替代原始验收矩阵
- GIVEN agent 生成 `visual-execution-plan.md`
- WHEN acceptance matrix 已存在
- THEN agent 不得删除或覆盖 acceptance matrix
- AND visual execution plan 必须保留回原始 acceptance 条目的 Spec ID 映射

### Requirement: SSF-QA-VISUAL-002 支持 Web 和小程序平台声明

系统必须支持 `platform: web | mini-program` 的视觉 QA 场景声明，并允许不同平台使用同一套视觉证据协议。

#### Scenario: Web 视觉场景
- GIVEN 视觉场景的 platform 为 `web`
- WHEN agent 写入 visual execution plan
- THEN agent 记录 URL 或 route、viewport、DPR、browser 或 screenshot source、theme、locale 和 environment

#### Scenario: 小程序视觉场景
- GIVEN 视觉场景的 platform 为 `mini-program`
- WHEN agent 写入 visual execution plan
- THEN agent 记录 page path、device profile、DPR、runner 或 screenshot source、theme、locale 和 environment
- AND agent 不要求必须存在微信开发者工具、具体小程序 CLI 或模拟器

### Requirement: SSF-QA-VISUAL-003 记录截图可比性字段

系统必须要求 baseline、actual 和 diff/comparison 记录足够的可比性字段，以便 Review、Ship 和 Git gate 复查视觉结论。

#### Scenario: 记录可复现截图上下文
- GIVEN agent 写入 visual execution plan 或 visual comparison report
- WHEN 场景包含截图证据
- THEN agent 记录 platform、route/page、viewport/device、DPR、theme、locale、environment、data preconditions、screenshot source、timestamp 和 evidence path
- AND 若存在参考图或设计来源，记录 reference image/design source

#### Scenario: 截图上下文不足
- GIVEN baseline 或 actual 截图缺少关键可比性字段
- WHEN agent 写入 visual comparison report
- THEN agent 标记 residual risk
- AND QA signoff 不得只凭聊天描述声明视觉自动通过

### Requirement: SSF-QA-VISUAL-004 定义视觉证据协议

系统必须定义 baseline、actual、diff 和 comparison report 的视觉证据协议，并将视觉证据写入或引用 `.superspecflow/qa/<change-id>/qa-evidence/visual/`。

#### Scenario: 自动 diff 证据齐全
- GIVEN baseline screenshot、actual screenshot 和 diff output 均存在
- WHEN agent 写入 `.superspecflow/qa/<change-id>/visual-comparison-report.md`
- THEN report 引用 baseline、actual、diff 和 comparison summary
- AND report 记录 threshold、actual difference、ignored regions、result 和 evidence path
- AND report 可以引用 optional reference image/design source，但不得要求接入具体设计工具 API

#### Scenario: 只做人工视觉验收
- GIVEN baseline 和 actual 截图存在
- AND 没有自动 diff output
- WHEN agent 写入 visual comparison report
- THEN report 记录 manual reviewer、comparison notes、accepted differences、residual risk 和 evidence path
- AND QA signoff 使用 `Manual Visual Verified`，不得使用 `Visual Passed`
- AND manual reviewer 使用足以被宿主项目追溯的自由文本标识

### Requirement: SSF-QA-VISUAL-005 定义视觉 QA 状态枚举和通过门禁

系统必须让 QA signoff 对视觉 QA 使用受控状态：`Visual Passed`、`Manual Visual Verified`、`Visual Failed`、`Blocked: Missing baseline`、`Blocked: Missing actual screenshot` 和 `Blocked: Diff tool unavailable`。

#### Scenario: 自动视觉 diff 通过
- GIVEN visual comparison report 引用 baseline、actual 和 diff output
- AND diff result 在阈值内
- WHEN agent 写入 QA signoff
- THEN visual QA 状态为 `Visual Passed`
- AND signoff 引用 visual comparison report 和 visual evidence

#### Scenario: 自动视觉 diff 失败
- GIVEN visual comparison report 记录差异超过阈值或关键区域不匹配
- WHEN agent 写入 QA signoff
- THEN visual QA 状态为 `Visual Failed`
- AND signoff 引用失败区域、差异摘要和 evidence path

#### Scenario: 缺少基线
- GIVEN 视觉场景需要 baseline
- AND baseline screenshot 不存在或未经确认
- WHEN agent 写入 QA signoff
- THEN visual QA 状态为 `Blocked: Missing baseline`
- AND signoff 说明建立 baseline 所需的人工确认步骤

#### Scenario: 缺少实际截图
- GIVEN 视觉场景需要 actual screenshot
- AND actual screenshot 不存在
- WHEN agent 写入 QA signoff
- THEN visual QA 状态为 `Blocked: Missing actual screenshot`
- AND signoff 说明需要补充的截图来源

#### Scenario: 需要自动 diff 但工具不可用
- GIVEN visual execution plan 声明 comparison mode 为 automated diff
- AND diff 工具或外部 diff 输出不可用
- WHEN agent 写入 QA signoff
- THEN visual QA 状态为 `Blocked: Diff tool unavailable`
- AND signoff 不得声明 `Visual Passed`

### Requirement: SSF-QA-VISUAL-006 定义 baseline 生命周期

系统必须定义 baseline 的建立、确认和更新规则，防止把未确认 actual 截图直接固化为视觉基线。

#### Scenario: 首次建立 baseline
- GIVEN 视觉场景没有既有 baseline
- WHEN agent 准备建立 baseline
- THEN agent 记录 baseline candidate path、source、reviewer 或 approval gate、timestamp 和关联 Spec ID
- AND baseline 未确认前 QA signoff 不得使用 `Visual Passed`

#### Scenario: 更新 baseline
- GIVEN 视觉差异是预期 UI 变更
- WHEN agent 记录 baseline update
- THEN agent 说明更新原因、关联 change-id、reviewer 或 approval gate、旧 baseline、候选 baseline 和残余风险
- AND agent 不得把 actual screenshot 自动提升为 baseline

### Requirement: SSF-QA-VISUAL-007 区分自动 diff 与人工视觉验收

系统必须区分自动视觉 diff 和人工视觉验收，且两者的 QA signoff 状态和证据要求不同。

#### Scenario: 人工验收允许继续
- GIVEN visual execution plan 允许 manual comparison
- AND baseline 与 actual 截图存在
- AND reviewer 明确记录视觉差异判断
- WHEN agent 写入 QA signoff
- THEN visual QA 状态可以为 `Manual Visual Verified`
- AND signoff 记录 reviewer、判断依据、未自动化风险和 evidence path

#### Scenario: 自动 diff 不可用不等于人工失败
- GIVEN visual execution plan 同时允许 automated diff 和 manual comparison
- AND diff 工具不可用
- AND 人工验收记录完整
- WHEN agent 写入 QA signoff
- THEN signoff 可以使用 `Manual Visual Verified`
- AND signoff 记录自动 diff 缺失作为 residual risk

### Requirement: SSF-QA-VISUAL-008 保持视觉 QA 与现有 QA 产物一致

系统必须保持 visual execution plan、visual comparison report、QA evidence 和 QA signoff 的状态一致，并与 acceptance matrix、browser run report 保持可追踪关系。

#### Scenario: Visual report 失败
- GIVEN `visual-comparison-report.md` 记录 `Visual Failed`
- WHEN agent 写入 `qa-signoff.md`
- THEN signoff 不得声明视觉 QA 通过
- AND signoff 记录失败影响范围和 release blocker 判断

#### Scenario: Browser QA 与 Visual QA 并存
- GIVEN 同一 change 同时包含 browser QA 和 visual QA
- WHEN agent 写入 QA signoff
- THEN signoff 分别记录 browser QA 状态和 visual QA 状态
- AND visual QA 不得替代 browser user journey 验证

### Requirement: SSF-QA-VISUAL-009 提供可复用视觉 QA 模板

系统必须提供 visual execution plan 和 visual comparison report 模板，并更新 QA signoff 模板的视觉 QA 状态段落。

#### Scenario: Agent 创建视觉 QA runtime 文件
- GIVEN agent 需要创建视觉 QA 相关运行时文件
- WHEN agent 查找模板
- THEN 系统提供 `templates/visual-execution-plan.md`
- AND 系统提供 `templates/visual-comparison-report.md`
- AND `templates/qa-signoff.md` 包含视觉 QA 状态枚举

### Requirement: SSF-QA-VISUAL-010 接入 routing 和 pack validation

系统必须把视觉 QA 文件协议接入 `ssf-qa`、`qa-gatekeeper`、routing 和 pack validation。

#### Scenario: Pack validation 检查视觉 QA 规则
- GIVEN visual UI QA adapter 已实现
- WHEN 运行 `rtk bash scripts/validate-pack.sh`
- THEN validation 检查 `ssf-qa`、`qa-gatekeeper`、routing 和 templates 包含视觉 QA 关键协议

## MODIFIED Requirements

无。

## REMOVED Requirements

无。

## MUST NOT

- SSF-QA-VISUAL-N1 系统不得在缺少 baseline 或 baseline 未确认时声明 `Visual Passed`。
- SSF-QA-VISUAL-N2 系统不得在缺少 actual screenshot 时声明视觉通过。
- SSF-QA-VISUAL-N3 系统不得把 `visual-execution-plan.md` 当作 acceptance matrix 的替代品。
- SSF-QA-VISUAL-N4 系统不得用聊天描述替代落盘 visual comparison report 或 evidence。
- SSF-QA-VISUAL-N5 系统不得在外部 diff 工具或 diff output 不可用时伪装成自动视觉通过。
- SSF-QA-VISUAL-N6 系统不得把 actual screenshot 自动提升为 baseline。
- SSF-QA-VISUAL-N7 系统不得把 secret、token、凭据、生产客户数据、未脱敏个人信息或敏感日志写入视觉 evidence。
- SSF-QA-VISUAL-N8 第一版不得绑定微信开发者工具、小程序 CLI、具体模拟器或具体图片 diff 算法。

## MUST NOT Violation Signals

| MUST NOT | 可观察违规现象 |
|---|---|
| SSF-QA-VISUAL-N1 | `qa-signoff.md` 使用 `Visual Passed`，但 visual report 没有 baseline path 或 baseline approval。 |
| SSF-QA-VISUAL-N2 | `qa-signoff.md` 使用视觉通过状态，但 actual screenshot 缺失。 |
| SSF-QA-VISUAL-N3 | acceptance matrix 被删除、覆盖，或 visual execution plan 缺少 Spec ID 映射。 |
| SSF-QA-VISUAL-N4 | QA signoff 声明视觉通过，但没有 `visual-comparison-report.md` 或 `qa-evidence/visual/` 引用。 |
| SSF-QA-VISUAL-N5 | comparison mode 为 automated diff，但没有 diff output 仍声明 `Visual Passed`。 |
| SSF-QA-VISUAL-N6 | baseline update 只引用 actual screenshot，没有 reviewer / approval gate / update reason。 |
| SSF-QA-VISUAL-N7 | `qa-evidence/visual/` 包含 secret、token、凭据、生产客户数据、未脱敏个人信息或敏感日志。 |
| SSF-QA-VISUAL-N8 | 本 change 要求安装或调用特定小程序 runner、特定微信工具或特定图片 diff 算法。 |
