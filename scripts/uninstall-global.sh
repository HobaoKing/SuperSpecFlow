#!/usr/bin/env bash
# SuperSpecFlow 全局卸载脚本（与 install-global.sh 对称）
# 只精确移除本仓库写入的 include 行，绝不改动用户在指令文件里的其他内容。

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

REMOVE_CLAUDE=1
REMOVE_CODEX=1
REMOVE_ANTIGRAVITY=1
PURGE=0
TARGET_SELECTED=0

# 展示卸载范围与 purge 的前置约束；只打印帮助，不改动安装状态。
usage() {
  cat <<MSG
Usage: uninstall-global.sh [--claude-only|--codex-only|--antigravity-only|--both|--all] [--purge]

CLI selection (mutually exclusive):
  --claude-only       Only remove include from ~/.claude/CLAUDE.md.
  --codex-only        Only remove include from ~/.codex/AGENTS.md.
  --antigravity-only  Only remove include from ~/.gemini/GEMINI.md.
  --both              Remove from Claude Code and Codex only.
  --all               Remove from Claude Code, Codex and Antigravity (default).

Other options:
  --purge        After removing includes, also delete the pack directory at $REPO_ROOT.
                 拒绝在 pack 目录内部执行，或删除其他未卸载宿主仍引用的共享包。
  -h, --help     Show this help.
MSG
}

require_single_target() {
  if [ "$TARGET_SELECTED" -eq 1 ]; then
    echo "error: --claude-only / --codex-only / --antigravity-only / --both / --all are mutually exclusive" >&2
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
      REMOVE_ANTIGRAVITY=0
      shift
      ;;
    --codex-only)
      require_single_target
      REMOVE_CLAUDE=0
      REMOVE_CODEX=1
      REMOVE_ANTIGRAVITY=0
      shift
      ;;
    --antigravity-only)
      require_single_target
      REMOVE_CLAUDE=0
      REMOVE_CODEX=0
      REMOVE_ANTIGRAVITY=1
      shift
      ;;
    --both)
      require_single_target
      REMOVE_CLAUDE=1
      REMOVE_CODEX=1
      REMOVE_ANTIGRAVITY=0
      shift
      ;;
    --all)
      require_single_target
      REMOVE_CLAUDE=1
      REMOVE_CODEX=1
      REMOVE_ANTIGRAVITY=1
      shift
      ;;
    --purge) PURGE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown arg: $1" >&2; usage >&2; exit 1 ;;
  esac
done

