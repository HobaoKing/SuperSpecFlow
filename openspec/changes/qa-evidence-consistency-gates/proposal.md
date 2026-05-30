# Proposal: qa-evidence-consistency-gates

## Summary

Add executable QA evidence consistency gates for Browser/MCP QA, Visual UI QA, and parent cluster QA summaries. Existing QA adapter changes define the protocols, but current tests mostly verify keyword presence and do not prevent false pass states.

## Problem

`browser-mcp-qa-adapter` and `visual-ui-qa-adapter` are marked complete and include templates, routing, skills, and grep-based contract tests. The missing piece is stronger verifiability:

- `Automated Browser Passed` can be written even when target/tool/run evidence is missing unless the agent follows rules manually.
- `Visual Passed` can be written without machine-checked baseline, actual screenshot, diff output, or evidence requirements.
- Execution plans are not tested against acceptance matrix derivation rules.
- Parent cluster QA summaries do not explicitly capture browser/visual/manual/blocked state for each cluster.

Claude consultation was not safely available. A fallback QA sub-agent review confirmed these gaps and recommended this follow-up change instead of reopening the completed adapter changes.

## Goals

- Add state-consistency rules and tests for Browser/MCP QA signoff.
- Add state-consistency rules and tests for Visual UI QA signoff.
- Add derivation contract tests for browser and visual execution plans from acceptance matrix rows.
- Extend parent cluster QA summary expectations with browser, visual, manual, blocked, and regression evidence.
- Strengthen validation so QA false-pass conditions are caught before ship.

## Non-goals

- Do not implement a full browser runner, MCP server, image diff algorithm, or mini-program runner.
- Do not reopen or rewrite completed `browser-mcp-qa-adapter` and `visual-ui-qa-adapter` tasks.
- Do not require storing real screenshots or traces in the repository.
- Do not make `.superspecflow/` runtime artifacts tracked in Git.

## User Impact

QA becomes harder to fake accidentally. If an automated path did not run, the signoff must be blocked or manually verified with explicit evidence.

## Affected Areas

- `skills/ssf-qa/SKILL.md`
- `agents/qa-gatekeeper.md`
- `templates/qa-signoff.md`
- `templates/browser-run-report.md`
- `templates/visual-comparison-report.md`
- `templates/integration-gate.md`
- `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`
- `README.md`
- `scripts/validate-pack.sh`
- New tests under `tests/qa/` and `tests/clusters/`

## Success Metrics

- Tests fail when Browser QA is marked passed with missing target/tool/evidence or failed journey.
- Tests fail when Visual QA is marked passed without baseline approval, actual screenshot, comparison report, diff result, or evidence.
- Tests verify plan derivation rules preserve Spec ID mapping.
- Parent cluster gate requires explicit QA status and missing evidence blocks ship.

## Risks

- Fixture validation can overfit to template text.
- Runtime `.superspecflow/` artifacts are not committed, so tests must use temporary fixtures.

## Rollout Strategy

Create fixture-style BATS tests and lightweight shell validators. Then update templates, skills, agents, routing, and docs to expose the new consistency gates.

## Open Questions

- Whether a future release should ship a standalone `ssf-qa-validate` executable. This change keeps validation inside tests and pack validation.
