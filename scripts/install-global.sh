#!/usr/bin/env bash
# SuperSpecFlow 全局安装脚本（方案 C 推荐入口）
# 只做检测 + 提示。绝不擅自改写用户已存在的全局指令文件 / settings.json。

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SKIP_HOOK=0
INSTALL_CLAUDE=1
INSTALL_CODEX=1
INSTALL_ANTIGRAVITY=1
TARGET_SELECTED=0
AUTO_APPEND=0
ASSUME_YES=0

usage() {
  cat <<MSG
Usage: install-global.sh [--claude-only|--codex-only|--antigravity-only|--both|--all] [--append] [--yes] [--no-hook]

CLI selection (mutually exclusive):
  --claude-only       Only install include into ~/.claude/CLAUDE.md.
  --codex-only        Only install include into ~/.codex/AGENTS.md.
  --antigravity-only  Only install include into ~/.gemini/GEMINI.md.
  --both              Install into Claude Code and Codex only.
  --all               Install into Claude Code, Codex and Antigravity (default).

Other options:
  --append       Automatically prepend include line to existing CLAUDE.md / AGENTS.md / GEMINI.md.
  --yes          Non-interactive mode (accept defaults without prompting).
  --no-hook      Skip Claude Code SessionStart hook setup hint.
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
      INSTALL_CLAUDE=1
      INSTALL_CODEX=0
      INSTALL_ANTIGRAVITY=0
      shift
      ;;
    --codex-only)
      require_single_target
      INSTALL_CLAUDE=0
      INSTALL_CODEX=1
      INSTALL_ANTIGRAVITY=0
      shift
      ;;
    --antigravity-only)
      require_single_target
      INSTALL_CLAUDE=0
      INSTALL_CODEX=0
      INSTALL_ANTIGRAVITY=1
      shift
      ;;
    --both)
      require_single_target
      INSTALL_CLAUDE=1
      INSTALL_CODEX=1
      INSTALL_ANTIGRAVITY=0
      shift
      ;;
    --all)
      require_single_target
      INSTALL_CLAUDE=1
      INSTALL_CODEX=1
      INSTALL_ANTIGRAVITY=1
      shift
      ;;
    --append) AUTO_APPEND=1; shift ;;
    --yes) ASSUME_YES=1; shift ;;
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

# 同步 Claude 的 skills 和命令，复用文件归属校验保护用户修改，不创建角色目录。
sync_claude_capabilities() {
  local manifest="$HOME/.claude/superspecflow/install-manifest.tsv"
  local path

  mkdir -p "$HOME/.claude/skills" "$HOME/.claude/commands"
  for path in "$REPO_ROOT/skills/"ssf-*; do
    [ -d "$path" ] || continue
    copy_dir_safe "$path" "$HOME/.claude/skills/$(basename "$path")" "$manifest"
  done
  for path in "$REPO_ROOT/commands/"ssf-*.md; do
    copy_file_safe "$path" "$HOME/.claude/commands/$(basename "$path")" "$manifest"
  done
  echo "✓ synced Claude Code skills and commands"
}

sync_codex_capabilities() {
  local manifest="$HOME/.codex/superspecflow/install-manifest.tsv"
  local path

  mkdir -p "$HOME/.codex/skills"
  for path in "$REPO_ROOT/skills/"ssf-*; do
    [ -d "$path" ] || continue
    copy_dir_safe "$path" "$HOME/.codex/skills/$(basename "$path")" "$manifest"
  done
  echo "✓ synced Codex skills"
}

# 同步 Antigravity 的 skills 到 IDE 与 CLI 两个全局目录。
# 输入：无（依赖全局 HOME 与 REPO_ROOT）；输出：同步结果至 stdout。
# 约束：Antigravity 没有用户自定义全局 slash 命令目录，skill 在 CLI 会自动成为 /ssf-*，IDE 里可按 <skill-name> 手动调用，因此这里只同步 skills、不写 commands。
# 两个目录共用同一份 install-manifest.tsv，保证重装与卸载对两份拷贝执行同一套“本包装的且未被用户修改”判定。
sync_antigravity_capabilities() {
  local manifest="$HOME/.gemini/superspecflow/install-manifest.tsv"
  local root path

  for root in "$HOME/.gemini/config/skills" "$HOME/.gemini/antigravity-cli/skills"; do
    mkdir -p "$root"
    for path in "$REPO_ROOT/skills/"ssf-*; do
      [ -d "$path" ] || continue
      copy_dir_safe "$path" "$root/$(basename "$path")" "$manifest"
    done
  done
  echo "✓ synced Antigravity skills (IDE + CLI)"
}

