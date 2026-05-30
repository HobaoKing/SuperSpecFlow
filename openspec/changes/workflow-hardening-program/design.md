# Design: workflow-hardening-program

## Architecture Summary

This parent change is a coordination contract only. It defines child order and dependency boundaries, while implementation lands in child changes.

## Dependency Order

1. Evidence lifecycle and root routing hardening provide the durable semantics.
2. Install portability removes host assumptions that can block adoption.
3. Runtime validators encode the lifecycle semantics in executable scripts.
4. Backlog cleanup applies the lifecycle to existing changes.
5. High-risk release template hardening expands release evidence fields.

## Rollback

Revert the parent and child changes independently. Existing workflow commands remain compatible because new gates are additive or stricter validation around documented behavior.
