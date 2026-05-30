# Spec to Code Map: validator-developer-tooling

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SSF-TOOLING-001 | Granular validator diagnostics | `scripts/validate-pack.sh`, `tests/validators/test_validate_pack_diagnostics.bats` | `rtk bats tests/validators/test_validate_pack_diagnostics.bats`; `rtk bash scripts/validate-pack.sh` | Implemented |
| SSF-TOOLING-002 | Focused test runner | `scripts/test.sh`, `tests/smoke/test_recursive_test_runner.bats` | `rtk bats tests/smoke/test_recursive_test_runner.bats`; `rtk bash scripts/test.sh --filter test_version_contract.bats` | Implemented |
| SSF-TOOLING-003 | New change scaffold | `scripts/new-change.sh`, `tests/openspec/test_new_change_scaffold.bats` | `rtk bats tests/openspec/test_new_change_scaffold.bats`; `rtk bash scripts/validate-pack.sh` | Implemented |
