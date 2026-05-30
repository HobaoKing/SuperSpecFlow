# Spec to Code Map: test-infra-portability-hardening

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SSF-TEST-INFRA-001 | TMPDIR-backed cleanup | `tests/lib/test_helper.bash` | `tests/smoke/test_scaffold.bats`, `TMPDIR=/tmp/superspecflow\ tmp/ bash scripts/test.sh` | Implemented |
| SSF-TEST-INFRA-002 | Suspicious path refusal | `tests/lib/test_helper.bash` | `tests/smoke/test_scaffold.bats` | Implemented |
| SSF-TEST-INFRA-003 | Root mutation isolation | `tests/lib/test_helper.bash`, `tests/artifacts/test_artifact_path_contract.bats`, `tests/verification/test_cross_agent_verification_contract.bats` | `tests/artifacts/test_artifact_path_contract.bats`, `tests/verification/test_cross_agent_verification_contract.bats` | Implemented |
| SSF-TEST-INFRA-004 | Non-default TMPDIR CI | `.github/workflows/validate.yml` | `TMPDIR=/tmp/superspecflow\ tmp/ bash scripts/test.sh`, `bash scripts/validate-pack.sh` | Implemented |
