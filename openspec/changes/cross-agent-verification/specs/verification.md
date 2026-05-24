# Spec: verification

## ADDED Requirements

### Requirement: SSF-XAV-001 定义 cross-agent verification handoff 目录

系统必须为每个需要独立核验的 change 使用 `.superspecflow/verification/<change-id>/` 作为 cross-agent review handoff 目录。

#### Scenario: 主 agent 准备交接核验
- GIVEN 主 agent 需要请求另一个 agent 核验 `<change-id>`
- WHEN 主 agent 准备 cross-agent review handoff
- THEN 系统使用 `.superspecflow/verification/<change-id>/` 作为唯一 handoff 目录
- AND 系统定义固定文件名 `request.md`、`evidence.md`、`reviewer-notes.md` 和 `signoff.md`
- AND 主 agent 只负责写入 `request.md` 和 `evidence.md`
- AND review agent 只在完成对应核验步骤后写入 `reviewer-notes.md` 和 `signoff.md`

### Requirement: SSF-XAV-002 主 agent 写入核验请求

系统必须要求主 agent 在 `request.md` 中写明核验范围、相关 OpenSpec 文件、目标 Spec ID、diff 来源、progress 引用和 evidence 引用。

#### Scenario: review agent 打开核验请求
- GIVEN 主 agent 已创建 `.superspecflow/verification/<change-id>/request.md`
- WHEN review agent 读取该文件
- THEN review agent 能确认核验的 change-id、阶段、范围和目标 Spec ID
- AND review agent 能找到相关 OpenSpec、diff、progress 和 evidence 来源

### Requirement: SSF-XAV-003 主 agent 写入可复查 evidence

系统必须要求主 agent 在 `evidence.md` 中写入可复查的验证证据。

#### Scenario: 主 agent 记录验证结果
- GIVEN 主 agent 已执行测试、检查或人工验证
- WHEN 主 agent 写入 `.superspecflow/verification/<change-id>/evidence.md`
- THEN evidence 列出验证命令、结果摘要、相关文件或产物引用
- AND evidence 标明关联的 Spec ID 或任务 ID
- AND evidence 记录未运行、跳过或失败的验证及原因

### Requirement: SSF-XAV-004 review agent 只基于落盘事实核验

系统必须要求 review agent 只基于 OpenSpec、diff、`.superspecflow/progress/<change-id>/` 和 `.superspecflow/verification/<change-id>/evidence.md` 中的事实做核验。

#### Scenario: review agent 收到额外聊天说明
- GIVEN 聊天上下文包含未写入 OpenSpec、diff、progress 或 evidence 的声明
- WHEN review agent 进行 cross-agent verification
- THEN review agent 不得把该声明作为核验依据
- AND review agent 必须只引用 OpenSpec、diff、progress 或 evidence 中可复查的事实

### Requirement: SSF-XAV-005 review agent 写入 reviewer notes

系统必须允许 review agent 在 `reviewer-notes.md` 中记录核验过程、发现、疑点、缺口和建议后续动作。

#### Scenario: review agent 发现 evidence 缺口
- GIVEN review agent 无法确认某个 Spec ID 的验证证据
- WHEN review agent 记录核验过程
- THEN review agent 在 `reviewer-notes.md` 中列出缺口
- AND review agent 标明缺口对应的 Spec ID 或事实来源

### Requirement: SSF-XAV-006 signoff 结果使用受限枚举

系统必须将 `signoff.md` 的结果限制为 `approve`、`changes-requested` 或 `blocked`。

#### Scenario: review agent 写入 signoff
- GIVEN review agent 已完成核验并具备可复查 evidence
- WHEN review agent 写入 `.superspecflow/verification/<change-id>/signoff.md`
- THEN `result` 只能是 `approve`、`changes-requested` 或 `blocked`

### Requirement: SSF-XAV-007 signoff 列出核验依据和残余风险

系统必须要求 `signoff.md` 列出已检查的 Spec ID、验证命令或证据引用、发现和残余风险。

