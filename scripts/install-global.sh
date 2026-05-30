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

file_checksum() {
  shasum -a 256 "$1" | awk '{print $1}'
}

dir_checksum() {
  local dir="$1"
  local file rel

  (
    cd "$dir"
    find . -type f ! -name '.superspecflow-installed' -print | LC_ALL=C sort | while IFS= read -r file; do
      rel="${file#./}"
      printf '%s\n' "$rel"
      shasum -a 256 "$rel"
    done
  ) | shasum -a 256 | awk '{print $1}'
}

manifest_has_path() {
  local manifest="$1"
  local target="$2"

  [ -f "$manifest" ] || return 1
  awk -F '\t' -v p="$target" '$3 == p { found = 1 } END { exit found ? 0 : 1 }' "$manifest"
}

manifest_checksum_matches() {
  local manifest="$1"
  local kind="$2"
  local checksum="$3"
  local target="$4"

  [ -f "$manifest" ] || return 1
  awk -F '\t' -v k="$kind" -v c="$checksum" -v p="$target" '
    $1 == k && $2 == c && $3 == p { found = 1 }
    END { exit found ? 0 : 1 }
  ' "$manifest"
}

record_manifest() {
  local manifest="$1"
  local kind="$2"
  local checksum="$3"
  local target="$4"

  mkdir -p "$(dirname "$manifest")"
  printf '%s\t%s\t%s\n' "$kind" "$checksum" "$target" >> "$manifest"
}

copy_file_safe() {
  local src="$1"
  local target="$2"
  local manifest="$3"
  local current

  mkdir -p "$(dirname "$target")"
  if [ -e "$target" ]; then
    if [ ! -f "$target" ]; then
      echo "⚠ $target already exists but is not a regular file; skipped"
      return 0
    fi
    current="$(file_checksum "$target")"
    if manifest_has_path "$manifest" "$target"; then
      if ! manifest_checksum_matches "$manifest" "F" "$current" "$target"; then
        echo "⚠ $target was modified after SuperSpecFlow installed it; skipped"
        return 0
      fi
    else
      echo "⚠ $target already exists and was not installed by SuperSpecFlow; skipped"
      return 0
    fi
  fi

  cp "$src" "$target"
  record_manifest "$manifest" "F" "$(file_checksum "$target")" "$target"
}

copy_dir_safe() {
  local src="$1"
  local target="$2"
  local manifest="$3"
  local marker="$target/.superspecflow-installed"
  local current

  if [ -e "$target" ]; then
    if [ ! -d "$target" ]; then
      echo "⚠ $target already exists but is not a directory; skipped"
      return 0
    fi
    current="$(dir_checksum "$target")"
    if [ -f "$marker" ] &&
       grep -Fxq "$REPO_ROOT" "$marker" &&
       manifest_checksum_matches "$manifest" "D" "$current" "$target"; then
      rm -rf "$target"
    else
      echo "⚠ $target already exists or was modified after SuperSpecFlow installed it; skipped"
      return 0
    fi
  fi

  mkdir -p "$(dirname "$target")"
  cp -R "$src" "$target"
  printf '%s\n' "$REPO_ROOT" > "$marker"
  record_manifest "$manifest" "D" "$(dir_checksum "$target")" "$target"
}

sync_claude_capabilities() {
  local manifest="$HOME/.claude/superspecflow/install-manifest.tsv"
  local path

  mkdir -p "$HOME/.claude/skills" "$HOME/.claude/agents" "$HOME/.claude/commands"
  for path in "$REPO_ROOT/skills/"ssf-*; do
    copy_dir_safe "$path" "$HOME/.claude/skills/$(basename "$path")" "$manifest"
  done
  for path in "$REPO_ROOT/agents/"*.md; do
    copy_file_safe "$path" "$HOME/.claude/agents/$(basename "$path")" "$manifest"
  done
  for path in "$REPO_ROOT/commands/"ssf-*.md; do
    copy_file_safe "$path" "$HOME/.claude/commands/$(basename "$path")" "$manifest"
  done
  echo "✓ synced Claude Code skills, agents, and commands"
}

sync_codex_capabilities() {
  local manifest="$HOME/.codex/superspecflow/install-manifest.tsv"
  local path

  mkdir -p "$HOME/.codex/skills"
  for path in "$REPO_ROOT/skills/"ssf-*; do
    copy_dir_safe "$path" "$HOME/.codex/skills/$(basename "$path")" "$manifest"
  done
  echo "✓ synced Codex skills"
}

render_wrapper() {
  local template="$1"
  local output="$2"
  local routing_file="$3"

  mkdir -p "$(dirname "$output")"
  sed \
    -e "s#<repo>/routing/${routing_file}#${REPO_ROOT}/routing/${routing_file}#g" \
    -e "s#<repo>#${REPO_ROOT}#g" \
    "$template" > "$output"
}

write_pack_root() {
  local output="$1"

  mkdir -p "$(dirname "$output")"
  printf '%s\n' "$REPO_ROOT" > "$output"
}

ensure_include() {
  local target="$1"          # ~/.claude/CLAUDE.md 或 ~/.codex/AGENTS.md
  local include_line="$2"    # 已生成 wrapper 的绝对路径 include

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
  sync_claude_capabilities
  write_pack_root "$HOME/.claude/superspecflow/pack-root"
  render_wrapper \
    "$REPO_ROOT/routing/CLAUDE.global.md" \
    "$HOME/.claude/superspecflow/CLAUDE.global.md" \
    "CLAUDE.routing.md"
  ensure_include "$HOME/.claude/CLAUDE.md" "@$HOME/.claude/superspecflow/CLAUDE.global.md"
fi

if [ "$INSTALL_CODEX" -eq 1 ]; then
  sync_codex_capabilities
  write_pack_root "$HOME/.codex/superspecflow/pack-root"
  render_wrapper \
    "$REPO_ROOT/routing/AGENTS.global.md" \
    "$HOME/.codex/superspecflow/AGENTS.global.md" \
    "AGENTS.routing.md"
  ensure_include "$HOME/.codex/AGENTS.md" "@$HOME/.codex/superspecflow/AGENTS.global.md"
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
