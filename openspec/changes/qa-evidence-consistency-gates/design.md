# Technical Design: qa-evidence-consistency-gates

## Architecture Summary

This change adds evidence consistency checks around existing QA protocols. It does not execute browser or visual tools; it defines and verifies the relationships among acceptance matrix, execution plans, run reports, evidence paths, signoff states, and parent cluster summaries.

## Browser/MCP QA Consistency

Browser QA pass states require:

- `qa-execution-plan.md` exists and contains relevant Spec IDs.
- `browser-run-report.md` exists.
- Target is not missing.
- Tool is not unavailable.
- No journey result is failed.
- `qa-evidence/` exists or manual verification notes are complete.

Blocked states require:

- `Blocked: No runnable target` when the report records missing target.
- `Blocked: Tool unavailable` when the report records tool unavailable.

## Visual UI QA Consistency

`Visual Passed` requires:

- `visual-execution-plan.md`
- `visual-comparison-report.md`
- baseline path and approval/reviewer
- actual screenshot
- diff output or threshold result
- `qa-evidence/visual/`

Manual visual verification requires:

- manual reviewer
- comparison notes
- accepted differences
- residual risk
- evidence path

Blocked states map to missing baseline, missing actual screenshot, or unavailable diff tool.

## Plan Derivation

Fixture tests verify that:

- Browser execution plans derive only E2E, user journey, or browser-required acceptance rows.
- Visual execution plans derive only UI restoration, screenshot comparison, visual regression, or design-alignment rows.
- Derived rows retain Spec ID mapping and do not replace the original acceptance matrix.

The first implementation can validate documented fixture transformations rather than shipping a production parser.

## Parent Cluster QA Summary

`templates/integration-gate.md` gains explicit QA columns:

- Browser QA Status
- Visual QA Status
- Manual QA Status
- Evidence Paths
- Blocked Reason
- Parent Integration Regression

Shipping is blocked when any cluster lacks required QA signoff, browser/visual evidence, review, commit evidence, or explicit blocked/waived reason.

## Validation Strategy

Use fixture-style BATS tests under temporary directories. Add `scripts/validate-pack.sh` checks for required template/instruction language.

## Security / Permission Considerations

Evidence directories must continue to reject secrets, tokens, credentials, production customer data, unredacted personal information, and sensitive logs.

## Failure Modes

- Tests may verify text contracts rather than full runtime behavior. Mitigation: use fixtures that model false-pass states.
- Parent cluster rules can become too strict for non-UI changes. Mitigation: allow explicit not-applicable/manual/blocked statuses.

## Observability

Evidence comes from:

- `rtk bats tests/qa/test_browser_mcp_qa_state_consistency.bats`
- `rtk bats tests/qa/test_visual_ui_qa_state_consistency.bats`
- `rtk bats tests/qa/test_qa_plan_derivation_contract.bats`
- `rtk bats tests/clusters/test_parent_cluster_qa_summary_contract.bats`
- `rtk bash scripts/validate-pack.sh`

## Migration Plan

No persisted runtime data migration. Future QA artifacts follow stronger consistency rules.

## Rollback Plan

Revert tests, template updates, and instruction changes. Existing browser and visual QA protocols remain.

## Alternatives Considered

- Reopen previous adapter changes: rejected because their protocol tasks are complete and the new scope spans both adapters plus cluster QA.
- Build a full QA artifact parser: rejected for first iteration; fixture validators are sufficient for workflow contract enforcement.
