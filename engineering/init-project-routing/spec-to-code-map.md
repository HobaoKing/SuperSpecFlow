# Spec to Code Map: init-project-routing

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SSF-INIT-001 | 使用唯一项目初始化命令 | `commands/ssf-init.md`, `README.md`, `AGENTS.md`, `CLAUDE.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `docs/installation.md`, `docs/compatibility.md` | `rtk ./scripts/validate-pack.sh`, 旧初始化命名残留搜索 | Done |
| SSF-INIT-002 | 初始化命令创建项目软链 | `commands/ssf-init.md`, `scripts/install-project-symlinks.sh` | 临时项目烟测 | Done |
| SSF-INIT-003 | 全局安装默认不启用自然语言路由 | `update.sh`, `README.md`, `docs/installation.md`, `docs/compatibility.md` | `rtk bash -n update.sh`, `rtk bash update.sh --help` | Done |
| SSF-INIT-004 | 全局安装提供显式自然语言开关 | `update.sh`, `README.md`, `docs/installation.md`, `docs/compatibility.md` | `rtk bash -n update.sh`, `rtk bash update.sh --help` | Done |
| SSF-INIT-005 | 移除旧初始化命名 | `commands/ssf-init.md`, command references | 旧初始化命名残留搜索 | Done |
| SSF-INIT-N1 | 不保留旧初始化命令别名 | `commands/` | 旧初始化命名残留搜索 | Done |
| SSF-INIT-N2 | 默认全局安装不创建 `.superspecflow/` | `update.sh` | `rtk bash update.sh --help` | Done |
| SSF-INIT-N3 | 不覆盖宿主项目指令文件 | `commands/ssf-init.md`, `scripts/install-project-symlinks.sh`, `update.sh` | `rtk ./scripts/validate-pack.sh` | Done |
