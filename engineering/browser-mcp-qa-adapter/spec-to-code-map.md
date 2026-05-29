# Spec to Code Map: browser-mcp-qa-adapter

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SSF-QA-BROWSER-001 | 定义 QA execution plan 文件 | `templates/qa-execution-plan.md`, `skills/ssf-qa/SKILL.md`, `commands/ssf-qa.md` | `tests/qa/test_browser_mcp_qa_contract.bats`, `rtk bash scripts/validate-pack.sh` | Implemented |
| SSF-QA-BROWSER-002 | 从 acceptance matrix 派生路径 | `skills/ssf-qa/SKILL.md`, `templates/qa-execution-plan.md` | `tests/qa/test_browser_mcp_qa_contract.bats` | Implemented |
| SSF-QA-BROWSER-003 | 记录可运行目标 | `templates/qa-execution-plan.md`, `templates/browser-run-report.md`, `skills/ssf-qa/SKILL.md` | `tests/qa/test_browser_mcp_qa_contract.bats` | Implemented |
| SSF-QA-BROWSER-004 | 检测浏览器或 MCP 工具可用性 | `skills/ssf-qa/SKILL.md`, `templates/browser-run-report.md`, `templates/qa-signoff.md` | `tests/qa/test_browser_mcp_qa_contract.bats` | Implemented |
| SSF-QA-BROWSER-005 | 定义 browser run report 文件 | `templates/browser-run-report.md`, `skills/ssf-qa/SKILL.md`, `commands/ssf-qa.md` | `tests/qa/test_browser_mcp_qa_contract.bats` | Implemented |
| SSF-QA-BROWSER-006 | 定义 QA evidence 目录 | `templates/browser-run-report.md`, `templates/qa-execution-plan.md`, `skills/ssf-qa/SKILL.md` | `tests/qa/test_browser_mcp_qa_contract.bats` | Implemented |
| SSF-QA-BROWSER-007 | 扩展 QA signoff 状态 | `templates/qa-signoff.md`, `skills/ssf-qa/SKILL.md` | `tests/qa/test_browser_mcp_qa_contract.bats` | Implemented |
| SSF-QA-BROWSER-008 | 保持 QA 文档一致 | `skills/ssf-qa/SKILL.md`, `templates/browser-run-report.md`, `templates/qa-signoff.md` | `tests/qa/test_browser_mcp_qa_contract.bats` | Implemented |
| SSF-QA-BROWSER-009 | 提供可复用模板 | `templates/qa-execution-plan.md`, `templates/browser-run-report.md`, `templates/qa-signoff.md` | `tests/qa/test_browser_mcp_qa_contract.bats` | Implemented |
| SSF-QA-BROWSER-010 | 接入 routing 和 pack validation | `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `scripts/validate-pack.sh`, `README.md` | `rtk bash scripts/validate-pack.sh` | Implemented |

## MUST NOT Coverage

| MUST NOT | Guard | Tests |
|---|---|---|
| SSF-QA-BROWSER-N1 | `ssf-qa` requires report, evidence, or manual verification before `Automated Browser Passed`. | `tests/qa/test_browser_mcp_qa_contract.bats` |
| SSF-QA-BROWSER-N2 | Missing target maps to `Blocked: No runnable target`. | `tests/qa/test_browser_mcp_qa_contract.bats` |
| SSF-QA-BROWSER-N3 | Missing tool maps to `Blocked: Tool unavailable`. | `tests/qa/test_browser_mcp_qa_contract.bats` |
| SSF-QA-BROWSER-N4 | Execution plan is derived from, not a replacement for, acceptance matrix. | `skills/ssf-qa/SKILL.md` |
| SSF-QA-BROWSER-N5 | Templates and skill prohibit secrets and sensitive evidence. | `templates/qa-execution-plan.md`, `templates/browser-run-report.md` |
| SSF-QA-BROWSER-N6 | Cluster/worktree protocol remains in `parallel-worktree-spec-clusters`. | `openspec/changes/parallel-worktree-spec-clusters/` |
| SSF-QA-BROWSER-N7 | Browser QA safety constraints prohibit production real-world actions. | `templates/qa-execution-plan.md` |
