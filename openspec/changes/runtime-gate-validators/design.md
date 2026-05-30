# Design: runtime-gate-validators

## Architecture Summary

Small Bash validators live under `scripts/` and are exercised by Bats fixtures. `templates/git-hooks/commit-msg` delegates message validation to the canonical script when available.
