# Spec: template and skill usability polish

### Requirement: SSF-USABILITY-001 Skeletal template guidance

Skeletal templates MUST include enough local guidance for an agent to fill them without reading unrelated files.

#### Scenario: agent opens a template
- GIVEN a template has only headings or table columns
- WHEN an agent reads it
- THEN it includes short fill guidance or example structure.

### Requirement: SSF-USABILITY-002 Build skill cross-reference

`ssf-build` MUST reduce duplicated Karpathy/Git detail without weakening build gates.

#### Scenario: agent reads build skill
- GIVEN build requires coding discipline and git handoff
- WHEN `ssf-build` references related skills
- THEN it still states mandatory local gates and where detailed discipline lives.

### Requirement: SSF-USABILITY-003 Retro probing questions

`ssf-retro` MUST include probing questions that expose process weaknesses.

#### Scenario: agent runs retro
- GIVEN a completed change
- WHEN the retro is written
- THEN it asks targeted questions about evidence, gates, scope, and agent handoff quality.

### Requirement: SSF-USABILITY-004 Archive continuation consistency

`ssf-archive` MUST include an automatic continuation heading consistent with other phase skills.

#### Scenario: archive completes
- GIVEN archive artifacts are written
- WHEN the agent reaches the continuation step
- THEN the skill points to `/ssf-retro` as the next phase.
