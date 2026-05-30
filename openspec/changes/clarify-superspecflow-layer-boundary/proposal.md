# Proposal: clarify-superspecflow-layer-boundary

## Summary

Clarify SuperSpecFlow's architecture boundary after `own-role-gates-remove-gstack-style`. OpenSpec is the contract layer, Superpowers is the execution discipline layer, and SuperSpecFlow is the routing/glue/adapter layer that composes them. Runtime guidance must not present SuperSpecFlow as a proprietary role-gate framework.

## Problem

`own-role-gates-remove-gstack-style` correctly removed execution-level `gstack` wording, but it replaced that framing with `SuperSpecFlow 角色门禁`. That phrase now appears in README, root routing instructions, centralized routing, tests, and pack validation. As a result, validation preserves the wrong architecture: SuperSpecFlow looks like it owns a custom product/spec/engineering/QA/release/Git role system instead of integrating OpenSpec and Superpowers.

The user confirmed the intended model:

- OpenSpec is the contract layer: change-id, Spec ID, requirements, tasks, archive, traceability.
- Superpowers is the execution discipline layer: brainstorming, writing-plans, TDD, systematic debugging, verification-before-completion, and review discipline.
- SuperSpecFlow is the glue/routing/adapter layer: route natural-language requests to the right OpenSpec + Superpowers combination rather than replacing them with a project-owned role framework.

Codex analysis and a sub-agent review agreed on a corrective change. Claude consultation was requested but stalled without output; after user approval, opencode was used as the replacement third-party consultation. Opencode approved the direction conditionally and asked for explicit routing input/output, discipline traceability, and stronger positive validation; those points are included in this change.

## Goals

- Replace `SuperSpecFlow 角色门禁` framing with `SuperSpecFlow 路由与适配层`.
- Make README and routing clearly describe OpenSpec as the contract layer and Superpowers as the execution discipline layer.
- Keep stage checks such as QA, release, and Git gates, but frame them as phase checks derived from OpenSpec + Superpowers + GitOps, not as a proprietary role-gate framework.
- Preserve the runtime ban on `gstack` execution wording while keeping source attribution in `NOTICE.md` and README design-source notes.
- Update tests and pack validation so they reject the old role-gate framing and require the new layer boundary.
- Define routing input/output and record selected Superpowers execution discipline in traceable stage artifacts.
- Mark the relevant old role-gate requirements as superseded by the new layer-boundary contract.

## Non-goals

- Do not remove OpenSpec, Superpowers, Karpathy, GitOps, QA, release, or Git discipline.
- Do not remove `agents/` files; they remain useful stage personas and focused prompts.
- Do not introduce an external runtime dependency on OpenSpec or Superpowers.
- Do not rewrite all completed historical changes.
- Do not weaken high-risk change gates, QA evidence, release checks, or Chinese Git/PR requirements.

## User Impact

Users and agents will understand SuperSpecFlow as an orchestrator that makes OpenSpec and Superpowers work together in projects. The workflow remains strict where needed, but its authority comes from traceable contracts, execution discipline, and evidence, not from a separate custom role hierarchy.

## Affected Areas

- `README.md`
- `AGENTS.md`, `CLAUDE.md`
- `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`
- `skills/ssf-think`, `skills/ssf-review`, `skills/ssf-ship`, `skills/ssf-git`, `skills/ssf-karpathy`
- `docs/installation.md`, `docs/compatibility.md`
- `tests/routing/test_role_gate_source_boundary.bats`
- `scripts/validate-pack.sh`
- `openspec/changes/own-role-gates-remove-gstack-style/`
- `engineering/own-role-gates-remove-gstack-style/`
- `engineering/clarify-superspecflow-layer-boundary/`

## Success Metrics

- Runtime docs no longer contain `SuperSpecFlow 角色门禁`.
- README and both centralized routing files contain `OpenSpec 合同层`, `Superpowers 执行纪律层`, and `SuperSpecFlow 路由与适配层`.
- Validation fails if runtime guidance reintroduces `SuperSpecFlow 角色门禁` or says SuperSpecFlow defines its own role-gate framework.
- Runtime docs define `路由输入`, `路由输出`, and `执行纪律选择记录`.
- Validation still fails if runtime guidance reintroduces `gstack` as an execution style.
- Spec-to-code map records the supersession of old role-gate requirements.

## Risks

- Over-correction could weaken QA, release, or Git checks. The implementation must preserve phase gates while changing their source framing.
- Tests that search for exact Chinese wording can become brittle. Use narrow banned phrases and stable required layer labels.
- Historical OpenSpec files intentionally mention the old framing; validation should distinguish historical contract context from current runtime guidance.

## Rollout Strategy

Add or update routing tests first so they fail against the current role-gate framing. Then update runtime docs, skills, and validation. Finally update the old OpenSpec map to record supersession and run targeted routing tests plus full pack validation.

## Open Questions

无。
