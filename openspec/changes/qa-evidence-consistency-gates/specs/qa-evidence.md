# Spec: qa-evidence

## ADDED Requirements

### Requirement: SSF-QA-EVIDENCE-BROWSER-001 Browser pass requires report and evidence

Browser/MCP QA MUST NOT be marked passed unless required report and evidence or manual verification records exist.

#### Scenario: Automated browser QA passes
- GIVEN `qa-signoff.md` uses `Automated Browser Passed`
- WHEN QA evidence is checked
- THEN `browser-run-report.md` exists
- AND `qa-evidence/` exists or complete manual verification notes exist
- AND no journey result is failed

### Requirement: SSF-QA-EVIDENCE-BROWSER-002 Browser blocked states match report facts

Browser/MCP QA blocked states MUST match missing target or unavailable tool facts.

#### Scenario: Target missing
- GIVEN `browser-run-report.md` records missing target
- WHEN `qa-signoff.md` is written
- THEN Browser/MCP QA status is `Blocked: No runnable target`

#### Scenario: Tool unavailable
- GIVEN `browser-run-report.md` records browser or MCP tool unavailable
- WHEN `qa-signoff.md` is written
- THEN Browser/MCP QA status is `Blocked: Tool unavailable`

### Requirement: SSF-QA-EVIDENCE-VISUAL-001 Visual pass requires comparable evidence

Visual QA MUST NOT be marked `Visual Passed` unless baseline, actual screenshot, comparison report, diff result, and evidence are present.

#### Scenario: Visual QA passes
- GIVEN `qa-signoff.md` uses `Visual Passed`
- WHEN visual evidence is checked
- THEN `visual-execution-plan.md` exists
- AND `visual-comparison-report.md` exists
- AND baseline path and approval/reviewer exist
- AND actual screenshot exists
- AND diff output or threshold result exists
- AND `qa-evidence/visual/` exists or is referenced

### Requirement: SSF-QA-EVIDENCE-VISUAL-002 Manual visual verification requires reviewer evidence

Manual visual verification MUST include reviewer, notes, accepted differences, residual risk, and evidence path.

#### Scenario: Manual visual verification is used
- GIVEN visual status is `Manual Visual Verified`
- WHEN signoff is checked
- THEN manual reviewer is recorded
- AND comparison notes are recorded
- AND accepted differences are recorded
- AND residual risk is recorded
- AND evidence path is recorded

### Requirement: SSF-QA-EVIDENCE-DERIVE-001 Browser plans derive from executable acceptance rows

Browser QA execution plans MUST derive only E2E, user journey, or explicitly browser-required acceptance matrix rows.

#### Scenario: Mixed acceptance matrix
- GIVEN acceptance matrix contains Unit, Integration, E2E, Manual, and browser-required rows
- WHEN browser execution plan is derived
- THEN only E2E, user journey, or browser-required rows are included
- AND every derived journey preserves Spec ID mapping

### Requirement: SSF-QA-EVIDENCE-DERIVE-002 Visual plans derive from visual acceptance rows

Visual QA execution plans MUST derive only UI restoration, screenshot comparison, visual regression, or design-alignment rows.

#### Scenario: Mixed visual and non-visual rows
- GIVEN acceptance matrix contains visual and non-visual rows
- WHEN visual execution plan is derived
- THEN only visual rows are included
- AND every derived scenario preserves Spec ID mapping

### Requirement: SSF-QA-EVIDENCE-CLUSTER-001 Parent cluster QA summary records evidence status

Parent integration gate MUST summarize each cluster's browser, visual, manual, blocked, evidence, and regression status before ship.

#### Scenario: Parent change has clusters
- GIVEN `.superspecflow/clusters/<parent-change>/cluster-status.md` exists
- WHEN `/ssf-qa <parent-change>` or `/ssf-ship <parent-change>` runs
- THEN integration gate records browser QA status, visual QA status, manual QA status, evidence paths, blocked reason, and parent integration regression per cluster

#### Scenario: Cluster evidence missing
- GIVEN any cluster lacks required QA signoff, browser or visual evidence, review, commit evidence, or explicit blocked reason
- WHEN ship recommendation is prepared
- THEN recommendation is not `Ship`

### Requirement: SSF-QA-EVIDENCE-TEST-001 Validation covers evidence consistency gates

The pack MUST include tests and validation checks that catch false pass QA states.

#### Scenario: False pass fixture
- GIVEN a fixture marks QA passed without required evidence
- WHEN the relevant BATS test runs
- THEN the test fails the fixture validation

## MODIFIED Requirements

无。

## REMOVED Requirements

无。

## MUST NOT

- SSF-QA-EVIDENCE-N1 Browser QA MUST NOT use `Automated Browser Passed` without run report and evidence or complete manual verification.
- SSF-QA-EVIDENCE-N2 Browser QA MUST NOT pass when target is missing, tool is unavailable, or a journey failed.
- SSF-QA-EVIDENCE-N3 Visual QA MUST NOT use `Visual Passed` without baseline approval, actual screenshot, comparison report, diff/threshold result, and evidence.
- SSF-QA-EVIDENCE-N4 Manual visual verification MUST NOT omit reviewer, notes, accepted differences, residual risk, or evidence path.
- SSF-QA-EVIDENCE-N5 Execution plans MUST NOT replace acceptance matrix or drop Spec ID mapping.
- SSF-QA-EVIDENCE-N6 Parent cluster ship gates MUST NOT recommend `Ship` when cluster QA evidence is missing without explicit blocked/waived reason.

## MUST NOT Violation Signals

| MUST NOT | 可观察违规现象 |
|---|---|
| SSF-QA-EVIDENCE-N1 | `qa-signoff.md` says `Automated Browser Passed` but report/evidence/manual notes are absent. |
| SSF-QA-EVIDENCE-N2 | Browser run report records missing target, unavailable tool, or failed journey while signoff says passed. |
| SSF-QA-EVIDENCE-N3 | Visual signoff says `Visual Passed` but baseline, actual, diff, comparison report, or evidence is missing. |
| SSF-QA-EVIDENCE-N4 | Manual visual status lacks reviewer or residual risk. |
| SSF-QA-EVIDENCE-N5 | Execution plan rows cannot be traced back to acceptance matrix Spec IDs. |
| SSF-QA-EVIDENCE-N6 | Parent integration gate recommends ship while cluster evidence is incomplete. |
