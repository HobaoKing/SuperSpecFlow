# Spec: artifacts

## ADDED Requirements

### Requirement: SSF-ARTIFACT-001 使用统一运行产物命名空间

系统必须将 SuperSpecFlow 新生成的本地运行产物写入 `.superspecflow/` 命名空间下的阶段化路径。

#### Scenario: 用户生成新阶段产物
- GIVEN 用户在某个 `<change-id>` 的 SuperSpecFlow 阶段中生成本地运行产物
- WHEN 系统计算默认输出路径
- THEN 系统使用 `.superspecflow/` 下的阶段化路径
- AND 不把根目录旧路径作为推荐输出位置

### Requirement: SSF-ARTIFACT-002 保留 openspec 作为可提交需求契约

系统必须保留 `openspec/` 作为可提交的 OpenSpec change contract 目录，不得把它迁移到 `.superspecflow/`。

#### Scenario: 用户起草或提交 OpenSpec change
- GIVEN 用户在 `openspec/changes/<change-id>/` 下维护 proposal、design、tasks 或 specs
- WHEN 系统执行路径迁移、验证或 Git 门禁
- THEN `openspec/` 仍被视为可提交需求契约
- AND 系统不得要求将 `openspec/` 移入 `.superspecflow/`
- AND 系统不得把 `openspec/` 误判为本地运行产物

### Requirement: SSF-ARTIFACT-003 定义标准运行产物路径

系统必须为各阶段和辅助产物定义统一的 `.superspecflow/` 标准路径。

#### Scenario: 系统展示或生成标准路径
- GIVEN 用户查看阶段说明、agent 输出、command 模板或 validation 报告
- WHEN 内容涉及 SuperSpecFlow 运行产物路径
- THEN engineering 产物使用 `.superspecflow/engineering/<change-id>/`
- AND QA 产物使用 `.superspecflow/qa/<change-id>/`
- AND release 产物使用 `.superspecflow/release/<change-id>/`
- AND archive 产物使用 `.superspecflow/archive/<change-id>/`
- AND retro 产物使用 `.superspecflow/retro/<change-id>/`
- AND decision records 使用 `.superspecflow/decisions/`
- AND spec-to-code maps 使用 `.superspecflow/maps/<change-id>/`
- AND review 产物使用 `.superspecflow/reviews/<change-id>/`
- AND Karpathy audit 产物使用 `.superspecflow/karpathy/<change-id>/`
- AND progress 产物路径由 `progress-tracking` change 定义
- AND cross-agent verification 产物路径由 `cross-agent-verification` change 定义

### Requirement: SSF-ARTIFACT-004 读取新路径优先并回退旧路径

系统必须在读取运行产物时优先读取 `.superspecflow/` 新路径，并在新路径不存在时回退旧路径。

#### Scenario: 新旧路径同时存在
- GIVEN `.superspecflow/<stage>/<change-id>/` 和旧根目录阶段路径都存在
- WHEN 系统读取该阶段运行产物
- THEN 系统读取 `.superspecflow/` 新路径
- AND 不用旧路径覆盖新路径内容

#### Scenario: 只有旧路径存在
- GIVEN `.superspecflow/<stage>/<change-id>/` 不存在
- AND 旧根目录阶段路径存在
- WHEN 系统读取该阶段运行产物
- THEN 系统读取旧路径作为兼容 fallback
- AND 可以提示用户该路径处于兼容读取状态

### Requirement: SSF-ARTIFACT-005 新写入不再推荐旧路径

系统必须让新产物默认写入 `.superspecflow/`，兼容期内可以提示旧路径但不得推荐继续写入旧路径。

#### Scenario: 用户触发新产物写入
- GIVEN 用户执行会生成本地运行产物的阶段流程
- WHEN 系统创建输出目录或写入文件
- THEN 系统写入 `.superspecflow/` 标准路径
- AND 如果检测到旧路径历史产物，只把旧路径作为兼容提示
- AND 不把旧路径作为默认写入位置

### Requirement: SSF-ARTIFACT-006 验证迁移覆盖面

系统必须通过后续 validation 覆盖 skills、agents、commands、templates 和验证门禁中的路径迁移一致性。

#### Scenario: 维护者运行 pack validation
- GIVEN 维护者准备发布路径迁移实现
- WHEN validation 扫描仓库路径约定
- THEN validation 检查新写入路径是否使用 `.superspecflow/`
- AND validation 允许旧路径仅出现在兼容读取、迁移说明或测试场景中
- AND validation 检查 `openspec/` 未被运行产物规则误伤

## MODIFIED Requirements

无。

## REMOVED Requirements

无。

## MUST NOT

- SSF-ARTIFACT-N1 系统不得迁移、隐藏或禁止提交 `openspec/`。
- SSF-ARTIFACT-N2 系统不得在新旧路径同时存在时优先读取旧路径。
- SSF-ARTIFACT-N3 系统不得把旧根目录路径作为新产物的推荐写入位置。
- SSF-ARTIFACT-N4 系统不得要求用户在兼容期内一次性删除或搬迁旧路径历史产物。
- SSF-ARTIFACT-N5 系统不得在本 change 中重新定义 progress 或 cross-agent verification 的文件协议。
