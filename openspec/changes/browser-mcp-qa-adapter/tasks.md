# Tasks: browser-mcp-qa-adapter

- [x] T1: 提供 browser QA runtime 模板
  - Spec: SSF-QA-BROWSER-001, SSF-QA-BROWSER-005, SSF-QA-BROWSER-006, SSF-QA-BROWSER-007, SSF-QA-BROWSER-009, SSF-QA-BROWSER-N1, SSF-QA-BROWSER-N5
  - Files: `templates/qa-execution-plan.md`, `templates/browser-run-report.md`, `templates/qa-signoff.md`
  - Test: `rtk bash scripts/validate-pack.sh`, `rtk bats tests/qa/test_browser_mcp_qa_contract.bats`
  - Acceptance: 模板包含 `.superspecflow/qa/<change-id>/qa-execution-plan.md`、`.superspecflow/qa/<change-id>/browser-run-report.md`、`.superspecflow/qa/<change-id>/qa-evidence/` 和受控 browser QA 状态枚举。
  - Estimate: 30 min

- [x] T2: 接入 ssf-qa browser QA 规则
  - Spec: SSF-QA-BROWSER-001, SSF-QA-BROWSER-002, SSF-QA-BROWSER-003, SSF-QA-BROWSER-004, SSF-QA-BROWSER-005, SSF-QA-BROWSER-006, SSF-QA-BROWSER-007, SSF-QA-BROWSER-008, SSF-QA-BROWSER-N1, SSF-QA-BROWSER-N2, SSF-QA-BROWSER-N3, SSF-QA-BROWSER-N4, SSF-QA-BROWSER-N7
  - Files: `skills/ssf-qa/SKILL.md`, `agents/qa-gatekeeper.md`, `commands/ssf-qa.md`
  - Test: `rtk bash scripts/validate-pack.sh`, `rtk bats tests/qa/test_browser_mcp_qa_contract.bats`
  - Acceptance: `ssf-qa` 要求从 acceptance matrix 生成 execution plan，检查 target/tool，可执行时写 browser run report，不可执行时写 blocked signoff。
  - Estimate: 45 min

- [x] T3: 接入 routing 和文档说明
  - Spec: SSF-QA-BROWSER-003, SSF-QA-BROWSER-004, SSF-QA-BROWSER-007, SSF-QA-BROWSER-010, SSF-QA-BROWSER-N2, SSF-QA-BROWSER-N3
  - Files: `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `README.md`
  - Test: `rtk bash scripts/validate-pack.sh`, `rtk bats tests/qa/test_browser_mcp_qa_contract.bats`
  - Acceptance: 路由和 README 说明 browser/MCP QA 的运行时路径、blocked 状态和 evidence-backed signoff 边界。
  - Estimate: 25 min

- [x] T4: 增加 browser MCP QA 契约验证
  - Spec: SSF-QA-BROWSER-001, SSF-QA-BROWSER-005, SSF-QA-BROWSER-006, SSF-QA-BROWSER-007, SSF-QA-BROWSER-009, SSF-QA-BROWSER-010, SSF-QA-BROWSER-N1, SSF-QA-BROWSER-N2, SSF-QA-BROWSER-N3, SSF-QA-BROWSER-N4, SSF-QA-BROWSER-N5, SSF-QA-BROWSER-N6, SSF-QA-BROWSER-N7
  - Files: `tests/qa/test_browser_mcp_qa_contract.bats`, `scripts/validate-pack.sh`, `engineering/browser-mcp-qa-adapter/spec-to-code-map.md`
  - Test: `rtk bats tests/qa/test_browser_mcp_qa_contract.bats`, `rtk bash scripts/validate-pack.sh`
  - Acceptance: 自动化测试和 pack validation 能发现模板缺失、`ssf-qa` 规则缺失、routing 规则缺失、非法状态枚举或越界实现 cluster/worktree 行为。
  - Estimate: 40 min
