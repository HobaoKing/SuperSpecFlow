Use the `ssf-build` skill.

Argument: $ARGUMENTS

Implement from OpenSpec only:
1. Read the relevant change.
2. Generate `.superspecflow/engineering/<change-id>/implementation-plan.md` for host runtime work, or `engineering/<change-id>/` only when working inside the SuperSpecFlow pack source.
3. Generate/update `.superspecflow/maps/<change-id>/spec-to-code-map.md`; in the SuperSpecFlow pack source, keep the committable delivery map at `engineering/<change-id>/spec-to-code-map.md`.
4. Prefer failing tests first.
5. Implement minimal code.
6. Run tests.
7. Update tasks.md.
8. Produce `.superspecflow/engineering/<change-id>/dev-handoff.md`.
