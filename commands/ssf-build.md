Use the `ssf-build` skill.

Argument: $ARGUMENTS

Implement from OpenSpec only:
1. Read the relevant change.
2. Generate `.superspecflow/engineering/<change-id>/implementation-plan.md` for host runtime work, or `engineering/<change-id>/` only when working inside the SuperSpecFlow pack source.
   - The plan must include Goal, Architecture, Spec Contract, Tech Stack, Scope Check, File Structure, Bite-Sized Tasks, Plan Review Loop, and Execution Handoff.
   - Each task must include Step 1: 写失败测试, Expected: FAIL with, Step 3: 写最小实现, Expected: PASS, and `/ssf-commit [change-id]` handoff.
3. Generate/update `.superspecflow/maps/<change-id>/spec-to-code-map.md`; in the SuperSpecFlow pack source, keep the committable delivery map at `engineering/<change-id>/spec-to-code-map.md`.
4. Prefer failing tests first.
5. Implement minimal code.
6. Run tests.
7. Update tasks.md.
8. Produce `.superspecflow/engineering/<change-id>/dev-handoff.md`.
9. For Spec cluster work, read `.superspecflow/clusters/<parent-change>/cluster-plan.md` and update `cluster-status.md`.
