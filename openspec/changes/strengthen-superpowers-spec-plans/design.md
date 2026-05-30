# Technical Design: strengthen-superpowers-spec-plans

## Architecture Summary

This change aligns the visible artifacts with the Superpowers discipline already implied by `ssf-build`. The source of truth remains OpenSpec for requirements and tasks, while Superpowers governs how specs are reviewed and how implementation plans become executable.

## Superpowers Spec Discipline

`ssf-spec` gains a required preflight:

- Goal
- Upstream think / brainstorming source
- Assumptions
- Alternatives considered
- Open questions and disposition
- Waiver reason when upstream context is absent

`Spec Readiness Review` gains sections for:

- Brainstorming Context
- Assumption Audit
- Alternatives Considered
- Open Questions Disposition
- Spec Document Review Loop
- Reviewer Result
- Blocked / Waived Evidence

The review loop remains tool-agnostic. If the preferred reviewer prompt or sub-agent is unavailable, the agent must record blocked or waived evidence instead of silently skipping review.

## Superpowers Plan Discipline

`templates/implementation-plan.md` is rewritten to match the stronger plan format:

- Header with goal, architecture, spec contract, tech stack
- Scope Check
- File Structure
- Bite-Sized Tasks
- Per-task `**Spec:**`
- Step 1 failing test
- Step 2 expected failure command and message
- Step 3 minimal implementation
- Step 4 expected pass command
- Step 5 Git gate preparation
- Plan Review Loop
- Execution Handoff

The template intentionally uses placeholders rather than real application code, but it must require complete code blocks in generated plans.

## Synchronization

The same requirements are mirrored in:

- `commands/ssf-spec.md`
- `commands/ssf-build.md`
- `agents/spec-architect.md`
- `agents/implementation-engineer.md`
- `routing/AGENTS.routing.md`
- `routing/CLAUDE.routing.md`
- `README.md`

## Validation

New tests verify the template and instruction contract. `scripts/validate-pack.sh` gains checks so pack validation catches drift without relying only on BATS.

## Security / Permission Considerations

No production systems or secrets are involved. Reviewer evidence must not rely on inaccessible private chat context.

## Failure Modes

- Agents may overproduce for tiny changes. Mitigation: allow explicit simplification with rationale.
- Reviewer prompts may not exist. Mitigation: blocked/waived evidence is required.

## Observability

Evidence comes from:

- `rtk bats tests/workflow/test_spec_discipline_contract.bats`
- `rtk bats tests/workflow/test_implementation_plan_contract.bats`
- `rtk bash scripts/validate-pack.sh`

## Migration Plan

No historical plan migration required. Future generated plans must use the stronger template.

## Rollback Plan

Revert template/instruction/test changes. Existing OpenSpec change contracts remain valid.

## Alternatives Considered

- Only update `skills/ssf-build`: rejected because the weak template and commands still drive actual behavior.
- Rewrite all historical implementation plans: rejected as churn unrelated to future enforcement.
