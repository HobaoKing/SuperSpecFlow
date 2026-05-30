# Spec: install-discoverability-onboarding

### Requirement: SSF-ONBOARD-001 全局安装脚本必须引导重启与项目初始化

`scripts/install-global.sh` 在成功同步 Claude 能力后，必须在结尾输出明确下一步：重启 Claude Code 会话，使新安装的 `/ssf-*`（含 `/ssf-init`）进入斜杠补全；随后在目标项目运行 `/ssf-init` 完成 opt-in。提示措辞限定为"为确保新命令被发现，建议重启"，不得断言 `~/.claude/commands/` 必须重启才能被监听。因为 `scripts/bootstrap.sh` 以 `exec` 调用 `install-global.sh`，该提示自动覆盖一句话安装路径。

#### Scenario: 安装成功结尾提示重启与 /ssf-init
- GIVEN 用户运行 `install-global.sh` 并成功同步 Claude commands
- WHEN 脚本执行到结尾
- THEN 输出包含重启 Claude Code 会话的指引
- AND 输出包含重启后在项目运行 `/ssf-init` 的指引

约束：

- SSF-ONBOARD-001-N1 系统不得在不提示重启的前提下，把 `/ssf-init` 呈现为安装后当前会话即可使用的命令。
- SSF-ONBOARD-001-N2 系统不得断言 `~/.claude/commands/` 目录必须重启才能被监听（措辞须为建议性、面向"确保被发现"）。

### Requirement: SSF-ONBOARD-002 项目 opt-in 脚本输出不得与安装顺序矛盾且须提示新会话

`scripts/_ssf_init_apply.sh` 的输出必须满足：(a) 不包含暗示"必须先去做全局安装"作为运行该脚本前置的鸡生蛋措辞；(b) 不声称手动 include routing 即可使 `/ssf-*` 显式命令可用；(c) 说明项目 opt-in 后需新开或重启会话，自然语言 Intake Gate 才稳定启用（依据：`routing/CLAUDE.global.md` 规定本会话只探测一次 SSF 状态、后续不重复）。

#### Scenario: opt-in 输出聚焦已生效与新会话
- GIVEN 用户在项目中触发 `/ssf-init` 或直接运行 `_ssf_init_apply.sh`
- WHEN 脚本输出提示
- THEN 提示项目 opt-in 已生效
- AND 提示需新开或重启会话使自然语言 Intake Gate 生效

约束：

- SSF-ONBOARD-002-N1 系统输出不得包含"不加也不影响 `/ssf-*` 显式命令"这类把"手动 include routing"与"slash 命令注册"混同的误导表述。

### Requirement: SSF-ONBOARD-003 安装文档必须说明命令可发现性、入口层次与终端备用路径

`README.md` 快速接入段与 `docs/installation.md`（项目 opt-in 段、安装后烟测段）必须说明：安装入口是 `install-global.sh`（让命令存在）；`/ssf-init` 是装完且重启会话后的项目 opt-in 动作；安装或 opt-in 后需重启会话，`/ssf-*` 才进入补全；slash 命令暂不可见时可用终端脚本（`_ssf_init_apply.sh` 或 `update.sh --enable-natural-language <project>`）初始化。

#### Scenario: 文档含可发现性与入口层次
- GIVEN 读者查阅 README 快速接入或 installation 安装/opt-in 段
- WHEN 阅读安装与项目接入说明
- THEN 文档说明安装后需重启会话 `/ssf-*` 才进入补全
- AND 文档区分"安装入口 `install-global.sh`"与"opt-in 动作 `/ssf-init`"

#### Scenario: 烟测在调用命令前包含重启步骤
- GIVEN 读者按 `docs/installation.md` 安装后烟测执行
- WHEN 烟测引导用户输入 `/ssf-*` 命令
- THEN 烟测在输入命令前包含重启会话的步骤

约束：

- SSF-ONBOARD-003-N1 系统不得在 README 恢复被 `routing-docs-drift-reduction` 移走的大段安装说明；README 只保留快速指引与指向 `docs/installation.md` 的指针。

### Requirement: SSF-ONBOARD-004 ssf-init 命令文件不得给出顺序颠倒的安装指引

`commands/ssf-init.md` 不得把 `/ssf-init` 排在 `install-global.sh` 之前作为新用户推荐顺序；必须呈现 `install-global.sh` → 重启会话 → `/ssf-init` 的正确顺序。

#### Scenario: 命令文件呈现正确安装顺序
- GIVEN 读者查阅 `commands/ssf-init.md` 的安装相关说明
- WHEN 阅读新用户推荐路径
- THEN 推荐顺序为先 `install-global.sh`、再重启、最后 `/ssf-init`

### Requirement: SSF-ONBOARD-005 Codex-only 路径不得暗示未安装的 Claude 命令可用

`docs/installation.md` 的 Codex-only 安装段不得让用户在仅运行 `install-global.sh --codex-only` 后，即把 `/ssf-init` 当作可用的 Claude Code slash 命令；必须说明 `--codex-only` 不安装 Claude commands。此外，`scripts/install-global.sh` 在 `--codex-only`（即未安装 Claude 能力）模式下，结尾引导不得让用户运行 `/ssf-init`，而应给出终端 opt-in 路径。

#### Scenario: Codex-only 段说明命令安装范围
- GIVEN 读者查阅 `docs/installation.md` Codex-only 安装段
- WHEN 阅读 `--codex-only` 后的项目接入说明
- THEN 文档说明 `--codex-only` 不安装 Claude commands，不把 `/ssf-init` 直接当作该模式下可用的 Claude 命令

#### Scenario: --codex-only 安装结尾给出终端 opt-in 路径
- GIVEN 用户运行 `install-global.sh --codex-only`
- WHEN 脚本执行到结尾
- THEN 输出不把 `/ssf-init` 当作该模式下可用的命令
- AND 输出给出 `_ssf_init_apply.sh` 终端 opt-in 路径

约束：

- SSF-ONBOARD-005-N1 系统不得引入未实现的 Codex CLI `/ssf-init` 行为承诺；仅修正事实表述与引导路径。

### Requirement: SSF-ONBOARD-006 全局安装须提示检查同名跳过

`scripts/install-global.sh` 既有"同名已存在文件则跳过复制并打印 skipped 警告"的安全机制。脚本结尾引导必须提示用户：若出现 skipped 警告，需自行确认，以免重启后看到的并非 SuperSpecFlow 命令。

#### Scenario: 结尾引导提示留意 skipped 警告
- GIVEN 用户运行 `install-global.sh`，能力同步阶段可能因同名文件跳过复制
- WHEN 脚本执行到结尾
- THEN 输出提示用户留意是否出现 skipped 警告并自行确认
