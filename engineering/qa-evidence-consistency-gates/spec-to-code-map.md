# Spec to Code Map: qa-evidence-consistency-gates

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SSF-QA-EVIDENCE-BROWSER-001 | Browser pass requires report and evidence | `templates/qa-signoff.md`, `templates/browser-run-report.md`, `skills/ssf-qa/SKILL.md`, `agents/qa-gatekeeper.md` | `tests/qa/test_browser_mcp_qa_state_consistency.bats` | Implemented |
| SSF-QA-EVIDENCE-BROWSER-002 | Browser blocked states match facts | `templates/browser-run-report.md`, `templates/qa-signoff.md`, `skills/ssf-qa/SKILL.md` | `tests/qa/test_browser_mcp_qa_state_consistency.bats` | Implemented |
| SSF-QA-EVIDENCE-VISUAL-001 | Visual pass requires comparable evidence | `templates/qa-signoff.md`, `templates/visual-comparison-report.md`, `skills/ssf-qa/SKILL.md`, `agents/qa-gatekeeper.md` | `tests/qa/test_visual_ui_qa_state_consistency.bats` | Implemented |
| SSF-QA-EVIDENCE-VISUAL-002 | Manual visual verification requires reviewer evidence | `templates/qa-signoff.md`, `templates/visual-comparison-report.md`, `skills/ssf-qa/SKILL.md` | `tests/qa/test_visual_ui_qa_state_consistency.bats` | Implemented |
| SSF-QA-EVIDENCE-DERIVE-001 | Browser plans derive from executable acceptance rows | `skills/ssf-qa/SKILL.md`, `agents/qa-gatekeeper.md`, `templates/qa-execution-plan.md` | `tests/qa/test_qa_plan_derivation_contract.bats` | Implemented |
| SSF-QA-EVIDENCE-DERIVE-002 | Visual plans derive from visual acceptance rows | `skills/ssf-qa/SKILL.md`, `agents/qa-gatekeeper.md`, `templates/visual-execution-plan.md` | `tests/qa/test_qa_plan_derivation_contract.bats` | Implemented |
| SSF-QA-EVIDENCE-CLUSTER-001 | Parent cluster QA summary records evidence status | `templates/integration-gate.md`, `skills/ssf-qa/SKILL.md`, `skills/ssf-ship/SKILL.md`, `agents/release-manager.md` | `tests/clusters/test_parent_cluster_qa_summary_contract.bats` | Implemented |
| SSF-QA-EVIDENCE-TEST-001 | Validation covers consistency gates | `scripts/validate-pack.sh` | `rtk bash scripts/validate-pack.sh` | Implemented |
| SSF-QA-EVIDENCE-N1 | Browser pass cannot omit evidence | Browser QA templates and skill | `tests/qa/test_browser_mcp_qa_state_consistency.bats` | Implemented |
| SSF-QA-EVIDENCE-N2 | Browser pass cannot hide missing target/tool/failure | Browser QA templates and skill | `tests/qa/test_browser_mcp_qa_state_consistency.bats` | Implemented |
| SSF-QA-EVIDENCE-N3 | Visual pass cannot omit comparable evidence | Visual QA templates and skill | `tests/qa/test_visual_ui_qa_state_consistency.bats` | Implemented |
| SSF-QA-EVIDENCE-N4 | Manual visual cannot omit reviewer evidence | Visual QA templates and skill | `tests/qa/test_visual_ui_qa_state_consistency.bats` | Implemented |
| SSF-QA-EVIDENCE-N5 | Plans preserve Spec ID mapping | QA execution templates and skill | `tests/qa/test_qa_plan_derivation_contract.bats` | Implemented |
| SSF-QA-EVIDENCE-N6 | Parent ship cannot pass missing evidence | Integration gate and ship guidance | `tests/clusters/test_parent_cluster_qa_summary_contract.bats` | Implemented |
