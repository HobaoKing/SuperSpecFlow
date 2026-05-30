# Proposal: strengthen-superpowers-spec-plans

## Summary

Strengthen Superpowers discipline in the spec and implementation-plan stages. The current `ssf-spec` and `ssf-build` skills contain some strong rules, but commands, agents, templates, routing, README, and validation do not consistently enforce them.

## Problem

The project claims to integrate OpenSpec, Superpowers, and Karpathy-style engineering discipline. In practice, Superpowers is weaker specifically in spec creation and implementation plans:

- `ssf-spec` starts with OpenSpec artifacts but does not require brainstorming context, assumptions, alternatives, or open-question disposition when upstream think output is missing.
- `templates/spec-readiness-review.md` is too thin to capture Superpowers review evidence.
- `templates/implementation-plan.md` is much weaker than `skills/ssf-build/SKILL.md` and lacks the writing-plans structure.
- `commands/ssf-spec.md`, `commands/ssf-build.md`, `agents/spec-architect.md`, `agents/implementation-engineer.md`, routing, and README do not consistently require plan/spec review loops.

Claude consultation was attempted but was not safely available. A fallback sub-agent review confirmed that Superpowers weakening is concentrated in spec and plan artifacts and recommended this change.

## Goals

- Make `ssf-spec` require or explicitly waive brainstorming context before declaring spec ready.
- Expand spec readiness review to capture assumptions, alternatives, open questions, reviewer results, and blocked/waived evidence.
- Make implementation plan templates match the stronger Superpowers writing-plans structure.
- Synchronize skill, command, agent, routing, README, and validation contracts.
- Add tests that prevent spec/plan discipline from drifting again.

## Non-goals

- Do not replace OpenSpec with Superpowers documents.
- Do not require all historical implementation plans to be rewritten.
- Do not bind the workflow to a single Claude plugin cache path.
- Do not remove Karpathy preflight or Git gates.

## User Impact

Users get specs that preserve design reasoning and plans that are directly executable by agents using TDD, review loops, and small steps.

## Affected Areas

- `skills/ssf-spec/SKILL.md`, `skills/ssf-build/SKILL.md`
- `commands/ssf-spec.md`, `commands/ssf-build.md`
- `agents/spec-architect.md`, `agents/implementation-engineer.md`
- `templates/spec-readiness-review.md`, `templates/implementation-plan.md`
- `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`
- `README.md`
- `scripts/validate-pack.sh`
- New tests under `tests/workflow/`

## Success Metrics

- Spec readiness cannot be claimed without brainstorming context or explicit waiver.
- Implementation plan template includes goal, architecture, spec contract, file structure, bite-sized TDD steps, plan review loop, and execution handoff.
- Commands and agents tell workers to produce the stronger artifacts, not just thin lists.
- Validation detects missing Superpowers spec/plan sections.

## Risks

- The stronger template can be verbose for small changes.
- Reviewer tool availability varies by host, so fallback evidence must be explicit.

## Rollout Strategy

Add contract tests first. Update templates and instructions. Run pack validation and targeted BATS tests.

## Open Questions

- Whether future versions should provide a small-change implementation-plan template. This change keeps one strong default and allows explicit simplification only with rationale.
