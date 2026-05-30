# Spec: routing and docs drift reduction

### Requirement: SSF-DRIFT-001 Routing drift guard

The system MUST prevent `routing/AGENTS.routing.md` and `routing/CLAUDE.routing.md` from drifting while preserving both public paths as portable files.

#### Scenario: routing content changes
- GIVEN a maintainer edits routing text
- WHEN validation runs
- THEN validation fails if only one public routing file changed.

### Requirement: SSF-DRIFT-002 README quick install focus

README MUST provide a concise quick install and point detailed installation/uninstall instructions to docs.

#### Scenario: new user reads README
- GIVEN a user wants to install SuperSpecFlow
- WHEN they read the quick access section
- THEN they see the recommended command/path and links to canonical details without a long duplicated install guide.

### Requirement: SSF-DRIFT-003 Legacy symlink appendix

Legacy project symlink installation MUST remain documented as compatibility, not as the main path.

#### Scenario: legacy user needs symlink install
- GIVEN a user already uses project symlinks
- WHEN they read installation docs
- THEN they can find the compatibility path in an appendix or compressed compatibility section.

### Requirement: SSF-DRIFT-004 Workflow-scale status refresh

Workflow-scale evidence MUST describe child changes as implemented when their contract tests exist.

#### Scenario: maintainer reads workflow-scale map
- GIVEN `browser-mcp-qa-adapter` and `parallel-worktree-spec-clusters` are implemented
- WHEN the workflow-scale map is reviewed
- THEN it no longer describes child contract tests as future work.
