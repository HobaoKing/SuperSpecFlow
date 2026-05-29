# Tasks: visual-ui-qa-adapter

- [x] T1: 提供 visual QA runtime 模板
  - Spec: SSF-QA-VISUAL-001, SSF-QA-VISUAL-003, SSF-QA-VISUAL-004, SSF-QA-VISUAL-005, SSF-QA-VISUAL-009, SSF-QA-VISUAL-N1, SSF-QA-VISUAL-N2, SSF-QA-VISUAL-N4, SSF-QA-VISUAL-N7
  - Files: `templates/visual-execution-plan.md`, `templates/visual-comparison-report.md`, `templates/qa-signoff.md`
  - Test: `rtk bash scripts/validate-pack.sh`, `rtk bats tests/qa/test_visual_ui_qa_contract.bats`
  - Acceptance: 模板包含 `.superspecflow/qa/<change-id>/visual-execution-plan.md`、`.superspecflow/qa/<change-id>/visual-comparison-report.md`、`.superspecflow/qa/<change-id>/qa-evidence/visual/`、baseline/actual/diff 字段和受控视觉 QA 状态枚举。
  - Estimate: 35 min

- [x] T2: 接入 ssf-qa 视觉 QA 规则
  - Spec: SSF-QA-VISUAL-001, SSF-QA-VISUAL-002, SSF-QA-VISUAL-003, SSF-QA-VISUAL-004, SSF-QA-VISUAL-005, SSF-QA-VISUAL-006, SSF-QA-VISUAL-007, SSF-QA-VISUAL-008, SSF-QA-VISUAL-N1, SSF-QA-VISUAL-N2, SSF-QA-VISUAL-N3, SSF-QA-VISUAL-N4, SSF-QA-VISUAL-N5, SSF-QA-VISUAL-N6
  - Files: `skills/ssf-qa/SKILL.md`, `agents/qa-gatekeeper.md`, `commands/ssf-qa.md`
  - Test: `rtk bash scripts/validate-pack.sh`, `rtk bats tests/qa/test_visual_ui_qa_contract.bats`
  - Acceptance: `ssf-qa` 要求从 acceptance matrix 生成 visual execution plan，记录 Web/小程序平台字段，检查 baseline/actual/diff 或人工验收证据，并禁止无证据视觉通过。
  - Estimate: 55 min

- [x] T3: 定义 baseline 生命周期和小程序协议边界
  - Spec: SSF-QA-VISUAL-002, SSF-QA-VISUAL-006, SSF-QA-VISUAL-007, SSF-QA-VISUAL-N6, SSF-QA-VISUAL-N8
  - Files: `skills/ssf-qa/SKILL.md`, `agents/qa-gatekeeper.md`, `templates/visual-execution-plan.md`, `templates/visual-comparison-report.md`
  - Test: `rtk bats tests/qa/test_visual_ui_qa_contract.bats`
  - Acceptance: 规则明确首次 baseline 建立、baseline 更新、人工确认、actual 不得自动提升 baseline，以及小程序第一版只定义协议、不绑定具体 runner。
  - Estimate: 35 min

- [x] T4: 接入 routing 和 README 说明
  - Spec: SSF-QA-VISUAL-002, SSF-QA-VISUAL-005, SSF-QA-VISUAL-008, SSF-QA-VISUAL-010, SSF-QA-VISUAL-N3, SSF-QA-VISUAL-N5, SSF-QA-VISUAL-N8
  - Files: `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `README.md`
  - Test: `rtk bash scripts/validate-pack.sh`, `rtk bats tests/qa/test_visual_ui_qa_contract.bats`
  - Acceptance: 路由和 README 说明 visual QA 的运行时路径、Web/小程序平台声明、自动/人工视觉验收状态、blocked 状态和协议层边界。
  - Estimate: 30 min

- [x] T5: 增加 visual UI QA 契约验证
  - Spec: SSF-QA-VISUAL-001, SSF-QA-VISUAL-002, SSF-QA-VISUAL-003, SSF-QA-VISUAL-004, SSF-QA-VISUAL-005, SSF-QA-VISUAL-006, SSF-QA-VISUAL-007, SSF-QA-VISUAL-008, SSF-QA-VISUAL-009, SSF-QA-VISUAL-010, SSF-QA-VISUAL-N1, SSF-QA-VISUAL-N2, SSF-QA-VISUAL-N3, SSF-QA-VISUAL-N4, SSF-QA-VISUAL-N5, SSF-QA-VISUAL-N6, SSF-QA-VISUAL-N7, SSF-QA-VISUAL-N8
  - Files: `tests/qa/test_visual_ui_qa_contract.bats`, `scripts/validate-pack.sh`, `engineering/visual-ui-qa-adapter/spec-to-code-map.md`
  - Test: `rtk bats tests/qa/test_visual_ui_qa_contract.bats`, `rtk bash scripts/validate-pack.sh`
  - Acceptance: 自动化测试和 pack validation 能发现 visual 模板缺失、状态枚举缺失、baseline 门禁缺失、routing 规则缺失、敏感证据约束缺失或越界绑定具体 diff/小程序工具。
  - Estimate: 45 min
