# Tasks: validator-developer-tooling

- [x] T1: Add focused test runner tests
  - Spec: SSF-TOOLING-002
  - Files: `tests/smoke/test_recursive_test_runner.bats`
  - Test: `rtk bats tests/smoke/test_recursive_test_runner.bats`
  - Acceptance: tests cover `--list`, file args, filter, no matches, and bad files.

- [x] T2: Implement `scripts/test.sh` selection
  - Spec: SSF-TOOLING-002
  - Files: `scripts/test.sh`
  - Test: `rtk bats tests/smoke/test_recursive_test_runner.bats`
  - Acceptance: full default behavior remains; selected tests run deterministically.

- [x] T3: Add new-change scaffold tests
  - Spec: SSF-TOOLING-003
  - Files: `tests/openspec/test_new_change_scaffold.bats`
  - Test: `rtk bats tests/openspec/test_new_change_scaffold.bats`
  - Acceptance: scaffold shape, invalid ID, and no overwrite covered.

- [x] T4: Implement `scripts/new-change.sh`
  - Spec: SSF-TOOLING-003
  - Files: `scripts/new-change.sh`
  - Test: `rtk bats tests/openspec/test_new_change_scaffold.bats`
  - Acceptance: creates proposal/design/tasks/spec/map skeletons and no runtime artifacts.

- [x] T5: Refactor key validate-pack diagnostics
  - Spec: SSF-TOOLING-001
  - Files: `scripts/validate-pack.sh`, focused tests
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: long chains report granular missing predicates and preserve aggregate failures.
