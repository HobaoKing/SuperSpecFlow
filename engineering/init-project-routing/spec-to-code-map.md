# Spec to Code Map: init-project-routing

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SSF-INIT-001 | 使用唯一项目初始化命令 | `commands/ssf-init.md`, `README.md`, `AGENTS.md`, `CLAUDE.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `docs/installation.md`, `docs/compatibility.md` | `rtk ./scripts/validate-pack.sh`, 旧初始化命名残留搜索 | Done |
| SSF-INIT-002 | 初始化命令创建 zero-touch opt-in sentinel | `commands/ssf-init.md`, `scripts/_ssf_init_apply.sh`, `openspec/changes/init-project-routing/specs/routing.md` | `tests/init/test_ssf_init_zero_touch.bats`, `rtk bash scripts/validate-pack.sh` | Done |
| SSF-INIT-003 | 全局安装默认不启用自然语言路由 | `update.sh`, `scripts/install-global.sh`, `scripts/uninstall-global.sh`, `README.md`, `docs/installation.md`, `docs/compatibility.md` | `tests/install/test_install_global.bats`, `rtk bash scripts/validate-pack.sh` | Done |
| SSF-INIT-004 | 全局安装提供显式自然语言开关 | `update.sh`, `scripts/_ssf_init_apply.sh`, `docs/installation.md`, `docs/compatibility.md` | `tests/init/test_ssf_init_zero_touch.bats`, `rtk bash update.sh --help` | Done |
| SSF-INIT-005 | 移除旧初始化命名 | `commands/ssf-init.md`, command references | 旧初始化命名残留搜索 | Done |
| SSF-INIT-006 | 根指令文件保持薄入口 | `AGENTS.md`, `CLAUDE.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `scripts/validate-pack.sh` | `rtk bash scripts/validate-pack.sh`, `tests/init/test_ssf_init_zero_touch.bats` | Done |
| SSF-INIT-007 | 区分源码契约与运行时产物 | `.gitignore`, `scripts/validate-pack.sh`, `docs/installation.md`, `README.md` | `rtk bash scripts/validate-pack.sh`, tracked runtime artifact check | Done |
| SSF-INIT-N1 | 不保留旧初始化命令别名 | `commands/` | 旧初始化命名残留搜索 | Done |
| SSF-INIT-N2 | 默认全局安装不创建 `.superspecflow/` | `update.sh` | `rtk bash update.sh --help` | Done |
| SSF-INIT-N3 | 不覆盖宿主项目指令文件 | `commands/ssf-init.md`, `scripts/install-project-symlinks.sh`, `update.sh` | `rtk ./scripts/validate-pack.sh` | Done |
| SSF-INIT-N4 | 不把完整路由规则复制回仓库根指令文件 | `AGENTS.md`, `CLAUDE.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md` | `rtk bash scripts/validate-pack.sh` | Done |
| SSF-INIT-N5 | 不提交 workflow 运行时、安装副本或缓存产物 | `.gitignore`, `scripts/validate-pack.sh` | `rtk bash scripts/validate-pack.sh` | Done |
| SSF-INIT-N6 | 不把 SuperSpecFlow 仓库 `openspec/` 误判为运行时产物 | `scripts/validate-pack.sh`, `openspec/changes/init-project-routing/specs/routing.md` | `rtk bash scripts/validate-pack.sh` | Done |
