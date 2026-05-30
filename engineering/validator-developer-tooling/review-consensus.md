# Review Consensus: validator-developer-tooling

## Scope Reviewed

`validate-pack.sh` diagnostics, `scripts/test.sh` focused selection, and `scripts/new-change.sh` scaffolding.

## Reviewers

- Sartre: CHANGES_REQUESTED; require ledger-ready scaffold, explicit filter semantics, and negative fixture diagnostics.
- Jason: CHANGES_REQUESTED; require active ledger row behavior, fixture-based multi-failure validator tests, and Bash 3.2 guardrails.
- Russell: CHANGES_REQUESTED; require ledger update, explicit bad-path/no-match runner behavior, and multi-marker validator regression tests.

## Consensus

Proceed with TDD. Preserve existing full-suite behavior and aggregate validator failure behavior. Keep shell code Bash 3.2 compatible. Scaffold must not overwrite existing changes or create runtime/cache artifacts. `scripts/new-change.sh` must create a validate-ready active ledger row. `scripts/test.sh --filter` is fixed-substring matching; filters and file args are a de-duplicated union; bad paths, non-`.bats` paths, and no matches exit 1.

## Required Tests

- `scripts/test.sh --list`, file args, `--filter`, no matches, bad file paths.
- `scripts/new-change.sh` valid scaffold, invalid ID, existing change refusal.
- Representative validator diagnostics name exact missing predicate.
