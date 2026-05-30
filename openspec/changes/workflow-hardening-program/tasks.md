# Tasks: workflow-hardening-program

- [x] T1: Define parent hardening contract
  - Spec: SSF-HARDENING-001
  - Files: `openspec/changes/workflow-hardening-program/*`
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: Parent lists child changes, dependency order, and non-goals.

- [x] T2: Track child implementation changes
  - Spec: SSF-HARDENING-002
  - Files: `openspec/changes/*`
  - Test: `rtk bash scripts/test.sh`
  - Acceptance: Each child has tasks, specs, and implementation evidence.
