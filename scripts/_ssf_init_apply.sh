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

for sub in engineering qa release archive retro decisions maps reviews karpathy progress verification; do
  mkdir -p "$project/.superspecflow/$sub"
done

# progress/ 必须保持空（结构由后续 progress-tracking change 定义）。
# 不写 .gitkeep、不写 README，避免与未来 change 冲突。

# 显式打印只读提示；不修改任何宿主指令文件。
cat <<MSG
SuperSpecFlow 项目 opt-in 已生效：$project/.superspecflow/enabled

下一步（仅在尚未做过全局安装时）：
  bash <pack>/scripts/install-global.sh

如果你只想给本项目使用而不做全局安装，可手动在 $project/CLAUDE.md 中加入：
  @<pack>/routing/CLAUDE.routing.md
或在 $project/AGENTS.md 中加入：
  @<pack>/routing/AGENTS.routing.md
（这一行为可选；不加也不影响 /ssf-* 显式命令）
MSG
