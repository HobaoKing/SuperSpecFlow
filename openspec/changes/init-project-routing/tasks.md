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
  - Files: `update.sh`
  - Test: `rtk bash -n update.sh`, `rtk bash update.sh --help`
  - Acceptance: 默认安装提示自然语言未启用；`--enable-natural-language <project>` 调用项目初始化流程。
  - Estimate: 30 min

- [x] T4: 验证项目软链安装命令集合
  - Spec: SSF-INIT-002, SSF-INIT-N1, SSF-INIT-N3
  - Files: `scripts/install-project-symlinks.sh`
  - Test: 临时项目烟测
  - Acceptance: 安装脚本创建 `.superspecflow/` 软链和 `.claude/commands/ssf-init.md`，不创建旧初始化命令文件。
  - Estimate: 15 min
