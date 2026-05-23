# Spec: routing

## ADDED Requirements

### Requirement: SSF-INIT-001 使用唯一项目初始化命令

系统必须使用 `/ssf-init` 作为项目级 SuperSpecFlow 自然语言路由初始化命令。

#### Scenario: 用户查看显式命令列表
- GIVEN 用户查看 README、AGENTS、CLAUDE 或 routing 文件中的显式命令列表
- WHEN 用户查找项目初始化入口
- THEN 系统只展示 `/ssf-init`

### Requirement: SSF-INIT-002 初始化命令创建项目软链

系统必须将 `/ssf-init` 定义为创建或更新当前项目 `.superspecflow/` 软链的项目初始化动作。

#### Scenario: 用户执行项目初始化
- GIVEN 用户在目标项目中调用 `/ssf-init`
- WHEN agent 按命令说明执行初始化
- THEN agent 创建 `.superspecflow/AGENTS.routing.md`、`.superspecflow/CLAUDE.routing.md` 和 `.superspecflow/templates` 软链
- AND 不覆盖宿主项目 `AGENTS.md` 或 `CLAUDE.md`

### Requirement: SSF-INIT-003 全局安装默认不启用自然语言路由

系统必须让全局安装默认只安装 SuperSpecFlow 能力文件，不自动初始化任意项目的自然语言路由。

#### Scenario: 用户执行默认全局安装
- GIVEN 用户执行 `./update.sh`
- WHEN 脚本完成同步
- THEN 脚本只同步全局 skills、commands 和 agents
- AND 提示自然语言路由未启用

### Requirement: SSF-INIT-004 全局安装提供显式自然语言开关

系统必须提供显式选项，让用户在全局安装时初始化指定项目的自然语言路由。

#### Scenario: 用户打开全局安装自然语言开关
- GIVEN 用户执行 `./update.sh --enable-natural-language <project>`
- WHEN 脚本完成全局同步
- THEN 脚本调用项目软链安装流程初始化 `<project>`

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
