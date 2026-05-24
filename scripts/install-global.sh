#!/usr/bin/env bash
# SuperSpecFlow 全局安装脚本（方案 C 推荐入口）
# 只做检测 + 提示。绝不擅自改写用户已存在的全局指令文件 / settings.json。

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ASSUME_YES=0
SKIP_HOOK=0

usage() {
  cat <<MSG
Usage: install-global.sh [--yes] [--no-hook]

Options:
  --yes      Skip interactive confirmation prompts.
  --no-hook  Skip Claude Code SessionStart hook setup.
MSG
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --yes) ASSUME_YES=1; shift ;;
    --no-hook) SKIP_HOOK=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown arg: $1" >&2; usage >&2; exit 1 ;;
  esac
done

confirm() {
  if [ "$ASSUME_YES" -eq 1 ]; then return 0; fi
  read -r -p "$1 [y/N] " ans
  [ "$ans" = "y" ] || [ "$ans" = "Y" ]
}

ensure_include() {
  local target="$1"          # ~/.claude/CLAUDE.md 或 ~/.codex/AGENTS.md
  local include_path="$2"    # routing/CLAUDE.global.md 或 routing/AGENTS.global.md
  local include_line="@${REPO_ROOT}/${include_path}"

  if [ ! -e "$target" ]; then
    mkdir -p "$(dirname "$target")"
    printf '%s\n' "$include_line" > "$target"
    echo "✓ created $target with SuperSpecFlow include"
    return 0
  fi

  if grep -Fq "$include_line" "$target"; then
    echo "= $target already includes SuperSpecFlow, skipped"
    return 0
  fi

  cat <<MSG

⚠ $target 已存在，但未包含 SuperSpecFlow include 行。
请手动追加（manually append）下面这一行到该文件靠前位置：

  $include_line

脚本不会擅自改写已有的用户全局指令文件。
MSG
  return 0
}

ensure_include "$HOME/.claude/CLAUDE.md" "routing/CLAUDE.global.md"
ensure_include "$HOME/.codex/AGENTS.md" "routing/AGENTS.global.md"

if [ "$SKIP_HOOK" -eq 0 ]; then
  hook_path="${REPO_ROOT}/scripts/hooks/session-start-detect.sh"
  cat <<MSG

—— 可选：Claude Code SessionStart hook ——
建议在 ~/.claude/settings.json 中合并以下片段（使用 Claude Code 官方 hook schema），
让会话启动时自动检测项目 opt-in：

{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {"type": "command", "command": "${hook_path}"}
        ]
      }
    ]
  }
}

脚本不会擅自改写 settings.json。若该文件不存在，可直接创建并仅包含上述内容。
MSG
fi

echo
echo "Done."
exit 0
