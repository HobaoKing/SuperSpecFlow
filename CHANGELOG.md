# Changelog

All notable SuperSpecFlow package changes are recorded here.

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