if [ "$PURGE" -eq 1 ]; then
  # 在任何卸载写操作之前检查物理路径与未选宿主依赖，失败时保留完整安装。
  real_root="$(cd "$REPO_ROOT" 2>/dev/null && pwd -P)" || real_root="$REPO_ROOT"
  case "$(pwd -P)/" in
    "$real_root"/*)
      echo
      echo "error: 当前工作目录位于 $REPO_ROOT 之内，无法 --purge。" >&2
      echo "       请 cd 到其他位置后重试。" >&2
      exit 1
      ;;
  esac
  for host_state in ".claude:$REMOVE_CLAUDE" ".codex:$REMOVE_CODEX" ".gemini:$REMOVE_ANTIGRAVITY"; do
    [ "${host_state##*:}" -eq 0 ] || continue
    host_dir="${host_state%:*}"
    record="$HOME/$host_dir/superspecflow/pack-root"
    [ -f "$record" ] || continue
    dependency="$(cat "$record")"
    if [ -d "$dependency" ]; then
      dependency="$(cd "$dependency" && pwd -P)"
    fi
    if [ "$dependency" = "$real_root" ]; then
      echo "error: $host_dir 仍引用此共享包，无法 --purge；请保留包或明确卸载所有引用宿主。" >&2
      exit 1
    fi
  done
fi

# 读取文件权限位的八进制表示（如 644）。GNU stat（Linux）用 -c '%a'，BSD stat（macOS）用 -f '%Lp'。
# 输入：$1 已存在的普通文件路径；输出：权限位（stdout），两种形式都不可用时输出空串。
# 约束：必须“先 GNU 后 BSD”，不能写成 `stat -f '%Lp' f || stat -c '%a' f` 串联——GNU stat 的 -f 是
# 文件系统模式，它会先把文件系统信息打印到 stdout 再以非零状态退出，串联兜底会把这段多行输出
# 一起捕获进变量，后续 chmod 拿到脏值失败（Linux 上移除 include 后恢复权限因此中断）。
file_mode() {
  local mode
  if mode="$(stat -c '%a' "$1" 2>/dev/null)"; then
    printf '%s' "$mode"
    return 0
  fi
  stat -f '%Lp' "$1" 2>/dev/null || true
}

# 精确移除 include 并保留其余内容与权限；软链目标删空时写回空文件，不删除真实文件或软链。
# $1 宿主指令文件路径，$2 完整 include 行；无法解析的软链仅提示并跳过。
remove_include() {
  local target="$1"          # ~/.claude/CLAUDE.md、~/.codex/AGENTS.md 或 ~/.gemini/GEMINI.md
  local include_line="$2"    # 已生成 wrapper 的绝对路径 include
  local file

  if [ -L "$target" ]; then
    # 软链改写其指向的真实文件并保留软链本身；多跳或悬空软链跳过，避免把软链替换成普通文件
    local link
    link="$(readlink "$target")"
    case "$link" in
      /*) file="$link" ;;
      *) file="$(dirname "$target")/$link" ;;
    esac
    if [ -L "$file" ] || [ ! -f "$file" ]; then
      echo "= $target 是指向不存在或多跳的符号链接，跳过"
      return 0
    fi
  else
    file="$target"
  fi

  if [ ! -e "$file" ]; then
    echo "= $target 不存在，跳过"
    return 0
  fi

  if ! grep -Fxq "$include_line" "$file"; then
    echo "= $target 未包含 SuperSpecFlow include 行，跳过"
    return 0
  fi

  local tmp mode
  tmp="$(mktemp)"
  # -F 固定字符串，-x 整行匹配，-v 反选；只移除恰好等于 include_line 的行
  grep -Fxv "$include_line" "$file" > "$tmp" || true

  # mktemp 产物是 600，写回前记录并恢复原权限，避免静默降级用户指令文件权限
  mode="$(file_mode "$file")"
  if [ ! -s "$tmp" ]; then
    if [ -L "$target" ]; then
      # 软链场景绝不越界删除用户真实文件（可能是 dotfiles 仓库里的共享文件）：
      # 写回空内容并恢复权限，保留真实文件，由用户自行决定去留。
      mv "$tmp" "$file"
      if [ -n "$mode" ]; then chmod "$mode" "$file"; fi
      echo "✓ 已从 $target 移除 SuperSpecFlow include 行（软链保留）"
      echo "⚠ 其指向的真实文件 $file 删除 include 后已为空，请自行确认是否删除。"
    else
      rm -f "$file" "$tmp"
      echo "✓ 已移除 ${target}（删除 include 后文件为空，整文件已删除）"
    fi
  else
    mv "$tmp" "$file"
    if [ -n "$mode" ]; then chmod "$mode" "$file"; fi
    echo "✓ 已从 $target 移除 SuperSpecFlow include 行（其他内容保留）"
  fi
}

# shellcheck source=scripts/install-state.sh
source "$REPO_ROOT/scripts/install-state.sh"

# 仅依据清单最后一条记录移除未修改能力；无法校验或用户修改的目标保留并提示。
# $1 为当前宿主清单；兼容旧版重复记录，卸载结束删除该宿主清单。
remove_manifested_capabilities() {
  local manifest="$1" kind checksum target
  [ -f "$manifest" ] || return 0
  while IFS=$'\t' read -r kind checksum target; do
    [ -n "${target:-}" ] || continue
    if owned_target_matches "$kind" "$checksum" "$target"; then
      if [ "$kind" = D ]; then rm -rf "$target"; else rm -f "$target"; fi
    elif [ -e "$target" ] || [ -L "$target" ]; then
      echo "⚠ modified or unverifiable capability preserved: $target"
    fi
  done < <(manifest_latest "$manifest")
  rm -f "$manifest"
}

if [ "$REMOVE_ANTIGRAVITY" -eq 1 ]; then
  remove_include "$HOME/.gemini/GEMINI.md" "@$HOME/.gemini/superspecflow/GEMINI.global.md"
  remove_manifested_capabilities "$HOME/.gemini/superspecflow/install-manifest.tsv"
  rm -f "$HOME/.gemini/superspecflow/GEMINI.global.md" "$HOME/.gemini/superspecflow/pack-root"
  rmdir "$HOME/.gemini/superspecflow" 2>/dev/null || true
fi

if [ "$REMOVE_CLAUDE" -eq 1 ]; then
  remove_include "$HOME/.claude/CLAUDE.md" "@$HOME/.claude/superspecflow/CLAUDE.global.md"
  remove_manifested_capabilities "$HOME/.claude/superspecflow/install-manifest.tsv"
  rm -f "$HOME/.claude/superspecflow/CLAUDE.global.md" "$HOME/.claude/superspecflow/pack-root"
  rmdir "$HOME/.claude/superspecflow" 2>/dev/null || true
fi

if [ "$REMOVE_CODEX" -eq 1 ]; then
  remove_include "$HOME/.codex/AGENTS.md" "@$HOME/.codex/superspecflow/AGENTS.global.md"
  remove_manifested_capabilities "$HOME/.codex/superspecflow/install-manifest.tsv"
  rm -f "$HOME/.codex/superspecflow/AGENTS.global.md" "$HOME/.codex/superspecflow/pack-root"
  rmdir "$HOME/.codex/superspecflow" 2>/dev/null || true
fi

if [ "$PURGE" -eq 1 ]; then
  echo
  echo "→ 删除 pack 目录 $real_root"
  rm -rf "$real_root"
  echo "✓ pack 目录已删除"
fi

echo
echo "Done."
exit 0
