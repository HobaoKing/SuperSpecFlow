#!/usr/bin/env bash
# SuperSpecFlow 全局安装脚本（方案 C 推荐入口）
# 只做检测 + 提示。绝不擅自改写用户已存在的全局指令文件 / settings.json。

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SKIP_HOOK=0
INSTALL_CLAUDE=1
INSTALL_CODEX=1
TARGET_SELECTED=0

usage() {
  cat <<MSG
Usage: install-global.sh [--claude-only|--codex-only|--both] [--yes] [--no-hook]

CLI selection (mutually exclusive):
  --claude-only  Only install include into ~/.claude/CLAUDE.md.
  --codex-only   Only install include into ~/.codex/AGENTS.md.
  --both         Install into both (default).

Other options:
  --yes          Non-interactive mode (current default; reserved for future interactive features).
  --no-hook      Skip Claude Code SessionStart hook setup hint.
  -h, --help     Show this help.
MSG
}

require_single_target() {
  if [ "$TARGET_SELECTED" -eq 1 ]; then
    echo "error: --claude-only / --codex-only / --both are mutually exclusive" >&2
    usage >&2
    exit 2
  fi
  TARGET_SELECTED=1
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --claude-only)
      require_single_target
      INSTALL_CLAUDE=1
      INSTALL_CODEX=0
      shift
      ;;
    --codex-only)
      require_single_target
      INSTALL_CLAUDE=0
      INSTALL_CODEX=1
      shift
      ;;
    --both)
      require_single_target
      INSTALL_CLAUDE=1
      INSTALL_CODEX=1
      shift
      ;;
    --yes) shift ;;
    --no-hook) SKIP_HOOK=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown arg: $1" >&2; usage >&2; exit 1 ;;
  esac
done

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

if [ "$INSTALL_CLAUDE" -eq 1 ]; then
  ensure_include "$HOME/.claude/CLAUDE.md" "routing/CLAUDE.global.md"
fi

if [ "$INSTALL_CODEX" -eq 1 ]; then
  ensure_include "$HOME/.codex/AGENTS.md" "routing/AGENTS.global.md"
fi

if [ "$SKIP_HOOK" -eq 0 ] && [ "$INSTALL_CLAUDE" -eq 1 ]; then
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
