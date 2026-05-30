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
| strengthen-superpowers-spec-plans | complete | Tasks and engineering map exist; host portability follow-up removed hardcoded reviewer prompt paths. | Historical final evidence gap: no separate durable Ship/Archive packet. |
| visual-ui-qa-adapter | archived | Local QA, release, archive, and retro evidence exists; released as `v1.2.0`. | `.superspecflow/` evidence remains local by design. |
| workflow-hardening-program | complete | Parent and child hardening changes verified by pack validation and full bats suite. | Historical final evidence gap: no separate durable Ship/Archive packet. |
| workflow-scale-architecture | complete | Parent contract and child changes exist; child changes are implemented. | Historical final evidence gap: no separate durable Ship/Archive packet. |
