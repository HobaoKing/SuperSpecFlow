# Spec to Code Map: install-discoverability-onboarding

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SSF-ONBOARD-001 | 全局安装脚本结尾引导重启与 `/ssf-init` | `scripts/install-global.sh` | `tests/install/test_install_global.bats` | Implemented |
| SSF-ONBOARD-002 | 项目 opt-in 脚本输出去鸡生蛋、提示新会话 | `scripts/_ssf_init_apply.sh` | `tests/init/test_ssf_init_apply_onboarding.bats` | Implemented |
| SSF-ONBOARD-003 | 安装文档说明可发现性/入口层次/备用路径 | `README.md`, `docs/installation.md` | `tests/docs/test_install_onboarding.bats` | Implemented |
| SSF-ONBOARD-004 | `ssf-init.md` 安装顺序修正 | `commands/ssf-init.md` | `tests/docs/test_install_onboarding.bats` | Implemented |
| SSF-ONBOARD-005 | Codex-only 路径不暗示未装的 Claude 命令可用 | `docs/installation.md`, `scripts/install-global.sh` | `tests/docs/test_install_onboarding.bats`, `tests/install/test_install_global.bats` | Implemented |
| SSF-ONBOARD-006 | 全局安装提示检查同名跳过 | `scripts/install-global.sh` | `tests/install/test_install_global.bats` | Implemented |
