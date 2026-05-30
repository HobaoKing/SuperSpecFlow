# Tasks: routing-docs-drift-reduction

- [x] T1: Add routing sync/drift tests
  - Spec: SSF-DRIFT-001
  - Files: `tests/routing/test_root_entry_thin_contract.bats`, `scripts/validate-pack.sh`
  - Test: `rtk bats tests/routing/test_root_entry_thin_contract.bats`
  - Acceptance: validation proves public routing files cannot silently drift and are not raw symlink-dependent.

- [x] T2: Implement routing canonicalization guard
  - Spec: SSF-DRIFT-001
  - Files: `routing/`, `scripts/`
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: one canonical source or equivalent check guards both public files.

- [x] T3: Trim README install/uninstall details
  - Spec: SSF-DRIFT-002
  - Files: `README.md`
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: README keeps quick install, `/ssf-init`, uninstall pointer, and links to docs.

- [x] T4: Move legacy symlink docs to appendix
  - Spec: SSF-DRIFT-003
  - Files: `docs/installation.md`
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: main install path leads with zero-touch; legacy symlink path is appendix/compatibility.

- [x] T5: Refresh workflow-scale evidence wording
  - Spec: SSF-DRIFT-004
  - Files: `engineering/workflow-scale-architecture/spec-to-code-map.md`
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: stale child draft/future wording is gone.
