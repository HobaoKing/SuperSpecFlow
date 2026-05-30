# Design: evidence-lifecycle-root-routing

## Architecture Summary

The centralized routing files remain the source of truth. Root instruction files become thin includes plus local source-repo constraints. Runtime intake evidence uses `.superspecflow/intake/<change-id>/`, while the package repository tracks durable status in `openspec/change-ledger.md`.

## Validation

`scripts/validate-pack.sh` checks root thinness, intake path declarations, and ledger coverage for every active `openspec/changes/*` directory.
