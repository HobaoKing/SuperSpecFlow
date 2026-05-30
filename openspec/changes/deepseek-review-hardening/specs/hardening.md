# Spec: deepseek review hardening

## ADDED Requirements

### Requirement: SSF-DEEPSEEK-001 Pack validation temp files

Pack validation MUST use repository helper temp files instead of hardcoded shared `/tmp` paths.

#### Scenario: command docs differ
- GIVEN command docs consistency is checked
- WHEN a diff file is needed
- THEN the file is created through the pack temp helper and removed after use.

### Requirement: SSF-DEEPSEEK-002 Portable root instruction entry

Root instruction files MUST NOT contain user-machine absolute includes.

#### Scenario: repository is cloned elsewhere
- GIVEN an agent reads `AGENTS.md`
- WHEN the first-level includes are evaluated
- THEN only repo-relative includes are present.

### Requirement: SSF-DEEPSEEK-003 Command contract coverage

The package MUST have bats contract tests for `/ssf-branch`, `/ssf-decision`, and `/ssf-map`.

#### Scenario: command files are changed
- GIVEN command contracts are tested
- WHEN those three command files are inspected
- THEN their required skill delegation and runtime artifact paths are checked.

### Requirement: SSF-DEEPSEEK-004 Compatibility dependencies

Compatibility documentation MUST state supported shell expectations and required tools.

#### Scenario: user installs the pack
- GIVEN the user reads `docs/compatibility.md`
- WHEN they review prerequisites
- THEN they can see runtime dependencies, optional tools, and test/CI dependencies.

### Requirement: SSF-DEEPSEEK-005 Documentation naming consistency

Documentation MUST refer to OpenSpec design files as `design.md`.

#### Scenario: user reads template quick reference
- GIVEN README lists OpenSpec artifacts
- WHEN the design artifact is shown
- THEN it uses `design.md`, not `technical-design.md`.

### Requirement: SSF-DEEPSEEK-006 Research document organization

PoC and research notes MUST live under `docs/research/`.

#### Scenario: maintainer scans docs
- GIVEN research notes exist
- WHEN files are listed
- THEN PoC reports are under `docs/research/`.

### Requirement: SSF-DEEPSEEK-007 Automated quality gates

The repository MUST provide CI automation for pack validation, bats tests, and shellcheck.

#### Scenario: pull request runs CI
- GIVEN GitHub Actions executes
- WHEN the validation workflow runs
- THEN it installs required test tools and runs pack validation, bats, and shellcheck.

### Requirement: SSF-DEEPSEEK-008 Change ledger status hygiene

The change ledger MUST avoid stale active rows for implementation contracts whose tasks are already complete.

#### Scenario: maintainer reviews ledger
- GIVEN implementation tasks are complete
- WHEN the change ledger is inspected
- THEN the row is no longer left as generic active follow-up, and any missing final evidence is recorded as a gap rather than hidden.

## MUST NOT

- SSF-DEEPSEEK-N1 The system MUST NOT hardcode shared temp paths for validation diffs.
- SSF-DEEPSEEK-N2 The system MUST NOT commit user-specific absolute instruction includes.
- SSF-DEEPSEEK-N3 The system MUST NOT claim durable historical final evidence where only current validation evidence exists.
