# Technical Design: clarify-superspecflow-layer-boundary

## Architecture Summary

This change replaces role-gate ownership language with a layer boundary:

- `OpenSpec 合同层`: owns change-id, Spec ID, requirements, scenarios, tasks, archive, and traceability.
- `Superpowers 执行纪律层`: owns brainstorming, planning, TDD, systematic debugging, review handling, and verification-before-completion discipline.
- `SuperSpecFlow 路由与适配层`: owns intake routing, slash command glue, artifact path conventions, and adapters that connect OpenSpec contracts to Superpowers execution workflows.

Stage checks remain, but they are described as workflow phase checks. Agent role files remain stage personas, not an independent SuperSpecFlow role-gate framework.

## Data Flow

No application data flow changes.

Workflow framing changes:

```text
Natural language request
  -> SuperSpecFlow Intake / routing adapter
  -> OpenSpec contract when behavior changes
  -> Superpowers execution discipline during think/spec/build/review/verify
  -> QA / ship / Git checks that cite contract, evidence, and rollback context
```

## Routing Contract

SuperSpecFlow routing decisions have explicit input and output:

- `路由输入`: user natural language, explicit `/ssf-*` command, existing change-id / Spec ID, host project context, risk level, available evidence, and current Git / runtime state.
- `路由输出`: request classification, next stage, OpenSpec contract need, selected Superpowers execution discipline, and stage artifacts to read or write.
- `执行纪律选择记录`: formal changes record the chosen Superpowers discipline in artifacts such as brainstorming context, implementation plan, TDD evidence, review notes, verification evidence, QA signoff, spec-to-code map, or progress handoff. Those records cite OpenSpec change-id / Spec ID but do not replace OpenSpec requirements.

## Interface Changes

- README and routing layer descriptions change from `SuperSpecFlow 角色门禁` to `SuperSpecFlow 路由与适配层`.
- Stage tables use `SuperSpecFlow 路由与适配职责` instead of `SuperSpecFlow 角色门禁`.
- `skills/ssf-*` text says phases execute checks using OpenSpec/Superpowers evidence rather than project-owned role gates.
- `agents/` remain persona prompts, but docs describe them as focused stage viewpoints.
- Pack validation requires the new layer labels and rejects old role-gate framing in runtime docs.

## Validation Boundary

Runtime guidance includes:

- `README.md`
- `AGENTS.md`, `CLAUDE.md`
- `routing/*.routing.md`, `routing/*.global.md`
- `skills/**/*.md`
- `commands/*.md`
- `agents/*.md`
- `templates/integration/*.md`
- `docs/installation.md`, `docs/compatibility.md`

Historical OpenSpec files may mention superseded terms only when documenting the old change or the new supersession.

## Required Runtime Labels

Runtime overview documents must contain:

- `OpenSpec 合同层`
- `Superpowers 执行纪律层`
- `SuperSpecFlow 路由与适配层`
- `路由输入`
- `路由输出`
- `执行纪律选择记录`

## Banned Runtime Framing

Runtime guidance must not contain:

- `SuperSpecFlow 角色门禁`
- `项目自有角色做门禁`
- `项目自有门禁`
- `SuperSpecFlow 的门禁`
- `SuperSpecFlow 负责流程门禁`
- `SuperSpecFlow 产品三重门禁`
- wording that says SuperSpecFlow defines its own product/spec/engineering/QA/release/Git role-gate framework

Existing gstack execution-style bans remain unchanged.

## Supersession

`own-role-gates-remove-gstack-style` remains historically accurate for removing gstack execution wording, but this change supersedes the parts that required SuperSpecFlow-owned role-gate language:

- `SSF-ROLE-GATE-001` is superseded by `SSF-LAYER-003`.
- `SSF-ROLE-GATE-N2` is superseded by `SSF-LAYER-N2`.

## Security / Permission Considerations

No secrets, permissions, or production behavior are affected.

## Failure Modes

- Validation is too broad and rejects historical OpenSpec context.
- Validation is too narrow and allows runtime docs to reintroduce custom role-gate framing.
- Wording changes accidentally remove QA, release, or Git checks. Tests and review must verify phase checks remain present.

## Observability

Targeted evidence:

- `rtk bats tests/routing/test_role_gate_source_boundary.bats`
- `rtk bash scripts/validate-pack.sh`
- `rtk rg -n "SuperSpecFlow 角色门禁|项目自有角色做门禁|项目自有门禁" README.md AGENTS.md CLAUDE.md routing skills commands agents docs`

## Rollback Plan

Revert the wording, tests, and validation changes. This would restore the previous role-gate framing, so rollback should only be used if the new layer-boundary wording breaks routing or installation documentation.

## Alternatives Considered

- Lightweight wording-only fix: rejected because tests and validation currently require the wrong phrase.
- Reopen and rewrite `own-role-gates-remove-gstack-style`: rejected because that change solved a distinct gstack attribution problem and should remain auditable.
- Remove all stage gates: rejected because the user wants OpenSpec and Superpowers integration strengthened, not process checks weakened.
