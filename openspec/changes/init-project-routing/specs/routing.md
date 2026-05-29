# Spec: routing

## ADDED Requirements

### Requirement: SSF-INIT-001 使用唯一项目初始化命令

系统必须使用 `/ssf-init` 作为项目级 SuperSpecFlow 自然语言路由初始化命令。

#### Scenario: 用户查看显式命令列表
- GIVEN 用户查看 README、AGENTS、CLAUDE 或 routing 文件中的显式命令列表
- WHEN 用户查找项目初始化入口
- THEN 系统只展示 `/ssf-init`

### Requirement: SSF-INIT-002 初始化命令创建 zero-touch opt-in sentinel

系统必须将 `/ssf-init` 定义为创建或更新当前项目 `.superspecflow/enabled` sentinel 和标准运行产物目录的项目初始化动作。

#### Scenario: 用户执行项目初始化
- GIVEN 用户在目标项目中调用 `/ssf-init`
- WHEN agent 按命令说明执行初始化
- THEN agent 创建 `.superspecflow/enabled`
- AND agent 创建 `.superspecflow/engineering/`、`qa/`、`release/`、`archive/`、`retro/`、`decisions/`、`maps/`、`reviews/`、`karpathy/`、`progress/` 和 `verification/`
- AND 不生成 `.superspecflow/AGENTS.routing.md`、`.superspecflow/CLAUDE.routing.md` 或 `.superspecflow/templates`
- AND 不覆盖宿主项目 `AGENTS.md` 或 `CLAUDE.md`

### Requirement: SSF-INIT-003 全局安装默认不启用自然语言路由

系统必须让全局安装默认只安装 SuperSpecFlow 能力文件，不自动初始化任意项目的自然语言路由。

#### Scenario: 用户执行默认全局安装
- GIVEN 用户执行 `./update.sh`
- WHEN 脚本完成同步
- THEN 脚本委托 `scripts/install-global.sh` 同步全局能力和 global wrapper
- AND 提示自然语言路由未启用

### Requirement: SSF-INIT-004 全局安装提供显式自然语言开关

系统必须提供显式选项，让用户在全局安装时初始化指定项目的自然语言路由。

#### Scenario: 用户打开全局安装自然语言开关
- GIVEN 用户执行 `./update.sh --enable-natural-language <project>`
- WHEN 脚本完成全局同步
- THEN 脚本调用 zero-touch 初始化流程，为 `<project>` 创建 `.superspecflow/enabled`

### Requirement: SSF-INIT-006 根指令文件保持薄入口

系统必须让 SuperSpecFlow 仓库根目录的 `AGENTS.md` 和 `CLAUDE.md` 只作为薄入口，完整 Intake Gate、显式命令集合、阶段路由、Git 规范和完成门禁必须维护在 `routing/*.routing.md`。

#### Scenario: 用户查看仓库根指令文件
- GIVEN 用户打开 SuperSpecFlow 仓库根目录的 `AGENTS.md` 或 `CLAUDE.md`
- WHEN 用户确认 agent 路由来源
- THEN 文件引用对应的 `routing/*.routing.md`
- AND 文件只保留本仓库本地约束
- AND 文件不包含完整 Intake Gate 表或显式命令全集

#### Scenario: 用户查看集中路由文件
- GIVEN 用户打开 `routing/AGENTS.routing.md` 或 `routing/CLAUDE.routing.md`
- WHEN 用户确认 SuperSpecFlow 完整路由契约
- THEN 文件包含完整 Intake Gate、显式命令集合、阶段路由、Git 规范和完成门禁
- AND 根指令文件薄化不会造成路由内容丢失
- AND 两个 routing 文件内容保持一致，不因 agent 入口不同产生规则漂移

### Requirement: SSF-INIT-007 区分源码契约与运行时产物

系统必须区分 SuperSpecFlow 包源码、OpenSpec 变更契约和本地 workflow 运行时/安装产物，并在验证与提交门禁中阻止运行时产物进入 Git 跟踪列表。

#### Scenario: 用户提交 SuperSpecFlow 仓库改动
- GIVEN 用户准备提交 SuperSpecFlow 仓库改动
- WHEN 用户运行 pack validation 或执行提交前检查
- THEN `openspec/` 保持为可提交的 change contract
- AND Git 跟踪列表不得包含 `superpowers/`、`docs/superpowers/`、`.superspecflow/`、`.claude/`、`.codex/` 或 `.DS_Store`
- AND 文档明确宿主项目如果采用 OpenSpec 管理需求，应正常提交宿主项目自己的 `openspec/`

## MODIFIED Requirements

无。

## REMOVED Requirements

### Requirement: SSF-INIT-005 移除旧初始化命名

系统必须移除旧初始化命令入口。

#### Scenario: 用户搜索旧命名
- GIVEN 用户或验证脚本搜索仓库
- WHEN 搜索旧初始化命名
- THEN 仓库中没有匹配项

## MUST NOT

- SSF-INIT-N1 系统不得保留旧初始化命令作为别名。
- SSF-INIT-N2 系统不得在默认全局安装时自动创建任意项目 `.superspecflow/`。
- SSF-INIT-N3 系统不得覆盖宿主项目 `AGENTS.md` 或 `CLAUDE.md`。
- SSF-INIT-N4 系统不得把完整路由规则复制回仓库根 `AGENTS.md` 或 `CLAUDE.md`。
- SSF-INIT-N5 系统不得把本地 workflow 运行时、安装副本或缓存产物提交到 SuperSpecFlow 仓库。
- SSF-INIT-N6 系统不得把 SuperSpecFlow 仓库内的 `openspec/` 误判为运行时产物。
