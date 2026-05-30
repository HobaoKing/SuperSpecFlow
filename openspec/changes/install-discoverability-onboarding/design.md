# Design: install-discoverability-onboarding

## Architecture Summary

纯 onboarding 一致性修复，不改任何命令语义或运行时机制。改动落在两个 shell 脚本的**输出文案**、一个命令说明文件和两个文档文件，外加三个 bats 契约测试。核心是把"安装能力 → 重启会话 → 项目 opt-in → （必要时）新会话"这条真实链路在所有用户可见出口处表述一致。

## Data Flow

用户接入链路（修复后表述）：

1. `install-global.sh`（或 `bootstrap.sh` exec 它）把 `commands/ssf-*.md`、`skills/ssf-*`、`agents/*.md` 复制进 `~/.claude/`。脚本结尾提示：重启 Claude Code 会话；留意 skipped 警告。
2. 用户重启 Claude Code，会话启动时扫描 `~/.claude/commands/`，`/ssf-*` 进入补全。
3. 用户在项目运行 `/ssf-init`（或终端等价 `_ssf_init_apply.sh` / `update.sh --enable-natural-language`）创建 `.superspecflow/enabled`。
4. opt-in 后若当前会话此前已探测为 disabled，需新会话；`routing/CLAUDE.global.md` 本会话只探测一次，故新会话才稳定启用 Intake Gate。

## API / Interface Changes

无。不新增脚本参数、不改命令名、不改文件协议。仅修改脚本 stdout 文案与文档正文。

## Data Model Changes

无。

## Security / Permission Considerations

无新增权限。继续遵守"不擅自改写宿主 `CLAUDE.md` / `AGENTS.md`、不创建 routing 软链"的既有约束；`_ssf_init_apply.sh` 行为不变，仅改输出文案。

## Failure Modes

- 文案过度承诺：断言"commands 目录必须重启"超出 Claude Code 官方逐字承诺范围。对策：措辞限定为"为确保新命令被发现，建议重启"（SSF-ONBOARD-001-N2）。
- 文档膨胀：补重启信息时误恢复被 `routing-docs-drift-reduction` 移走的大段说明。对策：README 仅加指针，详情留 docs（SSF-ONBOARD-003-N1）。
- 测试脆弱：断言脚本输出时若依赖真实 `$HOME` 会污染环境或假红。对策：测试在隔离临时目录运行，断言文案子串而非精确整段。

## Observability

契约测试即可观测信号：`install-global.sh` 与 `_ssf_init_apply.sh` 的输出子串断言、docs 文案断言。无运行时日志变更。

## Migration Plan

无数据/路径迁移。文案修复对已安装用户向后兼容；重新运行安装脚本即可看到新提示。

## Rollback Plan

改动均为文案/文档与新增测试，回滚等价于 `git revert` 本 change 的提交，不影响任何已创建的 `.superspecflow/` 或 `~/.claude/` 安装产物。

## Alternatives Considered

- **方案 B（把 `update.sh --enable-natural-language` 提升为并列主推路径）**：被否。维护者选择最小修复，终端路径仅作为备用 plan B 指针，避免双主推路径增加文档维护面。
- **plugin 化（命令走 `/plugin:ssf-init` 命名空间分发）**：被否。属于改变分发机制的大改，YAGNI，且与现有"复制到 `~/.claude/commands/`"设计冲突。
- **挂入 parent `comprehensive-maintenance-hardening` 第 5 child**：被否。该 parent 在 `change-ledger.md` 已记为 `complete`（four child completed），重开会破坏归档叙述并强制 3-agent review。改为 standalone change，经一次 Codex 独立只读评审作为 cross-agent verification 输入。