# 转义 sed 替换串里的元字符，避免包安装路径中的 &、#、\ 被 sed 解释。
# 输入：$1 原始字符串；输出：转义后的字符串（stdout）。
# 约束：# 同时是本脚本 sed 命令的分隔符，必须一并转义，否则路径含 # 时替换直接报错中断安装。
sed_escape_replacement() {
  printf '%s' "$1" | sed -e 's/[\\&#]/\\&/g'
}

# 用包内模板渲染全局 wrapper：把 <repo>/routing/<host> 与 <repo> 占位符替换为包绝对路径。
# 输入：$1 模板路径；$2 输出路径；$3 routing 文件名（如 GEMINI.routing.md）。
# 输出：无 stdout；成功时写出不含占位符的 wrapper 文件。
# 约束：包路径可能含 & 或 #（企业账号、同步盘），因此对 REPO_ROOT 做 sed 替换串转义，不做任何路径合法性假设。
render_wrapper() {
  local template="$1"
  local output="$2"
  local routing_file="$3"
  local repo_escaped

  repo_escaped="$(sed_escape_replacement "$REPO_ROOT")"
  mkdir -p "$(dirname "$output")"
  sed \
    -e "s#<repo>/routing/${routing_file}#${repo_escaped}/routing/${routing_file}#g" \
    -e "s#<repo>#${repo_escaped}#g" \
    "$template" > "$output"
}

write_pack_root() {
  local output="$1"

  mkdir -p "$(dirname "$output")"
  printf '%s\n' "$REPO_ROOT" > "$output"
}

# 读取文件权限位的八进制表示（如 644）。GNU stat（Linux）用 -c '%a'，BSD stat（macOS）用 -f '%Lp'。
# 输入：$1 已存在的普通文件路径；输出：权限位（stdout），两种形式都不可用时输出空串。
# 约束：必须“先 GNU 后 BSD”，不能写成 `stat -f '%Lp' f || stat -c '%a' f` 串联——GNU stat 的 -f 是
# 文件系统模式，它会先把文件系统信息打印到 stdout 再以非零状态退出，串联兜底会把这段多行输出
# 一起捕获进变量，后续 chmod 拿到脏值失败（Linux 上 --append 全链路因此中断）。
file_mode() {
  local mode
  if mode="$(stat -c '%a' "$1" 2>/dev/null)"; then
    printf '%s' "$mode"
    return 0
  fi
  stat -f '%Lp' "$1" 2>/dev/null || true
}

# 在已存在的指令文件首行前插入 include 行，保留原文件全部内容与排版。
# 输入：$1 目标文件绝对路径；$2 要插入的 include 完整行文本。
# 输出：无 stdout；成功时原子覆盖更新目标文件。
# 约束：$1 必须为已存在且具有写权限的普通文件；写回后必须恢复原文件权限——mktemp 产物是 600，
# 直接 mv 会把用户指令文件权限静默降级，因此先记录原 mode 再 chmod 复原。
prepend_include() {
  local target="$1"
  local include_line="$2"
  local tmp mode
  tmp="$(mktemp "${TMPDIR:-/tmp}/ssf-include.XXXXXX")"

  mode="$(file_mode "$target")"
  {
    printf '%s\n' "$include_line"
    cat "$target"
  } > "$tmp"
  mv "$tmp" "$target"
  if [ -n "$mode" ]; then chmod "$mode" "$target"; fi
  return 0
}

