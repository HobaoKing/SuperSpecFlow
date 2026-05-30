# Changelog

All notable SuperSpecFlow package changes are recorded here.

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
