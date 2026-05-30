# Technical Design: own-role-gates-remove-gstack-style

## Architecture Summary

The change separates source attribution from runtime guidance. Runtime files describe role checks as `SuperSpecFlow 角色门禁`; source files may still acknowledge gstack as a design influence.

## Data Flow

No runtime data flow changes.

## Interface Changes

- Human-facing wording changes in routing, skills, commands, agents, and README.
- Pack validation gains a source-boundary check for `gstack`.

## Validation Boundary

Runtime files include:

- `AGENTS.md`, `CLAUDE.md`
- `routing/*.routing.md`, `routing/*.global.md`
- `skills/**/*.md`
- `commands/*.md`
- `agents/*.md`
- `templates/integration/*.md`

Allowed source-attribution files:

- `NOTICE.md`
- README design-source section only

Validation should fail on execution phrases:

- `gstack 风格`
- `gstack 能力`
- `本阶段体现 gstack`
- `gstack 的发布门禁`
- `gstack 三重审判`

## Role Gate Language

Use project-owned language:

- `SuperSpecFlow 角色门禁`
- `SuperSpecFlow 产品门禁`
- `SuperSpecFlow 工程审查门禁`
- `SuperSpecFlow 发布门禁`

Existing role viewpoints can remain when clearly framed as SuperSpecFlow gates rather than external gstack guidance.

## Security / Permission Considerations

No secrets, permissions, or production behavior are affected.

## Failure Modes

- Validation too broad: legitimate attribution in `NOTICE.md` or README source section fails.
- Validation too narrow: runtime files can reintroduce gstack recommendations.

## Observability

`rtk bash scripts/validate-pack.sh` and `rtk bats tests/routing/test_role_gate_source_boundary.bats` provide evidence.

## Migration Plan

No data migration required.

## Rollback Plan

Revert the wording and validation changes. Existing workflow behavior remains otherwise unchanged.

## Alternatives Considered

- Remove all gstack mentions everywhere: rejected because source attribution should remain accurate.
- Keep current wording and add clarification: rejected because the user asked to remove the recommended gstack framing.
