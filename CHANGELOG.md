# Changelog

All notable SuperSpecFlow package changes are recorded here.

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
