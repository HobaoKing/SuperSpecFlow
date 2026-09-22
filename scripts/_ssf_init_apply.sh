#!/usr/bin/env bash
# SuperSpecFlow /ssf-init 副作用契约脚本（私有）。
# 由 commands/ssf-init.md 中的步骤直接调用，使 bats 测试可对其行为做契约验证。
# 严禁修改宿主 CLAUDE.md / AGENTS.md。严禁创建 routing 软链。

set -euo pipefail

project="${SSF_INIT_PROJECT_DIR:-$PWD}"

if [ ! -d "$project" ]; then
  echo "error: project directory does not exist: $project" >&2
  exit 1
fi

mkdir -p "$project/.superspecflow"
if [ -e "$project/.superspecflow/enabled" ] && [ ! -f "$project/.superspecflow/enabled" ]; then
  echo "error: $project/.superspecflow/enabled exists but is not a regular file" >&2
  exit 1
fi
: > "$project/.superspecflow/enabled"

# 显式打印只读提示；不修改任何宿主指令文件。
cat <<MSG
SuperSpecFlow 项目 opt-in 已生效：$project/.superspecflow/enabled

提示：
- 轻量自然语言路由已启用；显式 /ssf-init 后更新本会话状态，若宿主未重新读取规则，请新开或重启会话。
- 显式 /ssf-* 命令由全局安装（bash <pack>/scripts/install-global.sh）注册到 Claude Code，重启会话后进入斜杠补全；本脚本只做项目 opt-in，不注册命令。
- 如果只想给本项目启用自然语言路由而不做全局安装，可手动在 $project/CLAUDE.md 加入 @<pack>/routing/CLAUDE.routing.md（或在 $project/AGENTS.md 加入 @<pack>/routing/AGENTS.routing.md）。手动 include 只启用自然语言路由主体，不会把 /ssf-* 注册为 Claude Code slash 命令；两者相互独立。
MSG
