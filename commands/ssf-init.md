# /ssf-init

确认当前项目启用轻量路由（全局安装默认开启，无需逐项目执行），不改写宿主 AGENTS.md / CLAUDE.md / GEMINI.md。参数：$ARGUMENTS。

定位包根目录：依次使用 `SUPERSPECFLOW_HOME`、`~/.claude/superspecflow/pack-root`、`~/.codex/superspecflow/pack-root`、`~/.gemini/superspecflow/pack-root`；每条记录都要确认该路径下 `scripts/_ssf_init_apply.sh` 仍存在，旧安装残留的失效记录直接跳过继续往下找。当前目录确为包源码时可直接使用。只有都无法定位时询问安装路径。

执行 `bash "$PACK_ROOT/scripts/_ssf_init_apply.sh"`，确保 `.superspecflow/enabled` 存在并清除可能存在的 `.superspecflow/disabled`。不预建阶段目录、routing 覆盖或 templates 软链，重复执行保留已有资料。

首次使用先运行 `scripts/install-global.sh` 并重启会话（restart），让 Claude 命令进入补全；全局安装默认已在所有项目中开启轻量路由。Codex-only 使用终端运行本脚本确认或恢复启用，不依赖 Claude commands。Antigravity 使用 IDE / CLI 打开项目并重启会话生效，CLI 可直接调用 `/ssf-*` skill。仅项目接入可使用显式 routing include，安装脚本不自动改写已有宿主指令。
