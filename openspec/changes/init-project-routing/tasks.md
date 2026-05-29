# Tasks: init-project-routing

- [x] T1: 增加 `/ssf-init` 命令文件并移除旧命名
  - Spec: SSF-INIT-001, SSF-INIT-002, SSF-INIT-005, SSF-INIT-N1
  - Files: `commands/ssf-init.md`
  - Test: 旧初始化命名残留搜索。
  - Acceptance: 仓库不再包含旧初始化命名，`commands/ssf-init.md` 存在。
  - Estimate: 20 min

- [x] T2: 同步显式命令列表和安装说明
  - Spec: SSF-INIT-001, SSF-INIT-005, SSF-INIT-N1
  - Files: `README.md`, `AGENTS.md`, `CLAUDE.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `docs/installation.md`, `docs/compatibility.md`
  - Test: `rtk ./scripts/validate-pack.sh`
  - Acceptance: README、AGENTS、CLAUDE 与 `commands/` 命令集合一致。
  - Estimate: 25 min

- [x] T3: 增加全局安装自然语言路由开关
  - Spec: SSF-INIT-003, SSF-INIT-004, SSF-INIT-N2, SSF-INIT-N3
  - Files: `update.sh`, `scripts/install-global.sh`, `scripts/uninstall-global.sh`, `scripts/_ssf_init_apply.sh`
  - Test: `rtk bats tests/install/test_install_global.bats`, `rtk bash update.sh --help`
  - Acceptance: 默认安装同步能力文件与 global wrapper 但不启用任意项目；`--enable-natural-language <project>` 调用 zero-touch 初始化流程。
  - Estimate: 30 min

- [x] T4: 验证 zero-touch 项目初始化命令集合
  - Spec: SSF-INIT-002, SSF-INIT-N1, SSF-INIT-N3
  - Files: `commands/ssf-init.md`, `scripts/_ssf_init_apply.sh`, `tests/init/test_ssf_init_zero_touch.bats`
  - Test: `rtk bats tests/init/test_ssf_init_zero_touch.bats`
  - Acceptance: `/ssf-init` 创建 `.superspecflow/enabled` 和标准运行产物目录，不创建 routing 软链，不修改宿主指令文件。
  - Estimate: 15 min

- [x] T5: 收敛仓库根指令文件为薄入口并保留 routing 完整契约
  - Spec: SSF-INIT-006, SSF-INIT-N4
  - Files: `AGENTS.md`, `CLAUDE.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `scripts/validate-pack.sh`
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: 根 `AGENTS.md` / `CLAUDE.md` 只引用 `routing/*.routing.md` 并保留本仓库约束，`routing/*.routing.md` 保留完整且一致的路由契约，验证脚本阻止完整路由表或显式命令全集回流到根入口，并阻止 AGENTS / CLAUDE routing 漂移。
  - Estimate: 20 min

- [x] T6: 明确源码契约与运行时产物提交边界
  - Spec: SSF-INIT-007, SSF-INIT-N5, SSF-INIT-N6
  - Files: `.gitignore`, `AGENTS.md`, `CLAUDE.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `README.md`, `docs/installation.md`, `docs/compatibility.md`, `skills/ssf-git/SKILL.md`, `templates/commit-gate.md`, `templates/git-checklist.md`, `templates/git-hooks/commit-msg`, `scripts/validate-pack.sh`, `tests/smoke/test_artifact_policy.bats`
  - Test: `rtk bats tests/smoke/test_artifact_policy.bats`, `rtk bash scripts/validate-pack.sh`
  - Acceptance: SuperSpecFlow 仓库继续跟踪 `openspec/`，不再跟踪 `docs/superpowers/` 等本地 workflow 运行时产物；验证脚本、Git skill、commit gate 和 hook 模板阻止后续提交重新引入这些产物；文档说明宿主项目的 `openspec/` 仍应按项目需求正常提交。
  - Estimate: 25 min
