# Review Consensus: test-infra-portability-hardening

## Scope Reviewed

Test helper cleanup, root-mutating Bats isolation, and non-default `TMPDIR` CI coverage.

## Consensus

Proceed only with a narrow safety fix: cleanup must follow normalized `TMPDIR` but delete only helper-created `ssf-home.*` and `ssf-proj.*` directories. Root-mutating tests must run in temp repo copies and still exercise real git behavior.

## Required Tests

- Custom `TMPDIR`, trailing slash, spaces in path, cleanup success.
- Refusal for empty path, `/`, `$REPO_ROOT`, outside-temp paths, and non-helper basenames.
- Real repo remains clean after artifact and verification tests.
- CI runs validation and Bats with custom `TMPDIR`.

## Rejected Options

- Broadly trusting any `$TMPDIR` child path.
- Keeping root fixture writes in real `$REPO_ROOT`.
