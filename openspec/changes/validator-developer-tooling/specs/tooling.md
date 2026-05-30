# Spec: validator and developer tooling

### Requirement: SSF-TOOLING-001 Granular validator diagnostics

Pack validation SHOULD report specific missing predicates instead of one broad failure for long chained checks.

#### Scenario: contract check fails
- GIVEN a checked file misses one required marker
- WHEN `scripts/validate-pack.sh` runs
- THEN the failure message identifies the file and missing marker.

### Requirement: SSF-TOOLING-002 Focused test runner

The test runner MUST support full-suite behavior plus focused selection.

#### Scenario: maintainer runs selected tests
- GIVEN a maintainer passes a `.bats` file or `--filter <pattern>`
- WHEN `scripts/test.sh` runs
- THEN only matching tests are passed to `bats`.

### Requirement: SSF-TOOLING-003 New change scaffold

The repository MUST provide a scaffold script for new OpenSpec changes.

#### Scenario: maintainer creates a change
- GIVEN a valid `<change-id>`
- WHEN `scripts/new-change.sh <change-id>` runs
- THEN proposal, design, tasks, specs, and engineering map skeletons are created without overwriting existing changes.
