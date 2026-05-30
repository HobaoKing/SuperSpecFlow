# OpenSpec Change Ledger

This ledger is the committable package-repository summary for current
`openspec/changes/*` contracts. It does not replace proposal, specs, tasks,
spec-to-code maps, QA signoff, release decision, archive, or retro artifacts.

Allowed status values: `active`, `complete`, `archived`, `superseded`.

| Change ID | Status | Evidence Summary | Gaps / Notes |
|---|---|---|---|
| artifact-path-migration | complete | Tasks and engineering map exist; covered by artifact path tests and pack validation. | Historical final evidence gap: no separate durable Ship/Archive packet. |
| browser-mcp-qa-adapter | complete | Tasks and engineering map exist; browser QA contract tests exist. | Historical final evidence gap: no separate durable Ship/Archive packet. |
| change-backlog-status-cleanup | complete | Child change completed by `workflow-hardening-program`; ledger validator covers rows and status rationale. | Historical final evidence gap: no separate durable Ship/Archive packet. |
| clarify-superspecflow-layer-boundary | complete | Tasks and engineering map exist; supersedes role-gate framing. | Historical final evidence gap: no separate durable Ship/Archive packet. |
| comprehensive-maintenance-hardening | complete | Parent and four child changes completed with three-agent review consensus, focused contract tests, full Bats, non-default TMPDIR Bats, and pack validation. | shellcheck unavailable locally; CI remains configured to run shellcheck. |
| cross-agent-verification | complete | Tasks and engineering map exist; verification tests exist. | Historical final evidence gap: no separate durable Ship/Archive packet. |
| deepseek-review-hardening | complete | DeepSeek review findings mapped to Spec IDs with bats, pack validation, CI, and ledger updates. | Final validation expected in commit evidence; no fabricated historical artifacts. |
| evidence-lifecycle-root-routing | complete | Child change completed by `workflow-hardening-program`; root thinness and ledger validation pass. | Historical final evidence gap: no separate durable Ship/Archive packet. |
| high-risk-release-template-hardening | complete | Child change completed by `workflow-hardening-program`; high-risk template validation passes. | Historical final evidence gap: no separate durable Ship/Archive packet. |
| init-project-routing | complete | Tasks and engineering map exist; zero-touch tests exist; root thinness regression addressed. | Historical final evidence gap: no separate durable Ship/Archive packet. |
| install-host-portability | complete | Child change completed by `workflow-hardening-program`; host portability validation passes. | Historical final evidence gap: no separate durable Ship/Archive packet. |
| own-role-gates-remove-gstack-style | superseded | Superseded by `clarify-superspecflow-layer-boundary`. | Historical contract retained for traceability. |
| parallel-worktree-spec-clusters | complete | Tasks and engineering map exist; cluster contract tests exist. | Historical final evidence gap: no separate durable Ship/Archive packet. |
| progress-tracking | complete | Tasks and engineering map exist; progress tests exist. | Historical final evidence gap: no separate durable Ship/Archive packet. |
| qa-evidence-consistency-gates | complete | Tasks and engineering map exist; QA consistency tests exist. | Historical final evidence gap: no separate durable Ship/Archive packet. |
| runtime-gate-validators | complete | Child change completed by `workflow-hardening-program`; runtime validator tests pass. | Historical final evidence gap: no separate durable Ship/Archive packet. |
| routing-docs-drift-reduction | complete | Canonical routing source and validation guard added; README and installation docs trimmed; workflow-scale evidence wording refreshed. | Parent completion recorded in `comprehensive-maintenance-hardening`. |
| strengthen-superpowers-spec-plans | complete | Tasks and engineering map exist; host portability follow-up removed hardcoded reviewer prompt paths. | Historical final evidence gap: no separate durable Ship/Archive packet. |
| template-skill-usability-polish | complete | Skeletal templates gained local guidance; ssf-build now cross-references detailed discipline while preserving gates; retro and archive continuation were strengthened. | Parent completion recorded in `comprehensive-maintenance-hardening`. |
| test-infra-portability-hardening | complete | TMPDIR cleanup now follows the effective temp root, root-mutating contract tests run in copied fixtures, and CI covers non-default TMPDIR. | Parent completion recorded in `comprehensive-maintenance-hardening`. |
| validator-developer-tooling | complete | Focused test runner filtering, validate-ready new-change scaffold, and granular validator diagnostics implemented with fixture tests. | Parent completion recorded in `comprehensive-maintenance-hardening`. |
| visual-ui-qa-adapter | archived | Local QA, release, archive, and retro evidence exists; released as `v1.2.0`. | `.superspecflow/` evidence remains local by design. |
| workflow-hardening-program | complete | Parent and child hardening changes verified by pack validation and full bats suite. | Historical final evidence gap: no separate durable Ship/Archive packet. |
| workflow-scale-architecture | complete | Parent contract and child changes exist; child changes are implemented. | Historical final evidence gap: no separate durable Ship/Archive packet. |
| install-discoverability-onboarding | complete | Proposal/design/tasks/specs 写实（SSF-ONBOARD-001..006）；install-global.sh、_ssf_init_apply.sh、README、docs/installation.md、commands/ssf-init.md 的安装可发现性与 onboarding 修复已实现；新增 tests/install、tests/init、tests/docs 契约测试；pack validation、targeted onboarding tests 与全量 bats 186 ok 通过；含一次 Codex 独立只读评审作为 cross-agent verification 输入。 | Release evidence recorded in v1.2.2 metadata; shellcheck unavailable locally, CI remains configured to run shellcheck. |
