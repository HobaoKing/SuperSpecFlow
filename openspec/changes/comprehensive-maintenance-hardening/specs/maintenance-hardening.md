# Spec: comprehensive maintenance hardening

### Requirement: SSF-MAINT-001 Parent child split

The system MUST represent the full maintenance program as a parent change with bounded child changes.

#### Scenario: maintainer reviews scope
- GIVEN the requested fixes span test infrastructure, routing/docs, validator tooling, and skill/template text
- WHEN the OpenSpec contracts are reviewed
- THEN a parent change lists each child change and its boundary.

### Requirement: SSF-MAINT-002 Three-agent review gate

The system MUST record three-agent review consensus before each implementation batch changes files.

#### Scenario: agent starts a child batch
- GIVEN a child batch is about to edit files
- WHEN the batch scope is ready
- THEN three subagents review the scope in parallel
- AND the final edit plan uses only the non-conflicting consensus.

### Requirement: SSF-MAINT-003 Test infrastructure child

The parent MUST include a child change for portable and isolated tests.

#### Scenario: tests run in custom temp roots
- GIVEN `TMPDIR` points outside `/tmp/ssf-*`
- WHEN `scripts/test.sh` runs
- THEN helper cleanup accepts only helper-created `ssf-home.*` and `ssf-proj.*` directories under the normalized temp root.

### Requirement: SSF-MAINT-004 Routing and docs drift child

The parent MUST include a child change for routing/docs/status drift.

#### Scenario: routing files are maintained
- GIVEN `routing/AGENTS.routing.md` and `routing/CLAUDE.routing.md` expose public host-specific paths
- WHEN routing text changes
- THEN validation prevents silent drift without relying on raw symlinks.

### Requirement: SSF-MAINT-005 Validator and developer tooling child

The parent MUST include a child change for validator diagnostics and developer tooling.

#### Scenario: developer uses local tooling
- GIVEN a maintainer wants focused tests or a new change scaffold
- WHEN they use the supported scripts
- THEN the scripts provide deterministic output and clear failures.

### Requirement: SSF-MAINT-006 Template and skill usability child

The parent MUST include a child change for template and skill usability.

#### Scenario: agent uses templates and skills
- GIVEN an agent reads a skeletal template or phase skill
- WHEN it produces stage artifacts
- THEN the artifact has enough local guidance to avoid basic omissions without weakening gates.

### Requirement: SSF-MAINT-007 Completion evidence

The system MUST verify the parent only after every child has matching tests and evidence.

#### Scenario: maintainer completes parent
- GIVEN all child changes are marked complete
- WHEN the parent is marked complete
- THEN validation evidence covers every explicit requirement.
