# Negative Test Matrix: [change-id]

Path: `.superspecflow/qa/[change-id]/negative-test-matrix.md`

Fill guidance: map every MUST NOT requirement to a concrete guard; blocker is yes when release must stop on failure.
Example: `SSF-EXAMPLE-N1 | unauthenticated write succeeds | authz regression | request returns 401 and no row is written | yes`.

| MUST NOT ID | Forbidden Behavior | Test | Expected Failure / Guard | Blocker |
|---|---|---|---|---|
