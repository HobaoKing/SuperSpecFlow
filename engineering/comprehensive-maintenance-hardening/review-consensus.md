# Review Consensus: comprehensive-maintenance-hardening

## Scope Reviewed

Initial implementation structure for all requested maintenance fixes.

## Reviewers

- Reviewer A: APPROVE if the change is batch-scoped and records split rationale.
- Reviewer B: CHANGES_REQUESTED; require parent/child split and no raw routing symlink.
- Reviewer C: CHANGES_REQUESTED; require split or parent with child slices and explicit 3-agent review gate.

## Consensus

Use a parent change plus four child changes. Do not use raw symlinks for routing canonicalization. Record three-agent review consensus before each child implementation batch. Use TDD for behavior changes and keep Bash 3.2 compatibility.

## Rejected Options

- Single unclustered change for all files.
- Raw committed symlink replacing one routing public path.
- Editing implementation files before the parent/child contract exists.

## Required Tests

- Non-default `TMPDIR` Bats run.
- Root mutation isolation checks.
- Routing drift guard.
- Focused test runner and new-change scaffold tests.
- Granular validator diagnostics.
- Template/skill contract checks.
