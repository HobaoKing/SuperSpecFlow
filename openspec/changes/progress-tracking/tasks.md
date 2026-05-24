# Tasks: progress-tracking

- [x] T1: 提供 progress runtime 文件模板
  - Spec: SSF-PROGRESS-001, SSF-PROGRESS-002, SSF-PROGRESS-003, SSF-PROGRESS-004, SSF-PROGRESS-005, SSF-PROGRESS-012
  - Files: `templates/progress-state.json`, `templates/progress-timeline.md`, `templates/progress-verification.md`, `templates/progress-handoff.md`
  - Test: `rtk bats tests/progress/test_progress_contract.bats`
  - Acceptance: 模板定义 `state.json`、`timeline.md`、`verification.md`、`handoff.md` 的最小字段和恢复/验证段落，不创建 `.superspecflow/progress/` 运行时实例。
  - Estimate: 20 min

- [x] T2: 接入 ssf-build progress 读写规则
  - Spec: SSF-PROGRESS-006, SSF-PROGRESS-007, SSF-PROGRESS-008, SSF-PROGRESS-009, SSF-PROGRESS-010, SSF-PROGRESS-N1, SSF-PROGRESS-N2, SSF-PROGRESS-N3, SSF-PROGRESS-N4
  - Files: `skills/ssf-build/SKILL.md`
  - Test: `rtk bats tests/progress/test_progress_contract.bats`
  - Acceptance: `ssf-build` 要求恢复已有 change 时先读 progress，再读 OpenSpec；多 task 工作维护 progress；完成声明前写入或引用 fresh verification。
  - Estimate: 20 min

- [x] T3: 接入 routing 级恢复规则
  - Spec: SSF-PROGRESS-006, SSF-PROGRESS-009, SSF-PROGRESS-010
  - Files: `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`
  - Test: `rtk bats tests/progress/test_progress_contract.bats`, `rtk bash scripts/validate-pack.sh`
  - Acceptance: 两份 routing 都声明 `.superspecflow/progress/<change-id>/` 恢复顺序、模板来源和 fresh verification 规则。
  - Estimate: 15 min

- [x] T4: 增加 progress 契约验证
  - Spec: SSF-PROGRESS-011, SSF-PROGRESS-012
  - Files: `tests/progress/test_progress_contract.bats`, `scripts/validate-pack.sh`, `README.md`, `engineering/progress-tracking/spec-to-code-map.md`
  - Test: `rtk bats tests/progress/test_progress_contract.bats`, `rtk bash scripts/validate-pack.sh`
  - Acceptance: 自动化测试和 pack validation 能发现 progress 模板缺失、`ssf-build` 规则缺失或 routing 恢复规则缺失；README 包结构列出新增模板。
  - Estimate: 20 min
