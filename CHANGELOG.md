# Changelog

All notable SuperSpecFlow package changes are recorded here.

## [2.0.0] - 2026-09-22

破坏性变更：本版移除 OpenSpec / Superpowers 强依赖、旧命令别名、角色转接层和大部分模板，安装接入方式随之改变。升级前请确认没有依赖已移除的 `/ssf-*` 命令或模板路径。

### Removed

- 取消 OpenSpec 合同层与 Superpowers 执行纪律层强依赖：不再要求 change-id、Spec ID、规格映射、阶段签字、issue tracker、多 agent 或计划评审循环。
- 移除旧命令别名与角色转接层：`ssf-spec`、`ssf-karpathy`、`ssf-archive`、`ssf-retro`、`ssf-branch`、`ssf-commit`、`ssf-pr`、`ssf-map`、`ssf-decision` 及整个 `agents/` 目录。
- 模板从 56 个精简到 5 个：移除 `intake-gate`、`proposal`、`design`、`tasks`、`spec-to-code-map`、`acceptance-matrix`、`risk-matrix`、`qa-execution-plan`、`visual-comparison-report`、`git-hooks/commit-msg` 等旧流程产物。
- 移除 `validate-change-ledger.sh`、`validate-commit-message.sh`、`validate-qa-signoff.sh`、`install-project-symlinks.sh` 与 `new-change.sh`；commit 格式改由 routing 规则约束，不再随包分发机器校验 hook。
- 删除仓库内 `openspec/`、`engineering/`、`docs/research/` 历史记录，Git 历史仍可查阅。

### Added

- 新增 `/ssf-plan` 与 `scripts/new-plan.sh`：跨模块或跨会话工作只维护一份 `docs/plans/<topic>.md`；不覆盖已有文件，拒绝目录穿越与非法主题。
- 新增 `skills/ssf-build/references/karpathy.md`：编码前思考、简单优先、外科手术式修改、目标驱动执行；来源固定修订并在 NOTICE 记录。
- 新增可运行示例 `examples/add-membership-renewal-reminder`，含单文件计划与公开行为测试。
- 新增 `docs/branching-strategy.md`。

### Changed

- 默认流程改为明确任务直接执行，在会话内说明目标、边界和验收点；会话授权在同范围内持续有效。
- 入口规模：`commands/` 16 → 8，`skills/` 10 → 7，模板 56 → 5，测试 34 → 14。
- 体量：`routing/default.routing.md` 522 → 47 行，README 434 → 66 行，`scripts/validate-pack.sh` 1381 → 104 行。
- 按需适配 mattpocock/skills 的 TDD、缺陷定位和代码审查方法，固定修订 `c55ee46` 并按包分发上游 MIT 授权。
- commit / PR 标题改为 `<英文类型>(<英文范围>): <中文摘要>`，不再强制编号字段。
- 函数级注释要求收窄为"本次新增或行为、契约发生变化的函数"，仅格式调整不补注释。
- `check_commands` 同时校验反引号能力名与斜杠命令文件；`test.sh` 缺少 bats 时给出安装提示；`docs/compatibility.md` 补充 `python3` 依赖与 Superpowers 共存说明。

### Fixed

- 修复 `check_commands` 只覆盖 `/ssf-init` 的门禁退化，并为全部 8 个命令补充诊断测试。
- 删除孤儿模板、与模板字段不匹配的 QA signoff 校验器，以及失效的安装金丝雀。

## [1.2.2] - 2026-05-31

### Added

- Added install discoverability onboarding guidance: global install now tells users to restart Claude Code, run `/ssf-init` after commands are discoverable, and use terminal opt-in paths when slash commands are unavailable.
- Added onboarding contract tests for install output, `_ssf_init_apply.sh` output, README, installation docs, and `commands/ssf-init.md`.

### Changed

- Clarified Codex-only install guidance so it no longer implies Claude `/ssf-init` is available when Claude commands were not installed.
- Completed the comprehensive maintenance hardening batch: canonical routing source, README/install docs drift reduction, template usability guidance, test filtering, new-change scaffolding, validator diagnostics, and workflow evidence cleanup.

### Fixed

- Fixed test infrastructure portability under non-default `TMPDIR` and isolated artifact-path tests from the real repository root.
- Fixed the `scripts/test.sh` ShellCheck SC2295 warning in ROOT_DIR prefix removal and added a regression guard.

## [1.2.1] - 2026-05-30

### Changed

- Clarified the layer boundary: OpenSpec 合同层, Superpowers 执行纪律层, and SuperSpecFlow 路由与适配层.
- Replaced proprietary role-gate framing in runtime guidance with routing and stage-check language.
- Added routing input/output and Superpowers discipline traceability requirements.

### Fixed

- Fixed DeepSeek review hardening gaps: isolated `validate-pack` command diff temp files, removed user-specific root includes, added command contract tests, documented dependencies, moved PoC notes under `docs/research/`, added GitHub Actions validation with shellcheck, and refreshed change ledger status hygiene.
- Fixed CI commit-message validation under Linux locale by replacing locale-dependent CJK grep ranges with an `LC_ALL=C` non-ASCII text check.
- Prevented pack validation from requiring the superseded `SuperSpecFlow 角色门禁` wording.
- Preserved gstack source attribution while keeping runtime guidance free of gstack execution-style recommendations.

## [1.2.0] - 2026-05-30

### Added

- Added Visual UI QA protocol for Web and mini-program screenshot comparison, baseline lifecycle, visual comparison reports, and evidence paths.
- Added `visual-execution-plan.md` and `visual-comparison-report.md` templates.
- Added Visual UI QA contract tests and pack validation.

### Changed

- Updated `/ssf-qa`, `qa-gatekeeper`, routing, and README to describe visual QA states and protocol-only boundaries.
- Documented installation prerequisites, platform differences, documentation map, runtime path guidance, and license notes.

## [1.1.0] - 2026-05-30

### Added

- Added package version tracking with `VERSION` and `update.sh --version`.
- Added Browser/MCP QA execution plan, browser run report, evidence, and blocked signoff contracts.
- Added Spec cluster planning, status, integration gate templates, and parent ship gate rules.
- Added recursive bats test runner via `scripts/test.sh`.

### Changed

- Hardened global install and uninstall with generated wrappers, install manifests, and checksum ownership checks.
- Updated Git gates to reject local runtime artifacts including `docs/superpowers/`.

### Removed

- Removed tracked `docs/superpowers/` runtime documents from the package repository.
