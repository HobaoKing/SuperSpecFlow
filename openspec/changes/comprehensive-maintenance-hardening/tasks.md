# Tasks: comprehensive-maintenance-hardening

- [x] T1: 建立 child change 边界和 review consensus 记录
  - Spec: SSF-MAINT-001, SSF-MAINT-002
  - Files: `openspec/changes/*`, `engineering/*/review-consensus.md`
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: parent 和四个 child 都有 ledger row；每批修改前有 3-agent review consensus。

- [x] T2: 完成 `test-infra-portability-hardening`
  - Spec: SSF-MAINT-003
  - Files: child change files and implementation files
  - Test: `TMPDIR=/tmp/claude-501 rtk bash scripts/test.sh`
  - Acceptance: 默认和自定义 `TMPDIR` 测试通过，root-mutating 测试不污染真实仓库。

- [x] T3: 完成 `routing-docs-drift-reduction`
  - Spec: SSF-MAINT-004
  - Files: child change files and implementation files
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: routing 不依赖 raw symlink 且防漂移；README / installation / workflow-scale map 不再漂移。

- [x] T4: 完成 `validator-developer-tooling`
  - Spec: SSF-MAINT-005
  - Files: child change files and implementation files
  - Test: focused Bats plus `rtk bash scripts/validate-pack.sh`
  - Acceptance: validator diagnostics、test filter、new-change scaffold 均有测试。

- [x] T5: 完成 `template-skill-usability-polish`
  - Spec: SSF-MAINT-006
  - Files: child change files and implementation files
  - Test: focused Bats plus `rtk bash scripts/validate-pack.sh`
  - Acceptance: 模板和 skills 可用性增强，不削弱现有门禁。

- [x] T6: Parent completion audit
  - Spec: SSF-MAINT-007
  - Files: `openspec/change-ledger.md`, `engineering/comprehensive-maintenance-hardening/spec-to-code-map.md`
  - Test: `rtk bash scripts/validate-pack.sh`, `rtk bash scripts/test.sh`, shellcheck
  - Acceptance: 所有 child tasks 完成，parent evidence 可追踪。
