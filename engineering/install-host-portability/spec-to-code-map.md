# Spec to Code Map: install-host-portability

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SSF-PORTABILITY-001 | Deterministic installed init | `scripts/install-global.sh`, `scripts/uninstall-global.sh`, `commands/ssf-init.md` | `tests/install/test_host_portability_contract.bats`, `tests/install/test_install_global.bats` | Implemented |
| SSF-PORTABILITY-002 | Portable reviewer prompt fallback | `skills/ssf-think/SKILL.md`, `skills/ssf-spec/SKILL.md`, `skills/ssf-build/SKILL.md` | `tests/install/test_host_portability_contract.bats`, `tests/workflow/test_spec_discipline_contract.bats`, `tests/workflow/test_implementation_plan_contract.bats` | Implemented |

## MUST NOT 覆盖

| MUST NOT ID | Guard | Tests |
|---|---|---|
| SSF-PORTABILITY-N1 | No fixed Claude plugin cache path in runtime skills | `tests/install/test_host_portability_contract.bats`, `scripts/validate-pack.sh` |
