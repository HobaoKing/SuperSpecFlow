# Spec: layer-boundary

## ADDED Requirements

### Requirement: SSF-LAYER-001 OpenSpec is the contract layer

Runtime guidance MUST describe OpenSpec as the source of change contracts and traceability.

#### Scenario: Agent reads workflow overview
- GIVEN an agent reads README, root instructions, or centralized routing
- WHEN the workflow sources are listed
- THEN OpenSpec is framed as `OpenSpec 合同层`
- AND the description mentions change-id, Spec ID, requirements or tasks, archive or traceability

### Requirement: SSF-LAYER-002 Superpowers is the execution discipline layer

Runtime guidance MUST describe Superpowers as the execution discipline layer for understanding, planning, TDD, debugging, review handling, and verification-before-completion.

#### Scenario: Agent reads workflow overview
- GIVEN an agent reads README, root instructions, or centralized routing
- WHEN the workflow sources are listed
- THEN Superpowers is framed as `Superpowers 执行纪律层`
- AND the description mentions planning, TDD, review discipline, or verification

### Requirement: SSF-LAYER-003 SuperSpecFlow is the routing and adapter layer

Runtime guidance MUST describe SuperSpecFlow as the routing/glue/adapter layer that composes OpenSpec contracts with Superpowers execution discipline.

#### Scenario: Agent reads workflow overview
- GIVEN an agent reads README, root instructions, or centralized routing
- WHEN the workflow sources are listed
- THEN SuperSpecFlow is framed as `SuperSpecFlow 路由与适配层`
- AND the description says it routes natural-language requests or connects stage artifacts
- AND it does not present SuperSpecFlow as a proprietary role-gate framework

### Requirement: SSF-LAYER-004 Agent roles remain stage perspectives

The system MUST allow `agents/` persona files and stage checks, but MUST describe them as stage perspectives or focused prompts rather than a SuperSpecFlow-owned role-gate architecture.

#### Scenario: User reads repository structure
- GIVEN a user reads README or installation docs
- WHEN `agents/` is described
- THEN the text says they are stage personas, focused prompts, or perspectives
- AND it does not say they define a proprietary SuperSpecFlow role-gate framework

### Requirement: SSF-LAYER-005 Validation enforces the layer boundary

Pack validation and routing tests MUST reject old SuperSpecFlow-owned role-gate framing and require the new layer labels.

#### Scenario: Runtime file reintroduces SuperSpecFlow role-gate framing
- GIVEN a runtime guidance file contains `SuperSpecFlow 角色门禁`
- WHEN routing tests or pack validation run
- THEN validation fails

#### Scenario: Runtime overview omits layer labels
- GIVEN README or centralized routing omits `OpenSpec 合同层`, `Superpowers 执行纪律层`, or `SuperSpecFlow 路由与适配层`
- WHEN routing tests or pack validation run
- THEN validation fails

#### Scenario: Historical OpenSpec mentions superseded terms
- GIVEN an old OpenSpec file documents `SuperSpecFlow 角色门禁`
- WHEN routing tests or pack validation run
- THEN validation does not fail solely because historical contract context mentions the old phrase

### Requirement: SSF-LAYER-006 Gstack attribution boundary remains enforced

The system MUST continue to ban runtime guidance that presents `gstack` as an execution style while allowing source attribution in source notes.

#### Scenario: Runtime file reintroduces gstack execution style
- GIVEN a runtime guidance file contains `gstack 风格`
- WHEN pack validation runs
- THEN validation fails

#### Scenario: Source attribution mentions gstack
- GIVEN `NOTICE.md` or the README design-source section mentions gstack
- WHEN pack validation runs
- THEN validation passes

### Requirement: SSF-LAYER-007 Routing contract defines input and output

Runtime guidance MUST define the SuperSpecFlow routing contract with explicit routing input and routing output.

#### Scenario: Agent makes an intake decision
- GIVEN an agent reads README or centralized routing
- WHEN it needs to classify a user request
- THEN the docs define `路由输入`
- AND the docs define `路由输出`
- AND the routing output includes request classification, next stage, OpenSpec contract need, Superpowers discipline selection, and artifact read/write targets

### Requirement: SSF-LAYER-008 Superpowers discipline selection is traceable

The system MUST record selected Superpowers execution discipline in stage artifacts for formal changes.

#### Scenario: Formal change uses Superpowers discipline
- GIVEN a request enters a formal OpenSpec change
- WHEN the agent chooses brainstorming, writing-plans, TDD, review handling, verification, QA, or progress handoff discipline
- THEN the selected discipline is recorded in stage artifacts such as brainstorming context, implementation plan, TDD evidence, review notes, verification evidence, QA signoff, spec-to-code map, or progress handoff
- AND those records reference OpenSpec change-id / Spec ID without replacing OpenSpec requirements

## MODIFIED Requirements

### Requirement: SSF-ROLE-GATE-001 is superseded

`SSF-ROLE-GATE-001` from `own-role-gates-remove-gstack-style` is superseded by `SSF-LAYER-003`. Runtime guidance MUST no longer require `SuperSpecFlow 角色门禁`.

### Requirement: SSF-ROLE-GATE-N2 is superseded

`SSF-ROLE-GATE-N2` from `own-role-gates-remove-gstack-style` is superseded by `SSF-LAYER-N2`. Removing proprietary role-gate framing is required when OpenSpec contract discipline, Superpowers execution discipline, and phase checks remain intact.

## REMOVED Requirements

无。

## MUST NOT

- SSF-LAYER-N1 Runtime guidance MUST NOT contain `SuperSpecFlow 角色门禁`, `项目自有角色做门禁`, `项目自有门禁`, `SuperSpecFlow 的门禁`, `SuperSpecFlow 负责流程门禁`, or `SuperSpecFlow 产品三重门禁`.
- SSF-LAYER-N2 The change MUST NOT remove or weaken OpenSpec change-id, Spec ID, QA, release, Git, rollback, or verification checks.
- SSF-LAYER-N3 Runtime guidance MUST NOT reintroduce `gstack` execution-style wording.

## MUST NOT Violation Signals

| MUST NOT | 可观察违规现象 |
|---|---|
| SSF-LAYER-N1 | README, root instructions, routing, skills, commands, agents, or docs describe SuperSpecFlow as a proprietary role-gate framework. |
| SSF-LAYER-N2 | QA, release, Git, rollback, or verification checks disappear while wording is changed. |
| SSF-LAYER-N3 | Runtime files contain `gstack 风格`, `gstack 能力`, `本阶段体现 gstack`, `gstack 的发布门禁`, or `gstack 三重审判`. |
