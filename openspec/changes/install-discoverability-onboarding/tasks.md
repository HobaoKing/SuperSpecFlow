# Tasks: install-discoverability-onboarding

- [x] T1: 写失败测试承接 onboarding 契约
  - Spec: SSF-ONBOARD-001, SSF-ONBOARD-002, SSF-ONBOARD-003, SSF-ONBOARD-004, SSF-ONBOARD-005, SSF-ONBOARD-006
  - Files: `tests/install/test_install_global.bats`, `tests/init/test_ssf_init_apply_onboarding.bats`, `tests/docs/test_install_onboarding.bats`
  - Test: `rtk bats tests/install/test_install_global.bats tests/init/test_ssf_init_apply_onboarding.bats tests/docs/test_install_onboarding.bats`
  - Acceptance: 新增断言先全部失败（红），断言精确指向 SSF-ONBOARD 行为，不依赖真实 `$HOME` 副作用。

- [x] T2: install-global.sh 结尾重启 + /ssf-init 引导 + skipped 提示
  - Spec: SSF-ONBOARD-001, SSF-ONBOARD-006
  - Files: `scripts/install-global.sh`
  - Test: `rtk bats tests/install/test_install_global.bats`
  - Acceptance: 成功结尾输出含重启会话、运行 `/ssf-init`、留意 skipped 警告；措辞为建议性，不断言 commands 强制重启。

- [x] T3: _ssf_init_apply.sh 输出修正
  - Spec: SSF-ONBOARD-002
  - Files: `scripts/_ssf_init_apply.sh`
  - Test: `rtk bats tests/init/test_ssf_init_apply_onboarding.bats`
  - Acceptance: 输出无鸡生蛋前置措辞、无"不加也不影响 `/ssf-*` 显式命令"，含 opt-in 后需新会话提示。

- [x] T4: README + installation.md 可发现性/入口层次/备用路径
  - Spec: SSF-ONBOARD-003, SSF-ONBOARD-005
  - Files: `README.md`, `docs/installation.md`
  - Test: `rtk bats tests/docs/test_install_onboarding.bats`; `rtk bash scripts/validate-pack.sh`
  - Acceptance: 文档含重启/可发现性/入口层次/终端备用路径；Codex-only 段事实修正；README 不恢复大段说明。

- [x] T5: commands/ssf-init.md 安装顺序修正
  - Spec: SSF-ONBOARD-004
  - Files: `commands/ssf-init.md`
  - Test: `rtk bats tests/docs/test_install_onboarding.bats`
  - Acceptance: 推荐顺序为 `install-global.sh` → 重启 → `/ssf-init`。

- [x] T6: 全量验证 + 证据更新
  - Spec: SSF-ONBOARD-001, SSF-ONBOARD-002, SSF-ONBOARD-003, SSF-ONBOARD-004, SSF-ONBOARD-005, SSF-ONBOARD-006
  - Files: `openspec/change-ledger.md`, `engineering/install-discoverability-onboarding/spec-to-code-map.md`
  - Test: `rtk bash scripts/test.sh`; `rtk bash scripts/validate-pack.sh`
  - Acceptance: 全量 bats + pack validation 通过；ledger evidence 与 spec-to-code map 更新为实际实现状态。
