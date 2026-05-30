# Spec Readiness Review: strengthen-superpowers-spec-plans

## Ready Checklist
- [x] Problem clear
- [x] Scope clear
- [x] Non-goals clear
- [x] Requirements have Spec IDs
- [x] Scenarios cover happy and negative paths
- [x] Acceptance criteria testable
- [x] Risks identified
- [x] Rollback possible or not needed

## Brainstorming Context

User clarified that Superpowers weakening is mainly in spec and plans. Local inspection and sub-agent review confirmed mismatch across `ssf-spec`, `templates/spec-readiness-review.md`, `templates/implementation-plan.md`, commands, agents, routing, README, and tests.

## Assumption Audit

- The goal is to strengthen future workflow generation, not rewrite all historical plan files.
- The preferred reviewer may be unavailable in Codex or non-Claude hosts, so fallback evidence is necessary.

## Alternatives Considered

- Only update `skills/ssf-build`: insufficient because the weak template remains the practical artifact source.
- Require full Superpowers docs in this repo: rejected because `docs/superpowers/` is a local runtime artifact boundary.

## Open Questions Disposition

- Small changes may use simplified plans only when the simplification is explicitly recorded.

## Spec Document Review

- Claude CLI consultation was attempted but unavailable.
- Fallback sub-agent review completed and recommended this change.

## Reviewer Result

Sub-agent result: changes needed in spec and plan discipline; recommended `strengthen-superpowers-spec-plans`.

## Blocked / Waived Evidence

Claude path waived due local API failure and escalation denial.

## Blockers

None.

## Recommendation

Ready to implement.
