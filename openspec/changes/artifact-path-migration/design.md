# Technical Design: artifact-path-migration

## Architecture Summary

引入统一的 SuperSpecFlow 运行产物命名空间：`.superspecflow/`。所有新生成的本地 workflow 产物按阶段和 change-id 写入该命名空间，OpenSpec 需求契约继续保留在 `openspec/`，并作为可提交源码契约处理。

路径迁移采用兼容读取、推荐新写入的方式：读取时先查 `.superspecflow/` 新路径，再回退历史根目录路径；写入时默认写入新路径，兼容期内可以提示旧路径存在，但不再推荐新写入旧路径。

## Target Paths

- Engineering artifacts: `.superspecflow/engineering/<change-id>/`
- QA artifacts: `.superspecflow/qa/<change-id>/`
- Release artifacts: `.superspecflow/release/<change-id>/`
- Archive artifacts: `.superspecflow/archive/<change-id>/`
- Retro artifacts: `.superspecflow/retro/<change-id>/`
- Decision records: `.superspecflow/decisions/`
- Spec-to-code maps: `.superspecflow/maps/<change-id>/`
- Review artifacts: `.superspecflow/reviews/<change-id>/`
- Karpathy audits: `.superspecflow/karpathy/<change-id>/`

`progress-tracking` owns `.superspecflow/progress/<change-id>/` and `cross-agent-verification` owns `.superspecflow/verification/<change-id>/`. This migration change must not redefine those file protocols; it only needs to keep them under the same `.superspecflow/` runtime namespace.

## Data Flow

1. 用户或 agent 进入某个阶段并解析 `<change-id>`。
2. 系统计算该阶段的新产物路径。
3. 读取历史上下文时，系统先读取 `.superspecflow/<stage>/<change-id>/`。
4. 如果新路径不存在，系统回退读取旧路径，例如 `engineering/<change-id>/`、`qa/<change-id>/`、`release/<change-id>/`、`archive/<change-id>/` 或旧 `retro/` 位置。
5. 写入新产物时，系统创建并写入 `.superspecflow/` 下的目标路径。
6. 如果检测到旧路径已有相关产物，系统可以提示其处于兼容读取状态，但不得把旧路径作为推荐写入位置。

## API / Interface Changes

- 阶段说明、agent 提示词、slash command 和模板中的产物路径必须更新为 `.superspecflow/` 新路径。
- 验证脚本和提交门禁必须识别 `.superspecflow/` 为本地运行产物命名空间。
- 读取型流程必须定义新路径优先、旧路径 fallback 的路径解析顺序。
- `openspec/` 继续作为提交的 change contract，不随运行产物迁移。

## Data Model Changes

无结构化数据模型变更。变更只影响本地文件路径布局和路径解析优先级。

## Security / Permission Considerations

`.superspecflow/` 下可能包含本地审查、QA、发布、复盘和工程过程产物，默认应视为本地运行产物。Git 门禁不得把该目录作为可提交产物推荐；同时不得把 `openspec/` 误判为运行时缓存，因为它承载可审查、可提交的需求契约。

## Failure Modes

- 新旧路径同时存在：读取新路径；必要时提示旧路径仍存在但已降级为兼容来源。
- 只有旧路径存在：读取旧路径并提示用户后续新写入会进入 `.superspecflow/`。
- 写入新路径失败：阶段流程必须报告目标路径和失败原因，不应静默回退写入旧路径。
- 验证脚本误判 `openspec/`：必须作为阻断问题处理，避免破坏 change contract 工作流。
- 某个 skill 或 template 漏改路径：validation 应通过残留路径扫描暴露问题。

## Observability

后续实现应通过 validation 覆盖以下检查：

- 推荐写入路径只出现在 `.superspecflow/` 目标布局中。
- `openspec/` 不被列入运行产物忽略或阻断提交规则。
- 旧路径引用只允许出现在兼容读取、迁移说明或测试场景中。
- skills、agents、commands、templates 中的阶段产物路径保持一致。

## Migration Plan

1. 建立本 change 的路径契约和 Spec ID。
2. 更新 skills 和 agents 中的阶段产物路径说明。
3. 更新 commands 和 templates 中的默认输出路径。
4. 更新 validation / Git gate，阻止新运行产物被提交，同时保留 `openspec/` 可提交。
5. 添加兼容读取测试，覆盖新路径优先和旧路径 fallback。
6. 在发布说明中声明兼容期和旧路径降级策略。

## Rollback Plan

如果迁移实现造成路径解析或用户工作流中断，回滚后续实现提交即可恢复旧路径写入。由于本规格要求兼容读取旧路径，回滚不需要迁移用户数据；已写入 `.superspecflow/` 的产物仍可由后续修复版本读取。

## Alternatives Considered

- 一次性删除旧路径支持：拒绝，会硬断已有用户和历史项目。
- 把 `openspec/` 也移入 `.superspecflow/`：拒绝，`openspec/` 是可提交需求契约，不是本地运行产物。
- 继续允许新产物写入旧路径：拒绝，会延长路径分裂并削弱 Git / validation 门禁。
- 只通过文档约定迁移：拒绝，路径分散在 skills、agents、commands、templates 和 validation 中，必须有可验证任务闭环。
