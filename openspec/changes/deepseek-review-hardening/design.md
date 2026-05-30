# Design: deepseek-review-hardening

## Architecture Summary

This change keeps fixes close to the affected contracts. `scripts/validate-pack.sh` continues to own pack-level structural validation. Command contracts are checked with bats fixtures. GitHub Actions becomes the CI entry point for validation, bats, and shellcheck. Historical evidence gaps are represented honestly in `openspec/change-ledger.md` by using `complete` for implemented contracts and retaining notes where durable final evidence is absent.

## Verification Strategy

- Targeted bats tests prove each review item has a durable guard.
- `scripts/validate-pack.sh` enforces portable root files, CI presence, shellcheck gate wiring, and ledger hygiene.
- Full `scripts/test.sh` remains the package regression entry point.
