# Tasks: install-host-portability

- [x] T1: Add portability tests
  - Spec: SSF-PORTABILITY-001, SSF-PORTABILITY-002
  - Files: `tests/install/test_host_portability_contract.bats`
  - Test: `rtk bats tests/install/test_host_portability_contract.bats`
  - Acceptance: Tests fail until pack-root metadata and prompt fallback are documented.

- [x] T2: Implement deterministic install metadata and prompt fallback
  - Spec: SSF-PORTABILITY-001, SSF-PORTABILITY-002
  - Files: `scripts/install-global.sh`, `commands/ssf-init.md`, `skills/ssf-spec/SKILL.md`, `skills/ssf-build/SKILL.md`
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: No hardcoded plugin cache path remains.
