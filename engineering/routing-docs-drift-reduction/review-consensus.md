# Review Consensus: routing-docs-drift-reduction

## Scope Reviewed

Routing public file drift, README / installation duplication, and workflow-scale stale evidence wording.

## Reviewers

- Aristotle: CHANGES_REQUESTED; require canonical routing source, README trim, installation appendix, workflow-scale wording refresh, and passing validation.
- Anscombe: CHANGES_REQUESTED; same blockers plus ledger completion for already-finished test infra child.
- Faraday: CHANGES_REQUESTED; same blockers and missing routing drift tests.

## Consensus

Do not replace public routing paths with raw symlinks. Preserve `routing/AGENTS.routing.md` and `routing/CLAUDE.routing.md` as portable regular files or generated/materialized equivalents, and add validation against drift. Keep README concise while preserving canonical details in `docs/installation.md`.

## Required Tests

- Routing drift guard.
- README keeps quick install, `/ssf-init`, uninstall, and docs links.
- Legacy symlink docs remain available as compatibility appendix.
- workflow-scale map no longer contains stale child draft/future wording.
