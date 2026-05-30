# Spec: host portability

## ADDED Requirements

### Requirement: SSF-PORTABILITY-001 Deterministic installed init

The system MUST make installed `/ssf-init` able to locate the SuperSpecFlow pack root without guessing.

#### Scenario: command is installed globally
- GIVEN `install-global.sh` has run
- WHEN an agent executes `/ssf-init`
- THEN the command can find a recorded `pack-root` path or `SUPERSPECFLOW_HOME`.

### Requirement: SSF-PORTABILITY-002 Portable reviewer prompt fallback

The system MUST NOT depend on a single Claude Superpowers plugin cache path for spec or plan review.

#### Scenario: reviewer prompt is unavailable
- GIVEN the host lacks the Claude Superpowers plugin cache
- WHEN spec or build review would use a prompt
- THEN the agent records `Reviewer prompt unavailable` and waiver evidence instead of silently failing.

## MUST NOT

- SSF-PORTABILITY-N1 Runtime skills MUST NOT hardcode `claude-plugins-official/superpowers/5.0.5`.