#### Scenario: 主控流程读取 signoff
- GIVEN `.superspecflow/verification/<change-id>/signoff.md` 存在
- WHEN 主控流程评估 cross-agent verification 结果
- THEN signoff 明确列出已检查的 Spec ID
- AND signoff 明确列出使用过的验证命令、evidence 条目或文件引用
- AND signoff 明确列出残余风险

### Requirement: SSF-XAV-008 读取 progress-tracking 事实底座

系统必须把 `.superspecflow/progress/<change-id>/` 作为 cross-agent verification 的只读事实输入。

#### Scenario: progress 目录存在
- GIVEN `.superspecflow/progress/<change-id>/` 存在
- WHEN review agent 进行 cross-agent verification
- THEN review agent 读取 progress 中可用的状态、任务和验证事实
- AND review agent 在 reviewer notes 或 signoff 中引用相关 progress 来源

### Requirement: SSF-XAV-009 progress 不可用时记录风险

系统必须允许 progress 不可用时继续核验 OpenSpec、diff 和 evidence，但必须记录该事实造成的残余风险。

#### Scenario: progress 目录缺失
- GIVEN `.superspecflow/progress/<change-id>/` 不存在或不可读
- WHEN review agent 进行 cross-agent verification
- THEN review agent 仍可基于 OpenSpec、diff 和 evidence 继续核验
- AND review agent 在 `reviewer-notes.md` 中记录 progress 不可用
- AND 如果写入 `signoff.md`，signoff 的残余风险必须包含 progress 不可用

### Requirement: SSF-XAV-010 cross-agent verification 保持轻量 handoff

系统必须把第一版 cross-agent verification 限定为文件化 review handoff，不引入自动 agent 通信、抽象共识协议、双签门禁或多方投票。

#### Scenario: 用户启用 cross-agent verification
- GIVEN 用户要求 Claude、Codex 或另一个 agent 独立核验同一个 change
- WHEN 系统执行第一版 cross-agent verification
- THEN 系统通过 `.superspecflow/verification/<change-id>/` 交接文件完成核验
- AND 不要求 agent 之间自动通信
- AND 不要求多个 agent 投票或形成共识证明

### Requirement: SSF-XAV-011 提供 verification handoff 文件模板

系统必须在 SuperSpecFlow 包源码中提供 cross-agent verification handoff 文件模板，供主 agent 和 review agent 创建宿主项目运行时 verification 文件时引用。

#### Scenario: Agent 需要创建 verification handoff 文件
- GIVEN agent 需要为 `<change-id>` 创建 `.superspecflow/verification/<change-id>/`
- WHEN agent 查找可复用模板
- THEN 系统提供 `templates/verification-request.md`
- AND 系统提供 `templates/verification-evidence.md`
- AND 系统提供 `templates/verification-reviewer-notes.md`
- AND 系统提供 `templates/verification-signoff.md`
- AND 模板本身作为包源码提交，不作为宿主项目运行时实例提交

## MODIFIED Requirements

无。

## REMOVED Requirements

无。

## MUST NOT

- SSF-XAV-N1 系统不得在缺少 `evidence.md` 或 evidence 没有可复查内容时生成 `signoff.md`。
- SSF-XAV-N2 review agent 不得把聊天上下文、口头说明或未落盘声明作为核验依据。
- SSF-XAV-N3 review agent 不得在 cross-agent verification 中修改主 agent 的 `request.md` 或 `evidence.md`。
- SSF-XAV-N4 系统不得在 `signoff.md` 中使用 `approve`、`changes-requested`、`blocked` 之外的结果。
- SSF-XAV-N5 cross-agent-verification 不得定义或实现 `.superspecflow/progress/<change-id>/` 的文件协议。
- SSF-XAV-N6 系统不得要求两个 agent 自动通信。
- SSF-XAV-N7 系统不得在第一版引入抽象共识协议、双签门禁或多方投票。
- SSF-XAV-N8 SuperSpecFlow 本仓库不得提交 `.superspecflow/verification/` 运行时实例。
