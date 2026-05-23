# SuperSpecFlow Thin Entry for CLAUDE.md

本片段是宿主项目 `CLAUDE.md` 中的极薄入口。推荐通过软连读取 `.superspecflow/CLAUDE.routing.md`，不要复制完整路由内容，也不要覆盖宿主项目文件。

## SuperSpecFlow

本项目接入 SuperSpecFlow。宿主项目的业务规则、架构事实和本地约束优先。

- 请读取 `.superspecflow/CLAUDE.routing.md`。
- 所有自然语言请求先进入 SuperSpecFlow Intake Gate。
- 非平凡行为变更必须走 change-id / Spec ID / QA / Git 中文提交门禁。
- 纯问答和轻量任务不得被强行升级为完整 Think → Retro 流程。
