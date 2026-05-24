# Tasks: cross-agent-verification

- [x] T1: 提供 verification handoff 文件模板
  - Spec: SSF-XAV-001, SSF-XAV-002, SSF-XAV-003, SSF-XAV-005, SSF-XAV-006, SSF-XAV-007, SSF-XAV-011
  - Files: `templates/verification-request.md`, `templates/verification-evidence.md`, `templates/verification-reviewer-notes.md`, `templates/verification-signoff.md`
  - Test: `rtk bats tests/verification/test_cross_agent_verification_contract.bats`
  - Acceptance: 模板定义 `request.md`、`evidence.md`、`reviewer-notes.md` 和 `signoff.md` 的最小段落，不创建 `.superspecflow/verification/` 运行时实例。
  - Estimate: 20 min

- [x] T2: 接入 ssf-review 独立核验规则
  - Spec: SSF-XAV-002, SSF-XAV-003, SSF-XAV-004, SSF-XAV-005, SSF-XAV-006, SSF-XAV-007, SSF-XAV-008, SSF-XAV-009, SSF-XAV-010, SSF-XAV-N1, SSF-XAV-N2, SSF-XAV-N3, SSF-XAV-N4, SSF-XAV-N5, SSF-XAV-N6, SSF-XAV-N7
  - Files: `skills/ssf-review/SKILL.md`
  - Test: `rtk bats tests/verification/test_cross_agent_verification_contract.bats`
  - Acceptance: `ssf-review` 说明主 agent 和 review agent 的文件责任、可复查 evidence 要求、signoff 枚举和只基于落盘事实核验规则。
  - Estimate: 25 min

- [x] T3: 接入 routing 级 cross-agent verification 规则
  - Spec: SSF-XAV-001, SSF-XAV-004, SSF-XAV-006, SSF-XAV-010
  - Files: `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`
  - Test: `rtk bats tests/verification/test_cross_agent_verification_contract.bats`, `rtk bash scripts/validate-pack.sh`
  - Acceptance: 两份 routing 都声明 `.superspecflow/verification/<change-id>/`、OpenSpec/diff/progress/evidence 输入、signoff 枚举和不引入重型协作协议。
  - Estimate: 15 min

- [x] T4: 增加 cross-agent verification 契约验证
  - Spec: SSF-XAV-001, SSF-XAV-006, SSF-XAV-007, SSF-XAV-010, SSF-XAV-011, SSF-XAV-N8
  - Files: `tests/verification/test_cross_agent_verification_contract.bats`, `scripts/validate-pack.sh`, `README.md`, `engineering/cross-agent-verification/spec-to-code-map.md`
  - Test: `rtk bats tests/verification/test_cross_agent_verification_contract.bats`, `rtk bash scripts/validate-pack.sh`
  - Acceptance: 自动化测试和 pack validation 能发现 verification 模板缺失、`ssf-review` 规则缺失、routing 规则缺失或 OpenSpec 未同步模板实现范围。
  - Estimate: 20 min
