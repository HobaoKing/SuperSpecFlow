# Proposal: own-role-gates-remove-gstack-style

## Summary

Remove execution-level `gstack` attribution from SuperSpecFlow runtime instructions and present role review gates as SuperSpecFlow-owned workflow gates. Keep `gstack` only as design-source attribution in non-runtime source notes.

## Problem

Current routing, skills, and README text describe parts of the workflow as `gstack 风格` or `gstack 能力`. In practice this can make agents treat gstack as a recommended execution method rather than a historical influence. The user explicitly asked to remove the gstack recommended approach while preserving useful role-gate behavior.

Claude consultation was attempted but did not produce a safe usable result: the local CLI returned `ConnectionRefused`, and sandbox escalation was rejected because it would send private repository contents to an external service. A fallback sub-agent review completed and confirmed the gstack runtime attribution boundary.

## Goals

- Replace runtime `gstack` execution-language with SuperSpecFlow-owned role-gate language.
- Keep product, spec, engineering, QA, release, Git, archive, and retro gates as project workflow behavior.
- Allow design-source attribution in `NOTICE.md` and README source section only.
- Add validation so execution-layer files do not reintroduce `gstack` as a recommended style.

## Non-goals

- Do not remove SuperSpecFlow role gates.
- Do not rewrite the whole workflow or rename every agent role.
- Do not remove source attribution from `NOTICE.md`.
- Do not alter OpenSpec, Superpowers, or Karpathy behavior.

## User Impact

Users and agents will read SuperSpecFlow as its own workflow package. Role gates remain available, but they are no longer framed as gstack recommendations.

## Affected Areas

- `AGENTS.md`, `CLAUDE.md`
- `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`
- `README.md`, `NOTICE.md`
- `skills/ssf-think`, `skills/ssf-review`, `skills/ssf-ship`, `skills/ssf-git`, `skills/ssf-karpathy`
- `commands/`, `agents/` where role-gate language appears
- `scripts/validate-pack.sh`
- New or updated tests under `tests/routing/`

## Success Metrics

- Runtime instructions contain no `gstack 风格`, `gstack 能力`, `本阶段体现 gstack`, or equivalent recommended-method wording.
- `gstack` remains only in source-attribution locations.
- Validation fails if runtime files reintroduce execution-level gstack attribution.
- Existing role gates remain documented as SuperSpecFlow role gates.

## Risks

- Over-removal could weaken product/review/release gates.
- Too strict validation could reject legitimate source attribution.

## Rollout Strategy

Implement as a documentation and validation contract change. Update tests before changing text, then revise runtime instructions and validation.

## Open Questions

- Whether to keep role labels such as `CEO Court` or rename them to neutral names like `Value Gate`; this change should prefer SuperSpecFlow-owned names where practical.
