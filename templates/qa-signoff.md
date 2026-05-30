# QA Signoff: [change-id]

Path: `.superspecflow/qa/[change-id]/qa-signoff.md`

## Test Summary

## Passed

## Failed

## Release Blockers

## Non-blocking Issues

## Residual Risk

## Browser / MCP QA Status
- Status: Automated Browser Passed | Manual Verified | Blocked: No runnable target | Blocked: Tool unavailable | Failed
- Execution Plan: `.superspecflow/qa/[change-id]/qa-execution-plan.md`
- Browser Run Report: `.superspecflow/qa/[change-id]/browser-run-report.md`
- Evidence: `.superspecflow/qa/[change-id]/qa-evidence/`
- Manual Verification Notes:

### Pass Consistency Check
- [ ] `Automated Browser Passed` has `browser-run-report.md`.
- [ ] `Automated Browser Passed` has `qa-evidence/` or complete Manual Verification Notes.
- [ ] Missing target requires `Blocked: No runnable target`.
- [ ] Tool unavailable requires `Blocked: Tool unavailable`.
- [ ] Failed journey forbids `Automated Browser Passed`.

## Visual UI QA Status
- Status: Visual Passed | Manual Visual Verified | Visual Failed | Blocked: Missing baseline | Blocked: Missing actual screenshot | Blocked: Diff tool unavailable
- Visual Execution Plan: `.superspecflow/qa/[change-id]/visual-execution-plan.md`
- Visual Comparison Report: `.superspecflow/qa/[change-id]/visual-comparison-report.md`
- Evidence: `.superspecflow/qa/[change-id]/qa-evidence/visual/`
- Baseline:
- Actual Screenshot:
- Diff Output:
- Manual Reviewer:
- Residual Risk:

### Visual Pass Consistency Check
- [ ] `Visual Passed` has baseline path and baseline approval / reviewer.
- [ ] `Visual Passed` has actual screenshot.
- [ ] `Visual Passed` has visual comparison report.
- [ ] `Visual Passed` has diff output or threshold result.
- [ ] `Visual Passed` has `qa-evidence/visual/`.

### Manual Visual Verification Check
- [ ] `Manual Visual Verified` has manual reviewer.
- [ ] `Manual Visual Verified` has comparison notes.
- [ ] `Manual Visual Verified` has accepted differences.
- [ ] `Manual Visual Verified` has residual risk.
- [ ] `Manual Visual Verified` has evidence path.

## Recommendation
- Ship
- Ship with monitoring
- Do not ship
