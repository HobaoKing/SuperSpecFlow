# Design: install-host-portability

## Architecture Summary

`install-global.sh` writes `pack-root` metadata next to generated wrappers. `/ssf-init` documents deterministic lookup order: `SUPERSPECFLOW_HOME`, Claude pack-root, Codex pack-root, then local repository discovery.

Reviewer prompt rules become tool-agnostic. If a Superpowers reviewer prompt or agent tool is unavailable, the spec/build readiness artifacts record `Reviewer prompt unavailable` with waiver evidence.
