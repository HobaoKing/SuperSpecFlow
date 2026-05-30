# Spec: test infrastructure portability

### Requirement: SSF-TEST-INFRA-001 TMPDIR-backed cleanup

The test helper MUST clean up helper-created temp homes and projects under the active normalized `TMPDIR`.

#### Scenario: custom TMPDIR
- GIVEN `TMPDIR` is `/tmp/claude-501/`
- WHEN `ssf_make_tmp_project` creates `/tmp/claude-501/ssf-proj.xxxxxx`
- THEN `ssf_cleanup_tmp` removes that directory successfully.

### Requirement: SSF-TEST-INFRA-002 Suspicious path refusal

The test helper MUST refuse cleanup targets outside the helper namespace.

#### Scenario: suspicious target
- GIVEN a path is empty, `/`, `$REPO_ROOT`, outside `TMPDIR`, or lacks `ssf-home.` / `ssf-proj.` prefix
- WHEN `ssf_cleanup_tmp` receives it
- THEN cleanup fails without deleting it.

### Requirement: SSF-TEST-INFRA-003 Root mutation isolation

Tests that validate rejection of root runtime artifacts MUST mutate an isolated temporary repo copy instead of the real source repo.

#### Scenario: artifact path negative tests
- GIVEN the Bats suite runs in the SuperSpecFlow repo
- WHEN tests create fake root runtime artifacts
- THEN those artifacts are created only inside a temp repo fixture.

### Requirement: SSF-TEST-INFRA-004 Non-default TMPDIR CI

CI MUST run validation and tests with a non-default `TMPDIR`.

#### Scenario: CI portability regression
- GIVEN GitHub Actions runs validation
- WHEN the test suite executes
- THEN one step sets `TMPDIR` to a custom directory and runs pack validation plus Bats tests.
