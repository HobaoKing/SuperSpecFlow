# Spec: role-gates

## ADDED Requirements

### Requirement: SSF-ROLE-GATE-001 Runtime guidance uses SuperSpecFlow role gates

Runtime instructions MUST describe product, spec, engineering, QA, release, Git, archive, and retro review behavior as SuperSpecFlow-owned role gates.

#### Scenario: Agent reads workflow routing
- GIVEN an agent reads `AGENTS.md`, `CLAUDE.md`, or `routing/*.routing.md`
- WHEN it reaches the workflow source list
- THEN role review behavior is framed as `SuperSpecFlow 角色门禁`
- AND the text does not recommend `gstack 风格`

#### Scenario: Agent reads a stage skill
- GIVEN an agent reads `skills/ssf-think`, `skills/ssf-review`, `skills/ssf-ship`, `skills/ssf-git`, or `skills/ssf-karpathy`
- WHEN the skill describes stage value
- THEN the stage uses SuperSpecFlow-owned gate wording
- AND does not present gstack as the execution method

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
- SSF-ROLE-GATE-N2 The change MUST NOT remove SuperSpecFlow role gates or weaken product, review, QA, release, or Git gates.

## MUST NOT Violation Signals

| MUST NOT | 可观察违规现象 |
|---|---|
| SSF-ROLE-GATE-N1 | `AGENTS.md`, `CLAUDE.md`, `routing/`, `skills/`, `commands/`, or `agents/` contains gstack execution wording. |
| SSF-ROLE-GATE-N2 | Role checks are removed instead of renamed to SuperSpecFlow role gates. |
