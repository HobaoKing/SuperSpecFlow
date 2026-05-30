# Tasks: test-infra-portability-hardening

- [x] T1: Add failing helper portability tests
  - Spec: SSF-TEST-INFRA-001, SSF-TEST-INFRA-002
  - Files: `tests/smoke/test_scaffold.bats`
  - Test: `TMPDIR=/tmp/claude-501 rtk bats tests/smoke/test_scaffold.bats`
  - Acceptance: Current cleanup rejects custom `TMPDIR` helper paths before implementation.

- [x] T2: Fix `ssf_cleanup_tmp`
  - Spec: SSF-TEST-INFRA-001, SSF-TEST-INFRA-002
  - Files: `tests/lib/test_helper.bash`
  - Test: `TMPDIR=/tmp/claude-501 rtk bats tests/smoke/test_scaffold.bats`
  - Acceptance: helper-created dirs under custom temp roots clean up; suspicious paths still fail.

- [x] T3: Isolate root-mutating artifact path tests
  - Spec: SSF-TEST-INFRA-003
  - Files: `tests/artifacts/test_artifact_path_contract.bats`, `tests/lib/test_helper.bash`
  - Test: `rtk bats tests/artifacts/test_artifact_path_contract.bats`
  - Acceptance: tests mutate only temp repo copies.

- [x] T4: Isolate cross-agent verification invalid signoff test
  - Spec: SSF-TEST-INFRA-003
  - Files: `tests/verification/test_cross_agent_verification_contract.bats`
  - Test: `rtk bats tests/verification/test_cross_agent_verification_contract.bats`
  - Acceptance: invalid signoff fixture lives in temp repo copy.

- [x] T5: Add non-default TMPDIR CI coverage
  - Spec: SSF-TEST-INFRA-004
  - Files: `.github/workflows/validate.yml`
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: CI runs pack validation and test suite under non-default `TMPDIR`.
