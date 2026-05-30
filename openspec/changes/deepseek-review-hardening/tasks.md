# Tasks: deepseek-review-hardening

- [x] T1: Add review hardening contract
  - Spec: SSF-DEEPSEEK-001, SSF-DEEPSEEK-002, SSF-DEEPSEEK-003, SSF-DEEPSEEK-004, SSF-DEEPSEEK-005, SSF-DEEPSEEK-006, SSF-DEEPSEEK-007, SSF-DEEPSEEK-008
  - Files: `openspec/changes/deepseek-review-hardening/*`
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: DeepSeek feedback is mapped to explicit Spec IDs.

- [x] T2: Add failing contract tests
  - Spec: SSF-DEEPSEEK-001..008
  - Files: `tests/review/test_deepseek_review_hardening.bats`
  - Test: `rtk bats tests/review/test_deepseek_review_hardening.bats`
  - Acceptance: Tests fail on the current implementation before fixes.

- [x] T3: Implement script, docs, CI, and ledger fixes
  - Spec: SSF-DEEPSEEK-001..008
  - Files: `scripts/validate-pack.sh`, `AGENTS.md`, `README.md`, `docs/compatibility.md`, `docs/research/`, `.github/workflows/validate.yml`, `openspec/change-ledger.md`
  - Test: `rtk bats tests/review/test_deepseek_review_hardening.bats`, `rtk bash scripts/validate-pack.sh`
  - Acceptance: Targeted review hardening tests pass.

- [x] T4: Verify full package
  - Spec: SSF-DEEPSEEK-001..008
  - Files: `scripts/test.sh`, `scripts/validate-pack.sh`
  - Test: `rtk bash scripts/test.sh`
  - Acceptance: Full regression suite passes.
