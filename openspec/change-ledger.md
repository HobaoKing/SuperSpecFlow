# OpenSpec Change Ledger

This ledger is the committable package-repository summary for current
`openspec/changes/*` contracts. It does not replace proposal, specs, tasks,
spec-to-code maps, QA signoff, release decision, archive, or retro artifacts.

Allowed status values: `active`, `complete`, `archived`, `superseded`.

| Change ID | Status | Evidence Summary | Gaps / Notes |
|---|---|---|---|
| artifact-path-migration | active | Tasks and engineering map exist. | QA/Ship/Archive evidence not yet durable. |
| browser-mcp-qa-adapter | active | Tasks and engineering map exist; browser QA contract tests exist. | Needs durable Review/QA/Ship/Archive summary. |
| change-backlog-status-cleanup | active | Child change created by `workflow-hardening-program`. | Complete after ledger validation passes. |
| clarify-superspecflow-layer-boundary | active | Tasks and engineering map exist; supersedes role-gate framing. | Needs durable Review/QA/Ship/Archive summary. |
| cross-agent-verification | active | Tasks and engineering map exist; verification tests exist. | Needs durable Review/QA/Ship/Archive summary. |
| evidence-lifecycle-root-routing | active | Child change created by `workflow-hardening-program`. | Complete after root thinness and ledger validation pass. |
| high-risk-release-template-hardening | active | Child change created by `workflow-hardening-program`. | Complete after high-risk template validation passes. |
| init-project-routing | active | Tasks and engineering map exist; zero-touch tests exist. | Root thinness regression addressed by `evidence-lifecycle-root-routing`. |
| install-host-portability | active | Child change created by `workflow-hardening-program`. | Complete after host portability validation passes. |
| own-role-gates-remove-gstack-style | superseded | Superseded by `clarify-superspecflow-layer-boundary`. | Historical contract retained for traceability. |
| parallel-worktree-spec-clusters | active | Tasks and engineering map exist; cluster contract tests exist. | Needs durable Review/QA/Ship/Archive summary. |
| progress-tracking | active | Tasks and engineering map exist; progress tests exist. | Needs durable Review/QA/Ship/Archive summary. |
| qa-evidence-consistency-gates | active | Tasks and engineering map exist; QA consistency tests exist. | Needs durable Review/QA/Ship/Archive summary. |
| runtime-gate-validators | active | Child change created by `workflow-hardening-program`. | Complete after runtime validators pass. |
| strengthen-superpowers-spec-plans | active | Tasks and engineering map exist. | Host portability follow-up removes hardcoded reviewer prompt paths. |
| visual-ui-qa-adapter | archived | Local QA, release, archive, and retro evidence exists; released as `v1.2.0`. | `.superspecflow/` evidence remains local by design. |
| workflow-hardening-program | active | Parent hardening contract created. | Complete after child changes are verified. |
| workflow-scale-architecture | active | Parent contract and child changes exist; child changes are implemented. | Local release evidence still describes child work as follow-up; durable refresh tracked here. |
