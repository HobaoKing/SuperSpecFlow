#!/usr/bin/env bash
# SuperSpecFlow 全局卸载脚本（与 install-global.sh 对称）
# 只精确移除本仓库写入的 include 行，绝不改动用户在指令文件里的其他内容。

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

REMOVE_CLAUDE=1
REMOVE_CODEX=1
PURGE=0
TARGET_SELECTED=0

usage() {
  cat <<MSG
Usage: uninstall-global.sh [--claude-only|--codex-only|--both] [--purge]

CLI selection (mutually exclusive):
  --claude-only  Only remove include from ~/.claude/CLAUDE.md.
  --codex-only   Only remove include from ~/.codex/AGENTS.md.
  --both         Remove from both (default).

Other options:
  --purge        After removing includes, also delete the pack directory at $REPO_ROOT.
                 拒绝在 pack 目录内部执行。
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
      REMOVE_CLAUDE=1
      REMOVE_CODEX=0
      shift
      ;;
    --codex-only)
      require_single_target
      REMOVE_CLAUDE=0
      REMOVE_CODEX=1
      shift
      ;;
    --both)
      require_single_target
      REMOVE_CLAUDE=1
      REMOVE_CODEX=1
      shift
      ;;
    --purge) PURGE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown arg: $1" >&2; usage >&2; exit 1 ;;
  esac
done

remove_include() {
  local target="$1"          # ~/.claude/CLAUDE.md 或 ~/.codex/AGENTS.md
  local include_line="$2"    # 已生成 wrapper 的绝对路径 include

  if [ ! -e "$target" ]; then
    echo "= $target 不存在，跳过"
    return 0
  fi

  if ! grep -Fxq "$include_line" "$target"; then
    echo "= $target 未包含 SuperSpecFlow include 行，跳过"
    return 0
  fi

  local tmp
  tmp="$(mktemp)"
  # -F 固定字符串，-x 整行匹配，-v 反选；只移除恰好等于 include_line 的行
  grep -Fxv "$include_line" "$target" > "$tmp" || true

  if [ ! -s "$tmp" ]; then
    rm -f "$target" "$tmp"
    echo "✓ 已移除 ${target}（删除 include 后文件为空，整文件已删除）"
  else
    mv "$tmp" "$target"
    echo "✓ 已从 $target 移除 SuperSpecFlow include 行（其他内容保留）"
  fi
}

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

remove_manifested_capabilities() {
  local manifest="$1"
  local kind checksum target current marker

  [ -f "$manifest" ] || return 0

  while IFS=$'\t' read -r kind checksum target; do
    [ -n "${target:-}" ] || continue
    if [ "$kind" = "F" ] && [ -f "$target" ]; then
      current="$(file_checksum "$target")"
      if [ "$current" = "$checksum" ]; then
        rm -f "$target"
      fi
    elif [ "$kind" = "D" ] && [ -d "$target" ]; then
      marker="$target/.superspecflow-installed"
      current="$(dir_checksum "$target")"
      if [ -f "$marker" ] &&
         grep -Fxq "$REPO_ROOT" "$marker" &&
         [ "$current" = "$checksum" ]; then
        rm -rf "$target"
      fi
    fi
  done < "$manifest"

  rm -f "$manifest"
}

if [ "$REMOVE_CLAUDE" -eq 1 ]; then
  remove_include "$HOME/.claude/CLAUDE.md" "@$HOME/.claude/superspecflow/CLAUDE.global.md"
  remove_include "$HOME/.claude/CLAUDE.md" "@${REPO_ROOT}/routing/CLAUDE.global.md"
  remove_manifested_capabilities "$HOME/.claude/superspecflow/install-manifest.tsv"
  rm -f "$HOME/.claude/superspecflow/CLAUDE.global.md"
  rmdir "$HOME/.claude/superspecflow" 2>/dev/null || true
fi

if [ "$REMOVE_CODEX" -eq 1 ]; then
  remove_include "$HOME/.codex/AGENTS.md" "@$HOME/.codex/superspecflow/AGENTS.global.md"
  remove_include "$HOME/.codex/AGENTS.md" "@${REPO_ROOT}/routing/AGENTS.global.md"
  remove_manifested_capabilities "$HOME/.codex/superspecflow/install-manifest.tsv"
  rm -f "$HOME/.codex/superspecflow/AGENTS.global.md"
  rmdir "$HOME/.codex/superspecflow" 2>/dev/null || true
fi

if [ "$REMOVE_CLAUDE" -eq 1 ]; then
  hook_path="${REPO_ROOT}/scripts/hooks/session-start-detect.sh"
  cat <<MSG

—— 可选：清理 Claude Code SessionStart hook ——
如果之前在 ~/.claude/settings.json 中合并过 SuperSpecFlow 的 SessionStart hook，
请手动移除其中 command 指向以下路径的 hook 条目（脚本不会改写 settings.json）：

  ${hook_path}
MSG
fi

if [ "$PURGE" -eq 1 ]; then
  case "$PWD/" in
    "$REPO_ROOT"/*)
      echo
      echo "error: 当前工作目录位于 $REPO_ROOT 之内，无法 --purge。" >&2
      echo "       请 cd 到其他位置后重试。" >&2
      exit 1
      ;;
  esac
  echo
  echo "→ 删除 pack 目录 $REPO_ROOT"
  rm -rf "$REPO_ROOT"
  echo "✓ pack 目录已删除"
fi

echo
echo "Done."
exit 0
