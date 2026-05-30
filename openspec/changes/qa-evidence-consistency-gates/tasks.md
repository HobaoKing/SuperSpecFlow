# Tasks: qa-evidence-consistency-gates

- [x] T1: Add Browser/MCP QA state consistency tests
  - Spec: SSF-QA-EVIDENCE-BROWSER-001, SSF-QA-EVIDENCE-BROWSER-002, SSF-QA-EVIDENCE-N1, SSF-QA-EVIDENCE-N2
  - Files: `tests/qa/test_browser_mcp_qa_state_consistency.bats`, `scripts/validate-pack.sh`
  - Test: `rtk bats tests/qa/test_browser_mcp_qa_state_consistency.bats`
  - Acceptance: Fixture tests fail when browser QA is passed with missing run report, missing evidence/manual notes, missing target, unavailable tool, or failed journey.
  - Estimate: 55 min

- [x] T2: Add Visual UI QA state consistency tests
  - Spec: SSF-QA-EVIDENCE-VISUAL-001, SSF-QA-EVIDENCE-VISUAL-002, SSF-QA-EVIDENCE-N3, SSF-QA-EVIDENCE-N4
  - Files: `tests/qa/test_visual_ui_qa_state_consistency.bats`, `scripts/validate-pack.sh`
  - Test: `rtk bats tests/qa/test_visual_ui_qa_state_consistency.bats`
  - Acceptance: Fixture tests fail when visual QA is passed without baseline approval, actual screenshot, comparison report, diff output/threshold result, or evidence.
  - Estimate: 55 min

- [x] T3: Add QA plan derivation contract tests
  - Spec: SSF-QA-EVIDENCE-DERIVE-001, SSF-QA-EVIDENCE-DERIVE-002, SSF-QA-EVIDENCE-N5
  - Files: `tests/qa/test_qa_plan_derivation_contract.bats`, `skills/ssf-qa/SKILL.md`, `agents/qa-gatekeeper.md`
  - Test: `rtk bats tests/qa/test_qa_plan_derivation_contract.bats`
  - Acceptance: Tests verify browser and visual plans derive only appropriate acceptance rows and preserve Spec ID mapping.
  - Estimate: 45 min

- [x] T4: Strengthen QA templates and instructions
  - Spec: SSF-QA-EVIDENCE-BROWSER-001, SSF-QA-EVIDENCE-BROWSER-002, SSF-QA-EVIDENCE-VISUAL-001, SSF-QA-EVIDENCE-VISUAL-002, SSF-QA-EVIDENCE-DERIVE-001, SSF-QA-EVIDENCE-DERIVE-002
  - Files: `templates/qa-signoff.md`, `templates/browser-run-report.md`, `templates/visual-comparison-report.md`, `skills/ssf-qa/SKILL.md`, `agents/qa-gatekeeper.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `README.md`
  - Test: `rtk bats tests/qa/test_browser_mcp_qa_state_consistency.bats tests/qa/test_visual_ui_qa_state_consistency.bats tests/qa/test_qa_plan_derivation_contract.bats`
  - Acceptance: QA guidance includes explicit consistency rules that prevent false pass states.
  - Estimate: 65 min

- [x] T5: Add parent cluster QA summary gate
  - Spec: SSF-QA-EVIDENCE-CLUSTER-001, SSF-QA-EVIDENCE-N6
  - Files: `templates/integration-gate.md`, `skills/ssf-qa/SKILL.md`, `skills/ssf-ship/SKILL.md`, `agents/release-manager.md`, `tests/clusters/test_parent_cluster_qa_summary_contract.bats`
  - Test: `rtk bats tests/clusters/test_parent_cluster_qa_summary_contract.bats`
  - Acceptance: Parent integration gate records browser, visual, manual, blocked, evidence, and regression status per cluster; missing evidence blocks Ship.
  - Estimate: 55 min

- [x] T6: Update map and run full QA validation
  - Spec: SSF-QA-EVIDENCE-TEST-001
  - Files: `engineering/qa-evidence-consistency-gates/spec-to-code-map.md`
  - Test: `rtk bash scripts/validate-pack.sh`, `rtk bats tests/qa/test_browser_mcp_qa_contract.bats tests/qa/test_visual_ui_qa_contract.bats tests/qa/test_browser_mcp_qa_state_consistency.bats tests/qa/test_visual_ui_qa_state_consistency.bats tests/qa/test_qa_plan_derivation_contract.bats tests/clusters/test_parent_cluster_qa_summary_contract.bats`
  - Acceptance: Existing QA tests and new consistency tests pass.
  - Estimate: 30 min
