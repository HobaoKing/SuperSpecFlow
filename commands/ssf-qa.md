Use the `ssf-qa` skill.

Change id: $ARGUMENTS

Create QA gate under `.superspecflow/qa/<change-id>/`:
1. Acceptance Matrix.
2. Negative Test Matrix.
3. Risk Matrix.
4. Regression Checklist.
5. Exploratory Test Charter.
6. Browser/MCP `qa-execution-plan.md` for E2E or user journey scenarios.
7. `browser-run-report.md` and `qa-evidence/` when target and tools are available; blocked status when not available.
8. Visual UI `visual-execution-plan.md` for UI restoration, screenshot comparison, visual regression, or design alignment scenarios.
9. `visual-comparison-report.md` and `qa-evidence/visual/` for `platform: web | mini-program`; use `Visual Passed`, `Manual Visual Verified`, `Visual Failed`, `Blocked: Missing baseline`, `Blocked: Missing actual screenshot`, or `Blocked: Diff tool unavailable`.
10. Parent cluster QA evidence summary when `<change-id>` has `.superspecflow/clusters/<change-id>/`.
11. QA Signoff with Ship / Ship with monitoring / Do not ship.
