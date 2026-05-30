# Risk Matrix: [change-id]

Path: `.superspecflow/qa/[change-id]/risk-matrix.md`

Fill guidance: include every release blocker, high-impact unknown, security/data risk, and explicit waiver owner.
Example: `Data loss on retry | persistence | eng lead | 2 | 5 | idempotency key | duplicate-write test | integration regression | none | low | yes`.

| Risk | Area | Owner | Probability | Impact | Mitigation | Detection | Test Strategy | Waiver | Residual Risk | Release Blocker |
|---|---|---|---:|---:|---|---|---|---|---|---|
