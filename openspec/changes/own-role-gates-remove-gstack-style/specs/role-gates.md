# Spec: role-gates

## Supersession Notice

`clarify-superspecflow-layer-boundary` supersedes the parts of this change that required `SuperSpecFlow 角色门禁` runtime wording. This change remains authoritative for removing runtime `gstack` execution wording and preserving source attribution, but current runtime guidance must use the OpenSpec / Superpowers / SuperSpecFlow layer boundary instead of proprietary role-gate framing.

## ADDED Requirements

### Requirement: SSF-ROLE-GATE-001 Runtime guidance removes gstack role-gate attribution

Runtime instructions MUST remove `gstack` execution attribution from product, spec, engineering, QA, release, Git, archive, and retro review behavior. The previous requirement to describe that behavior as `SuperSpecFlow 角色门禁` is superseded by `SSF-LAYER-003`.

#### Scenario: Agent reads workflow routing
- GIVEN an agent reads `AGENTS.md`, `CLAUDE.md`, or `routing/*.routing.md`
- WHEN it reaches the workflow source list
- THEN role review behavior is not framed as `gstack 风格`
- AND current runtime guidance uses `SuperSpecFlow 路由与适配层`
- AND the text does not recommend `gstack 风格`

#### Scenario: Agent reads a stage skill
- GIVEN an agent reads `skills/ssf-think`, `skills/ssf-review`, `skills/ssf-ship`, `skills/ssf-git`, or `skills/ssf-karpathy`
- WHEN the skill describes stage value
- THEN the stage does not present gstack as the execution method
- AND current runtime guidance does not require SuperSpecFlow-owned role-gate wording

### Requirement: SSF-ROLE-GATE-002 Source attribution remains bounded

The system MUST allow gstack attribution only in source-attribution contexts, not in runtime execution guidance.

#### Scenario: Source notes mention influences
- GIVEN a maintainer reads `NOTICE.md` or the README design-source section
- WHEN gstack is mentioned
- THEN it is clearly attribution
- AND it is not phrased as an agent execution rule

### Requirement: SSF-ROLE-GATE-003 Validation enforces the attribution boundary

Pack validation MUST fail if execution-layer files reintroduce gstack as a recommended style.

#### Scenario: Runtime file reintroduces gstack style
- GIVEN a runtime file contains `gstack 风格`
- WHEN `rtk bash scripts/validate-pack.sh` runs
- THEN validation fails

#### Scenario: Attribution file mentions gstack
- GIVEN `NOTICE.md` mentions gstack as a source influence
- WHEN validation runs
- THEN validation passes

## MODIFIED Requirements

无。

## REMOVED Requirements

无。

## MUST NOT

- SSF-ROLE-GATE-N1 Runtime instructions MUST NOT use `gstack 风格`, `gstack 能力`, `本阶段体现 gstack`, `gstack 的发布门禁`, or `gstack 三重审判`.
- SSF-ROLE-GATE-N2 Superseded by `SSF-LAYER-N2`: removing proprietary SuperSpecFlow role-gate wording is allowed and required when OpenSpec contract discipline, Superpowers execution discipline, and phase checks remain intact.

## MUST NOT Violation Signals

| MUST NOT | 可观察违规现象 |
|---|---|
| SSF-ROLE-GATE-N1 | `AGENTS.md`, `CLAUDE.md`, `routing/`, `skills/`, `commands/`, or `agents/` contains gstack execution wording. |
| SSF-ROLE-GATE-N2 | OpenSpec contract discipline, Superpowers execution discipline, QA, release, or Git checks are weakened while wording is changed. |
