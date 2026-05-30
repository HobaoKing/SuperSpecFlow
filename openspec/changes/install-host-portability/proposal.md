# Proposal: install-host-portability

## Summary

Make installed `/ssf-init` deterministic and remove hardcoded Claude Superpowers plugin cache paths from review loops.

## Problem

Installed command files are copied verbatim, so `/ssf-init` relies on an agent finding `<pack>`. Spec and build skills also reference one Claude plugin cache path even though Superpowers is optional and Codex-compatible operation is documented.

## Goals

- Record the pack root during global install.
- Teach `/ssf-init` to use that metadata or `SUPERSPECFLOW_HOME`.
- Replace hardcoded reviewer prompt paths with portable availability checks and explicit waiver evidence.