# 把可能是符号链接的目标路径解析到其指向的真实文件；多跳、悬空或目标非普通文件时返回 1。
# 输入：$1 目标路径；输出：解析后的真实文件路径（stdout）。
# 约束：只解析单跳软链；这样写入的是用户真正维护的文件，同时保持软链本身不被替换成普通文件。
resolve_instruction_target() {
  local target="$1"
  local link

  [ -L "$target" ] || { printf '%s' "$target"; return 0; }
  link="$(readlink "$target")"
  case "$link" in
    /*) target="$link" ;;
    *) target="$(dirname "$target")/$link" ;;
  esac
  [ -L "$target" ] && return 1
  [ -f "$target" ] || return 1
  printf '%s' "$target"
}

# 确保目标指令文件包含 SuperSpecFlow 全局 include 行。
# 输入：$1 目标文件绝对路径（如 ~/.claude/CLAUDE.md、~/.codex/AGENTS.md 或 ~/.gemini/GEMINI.md）；$2 include 完整行文本。
# 输出：成功或跳过信息至 stdout；未追加且未确认时输出手动操作提示。
# 约束：已接入判定必须是整行精确匹配——子串匹配会把注释掉或含尾随空行的同一路径误判为已接入，导致路由实际不生效且无任何警告；
# 目标是软链时改写其指向的真实文件并保留软链；追加后保持原文件权限不变。
ensure_include() {
  local target="$1"          # ~/.claude/CLAUDE.md、~/.codex/AGENTS.md 或 ~/.gemini/GEMINI.md
  local include_line="$2"    # 已生成 wrapper 的绝对路径 include
  local file

  file="$(resolve_instruction_target "$target")" || {
    cat <<MSG

⚠ $target 是符号链接，但其指向的文件不存在、是多跳软链或不是普通文件。
请手动把下面这一行追加到该文件靠前位置：

  $include_line
MSG
    return 0
  }

  if [ ! -e "$file" ]; then
    mkdir -p "$(dirname "$file")"
    printf '%s\n' "$include_line" > "$file"
    echo "✓ created $target with SuperSpecFlow include"
    return 0
  fi

  if grep -Fxq "$include_line" "$file"; then
    echo "= $target already includes SuperSpecFlow, skipped"
    return 0
  fi

  local do_append=0
  if [ "$AUTO_APPEND" -eq 1 ]; then
    do_append=1
  elif [ "$ASSUME_YES" -eq 0 ] && [ -t 0 ]; then
    local ans
    read -r -p "⚠ $target 已存在但未包含 include 行。是否自动追加到文件顶部？[y/N] " ans
    case "$ans" in
      y|Y|yes|YES) do_append=1 ;;
      *) do_append=0 ;;
    esac
  fi

  if [ "$do_append" -eq 1 ]; then
    prepend_include "$file" "$include_line"
    echo "✓ appended SuperSpecFlow include to $target"
    return 0
  fi

  cat <<MSG

⚠ $target 已存在，但未包含 SuperSpecFlow include 行。
请手动追加（manually append）下面这一行到该文件靠前位置：

  $include_line

脚本不会擅自改写已有的用户全局指令文件（亦可传入 --append 自动追加）。
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

if [ "$INSTALL_ANTIGRAVITY" -eq 1 ]; then
  sync_antigravity_capabilities
  write_pack_root "$HOME/.gemini/superspecflow/pack-root"
  render_wrapper \
    "$REPO_ROOT/routing/GEMINI.global.md" \
    "$HOME/.gemini/superspecflow/GEMINI.global.md" \
    "GEMINI.routing.md"
  ensure_include "$HOME/.gemini/GEMINI.md" "@$HOME/.gemini/superspecflow/GEMINI.global.md"
fi

if [ "$SKIP_HOOK" -eq 0 ] && [ "$INSTALL_CLAUDE" -eq 1 ]; then
  hook_path="${REPO_ROOT}/scripts/hooks/session-start-detect.sh"
  cat <<MSG

—— 可选：Claude Code SessionStart hook ——
建议在 ~/.claude/settings.json 中合并以下片段（使用 Claude Code 官方 hook schema），
让会话启动、恢复、清空和压缩时都重新检测项目 opt-in：

{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear|compact",
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
echo "下一步："
step=1
if [ "$INSTALL_CLAUDE" -eq 1 ]; then
  echo "  $step. 重启 Claude Code 会话，以确保新安装的 /ssf-* 命令进入斜杠补全。"
  step=$((step + 1))
fi
if [ "$INSTALL_CODEX" -eq 1 ]; then
  echo "  $step. Codex：新会话中 skills 与全局 rules 自动生效；显式恢复已禁用项目可执行 bash \"$REPO_ROOT/scripts/_ssf_init_apply.sh\"。"
  step=$((step + 1))
fi
if [ "$INSTALL_ANTIGRAVITY" -eq 1 ]; then
  echo "  $step. Antigravity：重启 IDE / CLI 会话后 skills 与 ~/.gemini/GEMINI.md 里的全局 rules 生效，CLI 中可直接使用 /ssf-*。"
fi
echo "  默认安装已全局开启轻量自然语言路由，所有项目开箱即用，无需在每个项目中自己执行 init。"
echo "     （若需单独禁用某项目，可在该项目根目录放置 .superspecflow/disabled；需恢复时运行 /ssf-init）"
echo "  注意：若上面出现 \"skipped\" 警告，请确认对应文件，避免看到的并非 SuperSpecFlow 命令。"
echo
echo "按需使用工程 skills；项目规则优先。"
echo "Done."
exit 0
