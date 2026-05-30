# Proposal: install-discoverability-onboarding

## Summary

消除 SuperSpecFlow 安装后 `/ssf-init` 等 slash 命令"打不出来"的 onboarding 断点：在安装脚本、项目 opt-in 脚本和安装文档里讲清三件事——命令安装入口是 `install-global.sh`、安装或 opt-in 后需重启 Claude Code 会话、命令暂不可见时可用终端脚本初始化——并修正若干顺序颠倒与误导措辞。本 change 不改变任何命令语义，只补提示与文档。

## Problem

`/ssf-init` 被文档反复强调为项目接入入口，但用户安装后常常在 Claude Code 斜杠补全里打不出它。根因有三层，且伴随多处措辞缺陷：

- **入口认知颠倒**：`/ssf-init` 是 Claude Code slash 命令，只有当 `scripts/install-global.sh` 把 `commands/ssf-*.md` 复制进 `~/.claude/commands/` 后才存在。真正的安装入口是 `install-global.sh` / `bootstrap.sh`（后者 `exec` 前者），不是 `/ssf-init` 本身。
- **缺少重启提示**：Claude Code 在会话启动时扫描命令目录。脚本首次创建 `~/.claude/commands/` 后，当前会话扫不到新命令，需重启会话才能在补全里看到 `/ssf-*`。主推入口 `install-global.sh` / `bootstrap.sh` 结尾没有任何重启提示（只有 `update.sh` 结尾有）。
- **第二个、独立的重启理由**：项目 opt-in 后，`routing/CLAUDE.global.md` 规定本会话只探测一次 SSF 状态、后续不重复，因此 opt-in 后也需新会话，自然语言 Intake Gate 才稳定启用。这与"命令可见性"是两件不同的事。
- **误导措辞**：`_ssf_init_apply.sh` 输出含与安装顺序矛盾的鸡生蛋表述，以及"不加也不影响 `/ssf-*` 显式命令"——后者在"不做全局安装"语境下错误，因为未全局安装时 slash 命令根本未注册。`commands/ssf-init.md` 末尾把 `/ssf-init` 排在 `install-global.sh` 之前作为推荐顺序。`docs/installation.md` 的 Codex-only 段让用户在仅 `--codex-only` 后使用 `/ssf-init`，但该模式不安装 Claude commands。`install-global.sh` 遇同名文件会静默跳过复制，用户重启后看到的可能并非 SuperSpecFlow 命令。
- **终端备用路径被埋没**：等价的、不依赖 slash 命令的终端初始化路径（`_ssf_init_apply.sh`、`update.sh --enable-natural-language <project>`）已存在，但 README 未将其作为"slash 命令暂不可见时的 plan B"指出。

## Goals

- 主推安装与 opt-in 路径明确告知重启与命令可发现性，措辞严谨不夸大。
- 消除所有与安装顺序相关的误导与颠倒措辞。
- 在 README 提供"slash 命令暂不可见时用终端脚本初始化"的轻量指针，详情仍集中在 `docs/installation.md`。

## Non-goals

- 不引入 plugin 化、命令命名空间或任何新机制。
- 不把 `update.sh --enable-natural-language` 提升为并列主推安装路径（仅作为备用 plan B 指针）。
- 不回退 `routing-docs-drift-reduction` 对 README 的精简，不恢复被移走的大段安装说明。
- 不实现或承诺 Codex CLI 侧 `/ssf-init` 等价命令行为，只修正文档事实表述。

## User Impact

新用户按文档安装后，能明确知道"重启会话后才能打出 `/ssf-init`"，不再卡在"命令打不出来"；命令暂不可见时有可靠的终端备用路径；不再被顺序颠倒或自相矛盾的提示误导。

## Affected Areas

- `scripts/install-global.sh`、`scripts/_ssf_init_apply.sh`
- `README.md`、`docs/installation.md`、`commands/ssf-init.md`
- `tests/install/`、`tests/init/`、`tests/docs/`

## Success Metrics

- `install-global.sh` 成功输出包含重启会话与运行 `/ssf-init` 的引导，并提示留意 skipped 警告；契约测试覆盖。
- `_ssf_init_apply.sh` 输出不含鸡生蛋前置措辞、不含"不加也不影响 `/ssf-*` 显式命令"，且含 opt-in 后需新会话的提示；契约测试覆盖。
- `README.md` 与 `docs/installation.md` 含重启、命令可发现性、入口层次与终端备用路径；docs 契约测试覆盖。
- `commands/ssf-init.md` 推荐顺序为 `install-global.sh` → 重启 → `/ssf-init`。
- `docs/installation.md` Codex-only 段不再暗示 `--codex-only` 后 `/ssf-init` 即为可用 Claude 命令。
- `scripts/validate-pack.sh` 与全量 bats 通过。

## Risks

- **文档精简边界**：补充重启信息不得恢复被 `routing-docs-drift-reduction` 移走的大段说明，README 只留快速指针。
- **重启措辞严谨性**：Claude Code 官方逐字承诺的是 skills 顶层目录重启，`commands/` 为同类机制；须写"为确保新命令被发现，建议重启"，不得断言 `~/.claude/commands/` 强制重启。
- **Codex-only 修正边界**：只修正"`--codex-only` 不装 Claude commands"这一事实，不引入未实现的 Codex slash 行为承诺。

## Rollout Strategy

standalone change，先写失败测试（install / init / docs 契约）→ 实现脚本与文档改动 → 局部 bats + `validate-pack.sh` + 全量 `test.sh` 转绿 → 更新 ledger evidence 与 spec-to-code map。轻量 review：已含一次 Codex 独立只读评审作为 cross-agent verification 输入。

## Open Questions

- 无。归属（standalone）、范围（核心修复 + Codex-only 段与 skipped 提示两个边界）已与维护者及 Codex 评审收敛。
