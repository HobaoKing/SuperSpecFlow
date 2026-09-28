#!/usr/bin/env bash
# SuperSpecFlow 全局安装脚本。
# 同步所选宿主能力；已有全局指令仅在 --append 或交互确认后追加，不改写 settings.json。

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

INSTALL_CLAUDE=1
INSTALL_CODEX=1
INSTALL_ANTIGRAVITY=1
TARGET_SELECTED=0
AUTO_APPEND=0
ASSUME_YES=0
INCLUDES_PENDING=0
PRESERVED_COUNT=0
INSTALL_WRITES=()
CONNECTED_INCLUDES=()
INSTALL_STAGE=""

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
  --no-hook      Deprecated no-op kept for CLI compatibility; the SessionStart hook was removed.
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
    # --no-hook 已废弃：SessionStart hook 已删除，保留解析仅为兼容旧调用。
    --no-hook) shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown arg: $1" >&2; usage >&2; exit 1 ;;
  esac
done

# shellcheck source=scripts/install-state.sh
source "$REPO_ROOT/scripts/install-state.sh"

# 仅回收本次创建的暂存目录；其中尚有旧版本时保留并提示恢复位置，避免失败后误删。
# shellcheck disable=SC2317,SC2329 # EXIT trap 间接调用，兼容不同检查器版本。
cleanup_install_stage() {
  [ -n "$INSTALL_STAGE" ] || return 0
  if [ -e "$INSTALL_STAGE/previous" ] || [ -L "$INSTALL_STAGE/previous" ]; then
    echo "⚠ preserved previous installation: $INSTALL_STAGE/previous" >&2
  else
    rm -rf "$INSTALL_STAGE"
  fi
}
trap 'cleanup_install_stage' EXIT

# 记录本次写入的预期内容供安装末尾读回；四项为类型、源内容 checksum、目标与可选清单。
remember_install_write() {
  INSTALL_WRITES+=("$1"$'\t'"$2"$'\t'"$3"$'\t'"$4")
}

# 在同目录暂存并验证新内容后替换能力，复制失败不动旧版；替换失败尝试恢复旧版。
# 参数为源、目标、清单、F/D 类型；仅在调用方已通过归属保护后调用，旧版保留到记录成功。
install_staged_capability() {
  local src="$1" target="$2" manifest="$3" kind="$4" expected actual file current
  if [ "$kind" = D ]; then expected="$(dir_checksum "$src")"; else expected="$(file_checksum "$src")"; fi
  mkdir -p "$(dirname "$target")"
  INSTALL_STAGE="$(mktemp -d "$(dirname "$target")/.ssf-install.XXXXXX")"
  if [ "$kind" = D ]; then
    cp -R "$src" "$INSTALL_STAGE/content"
    actual="$(dir_checksum "$INSTALL_STAGE/content")"
    while IFS= read -r file; do
      [ -x "$INSTALL_STAGE/content/${file#"$src"/}" ] || { echo "error: executable missing: $file" >&2; return 1; }
    done < <(find "$src" -type f -perm -100)
    printf '%s\n' "$REPO_ROOT" > "$INSTALL_STAGE/content/.superspecflow-installed"
  else
    cp "$src" "$INSTALL_STAGE/content"
    actual="$(file_checksum "$INSTALL_STAGE/content")"
  fi
  [ "$expected" = "$actual" ] || { echo "error: staged content mismatch: $target" >&2; return 1; }
  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ "$kind" = D ]; then current="$(dir_checksum "$target")"; else current="$(file_checksum "$target")"; fi
    if ! manifest_checksum_matches "$manifest" "$kind" "$current" "$target" ||
       ! owned_target_matches "$kind" "$current" "$target"; then
      echo "error: target changed before replacement: $target" >&2
      return 1
    fi
    mv "$target" "$INSTALL_STAGE/previous"
  fi
  if ! mv "$INSTALL_STAGE/content" "$target"; then
    if [ -e "$INSTALL_STAGE/previous" ]; then mv "$INSTALL_STAGE/previous" "$target"; fi
    return 1
  fi
  record_manifest "$manifest" "$kind" "$expected" "$target"
  remember_install_write "$kind" "$expected" "$target" "$manifest"
  rm -rf "$INSTALL_STAGE"
  INSTALL_STAGE=""
}

# 读回本次实际写入的能力与元数据，内容、归属或清单不符即失败，禁止继续清理退役内容。
# 用户修改而跳过的目标不计为通过；它们由 PRESERVED_COUNT 在汇总中单独报告。
verify_install_writes() {
  local row kind expected target manifest actual include_line
  for row in ${INSTALL_WRITES[@]+"${INSTALL_WRITES[@]}"}; do
    IFS=$'\t' read -r kind expected target manifest <<< "$row"
    if [ "$kind" = D ]; then
      actual="$(dir_checksum "$target")" || return 1
      [ -f "$target/.superspecflow-installed" ] && [ ! -L "$target/.superspecflow-installed" ] &&
        grep -Fxq "$REPO_ROOT" "$target/.superspecflow-installed" || return 1
    else
      [ -f "$target" ] && [ ! -L "$target" ] || return 1
      actual="$(file_checksum "$target")" || return 1
    fi
    [ "$actual" = "$expected" ] || { echo "error: installed content mismatch: $target" >&2; return 1; }
    if [ -n "$manifest" ]; then
      manifest_checksum_matches "$manifest" "$kind" "$actual" "$target" || return 1
    fi
  done
  for row in ${CONNECTED_INCLUDES[@]+"${CONNECTED_INCLUDES[@]}"}; do
    IFS=$'\t' read -r target include_line <<< "$row"
    if [ ! -f "$target" ] || ! grep -Fxq "$include_line" "$target"; then
      echo "error: include readback failed: $target" >&2
      return 1
    fi
  done
  echo "✓ installation readback passed: ${#INSTALL_WRITES[@]} written targets; preserved: $PRESERVED_COUNT"
}

# 只覆盖最近一次安装后未修改的普通文件；用户软链和未归属文件均保留。
# $1 源文件，$2 安装目标，$3 宿主 manifest；跳过计入保留项，暂存验证后替换并登记最终读回。
copy_file_safe() {
  local src="$1"
  local target="$2"
  local manifest="$3"
  local current

  mkdir -p "$(dirname "$target")"
  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ ! -f "$target" ] || [ -L "$target" ]; then
      echo "⚠ $target already exists but is not a regular file; skipped"
      PRESERVED_COUNT=$((PRESERVED_COUNT + 1))
      return 0
    fi
    current="$(file_checksum "$target")"
    if manifest_has_path "$manifest" "$target"; then
      if ! manifest_checksum_matches "$manifest" "F" "$current" "$target"; then
        echo "⚠ $target was modified after SuperSpecFlow installed it; skipped"
        PRESERVED_COUNT=$((PRESERVED_COUNT + 1))
        return 0
      fi
    else
      echo "⚠ $target already exists and was not installed by SuperSpecFlow; skipped"
      PRESERVED_COUNT=$((PRESERVED_COUNT + 1))
      return 0
    fi
  fi

  install_staged_capability "$src" "$target" "$manifest" F
}

# 重装目录前核对当前包标记与最新校验值；含软链或特殊文件时跳过，保留旧版校验兼容性。
# $1 源目录，$2 安装目标，$3 宿主 manifest；暂存验证通过后同步整个目录并登记归属及最终读回。
copy_dir_safe() {
  local src="$1"
  local target="$2"
  local manifest="$3"
  local marker="$target/.superspecflow-installed"
  local current

  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ ! -d "$target" ] || [ -L "$target" ]; then
      echo "⚠ $target already exists but is not a directory; skipped"
      PRESERVED_COUNT=$((PRESERVED_COUNT + 1))
      return 0
    fi
    if current="$(dir_checksum "$target")" &&
       [ -f "$marker" ] &&
       grep -Fxq "$REPO_ROOT" "$marker" &&
       manifest_checksum_matches "$manifest" "D" "$current" "$target"; then
      : # 验证通过，旧目录仅在新内容暂存校验后替换。
    else
      echo "⚠ $target already exists or was modified after SuperSpecFlow installed it; skipped"
      PRESERVED_COUNT=$((PRESERVED_COUNT + 1))
      return 0
    fi
  fi

  install_staged_capability "$src" "$target" "$manifest" D
}

# 同步 Claude 的 skills 和命令；退役清理延后至安装读回通过，保留用户内容。
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
  echo "✓ processed Claude Code skills and commands"
}

# 同步 Codex skills；不影响未归属或用户修改的能力，退役清理延后至安装读回通过。
sync_codex_capabilities() {
  local manifest="$HOME/.codex/superspecflow/install-manifest.tsv"
  local path

  mkdir -p "$HOME/.codex/skills"
  for path in "$REPO_ROOT/skills/"ssf-*; do
    [ -d "$path" ] || continue
    copy_dir_safe "$path" "$HOME/.codex/skills/$(basename "$path")" "$manifest"
  done
  echo "✓ processed Codex skills"
}

# 同步 Antigravity 的 skills 到 IDE 与 CLI 两个全局目录。
# 输入：无（依赖全局 HOME 与 REPO_ROOT）；输出：同步结果至 stdout。
# 约束：Antigravity 没有用户自定义全局 slash 命令目录，skill 在 CLI 会自动成为 /ssf-*，IDE 里可按 <skill-name> 手动调用，因此这里只同步 skills、不写 commands。
# 两个目录共用一份清单，安装验证后再分别清理退役能力；重装和卸载均只对比最近一次安装记录。
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
  echo "✓ processed Antigravity skills (IDE + CLI)"
}

# 用包内模板渲染全局 wrapper：模板中含 <repo> 的占位行被整体替换为对应 routing 文件全文，
# 同时把内联内容中的 <pack> 占位符展开为包绝对路径，使安装后的 wrapper 自包含规则与路径，
# 不依赖宿主是否支持嵌套 include，也不受包路径特殊字符影响（一律用 index 定位替换，无正则展开）。
# 输入：$1 模板路径；$2 输出路径；$3 routing 文件名（如 GEMINI.routing.md）。
# 输出：无 stdout；暂存渲染后写出自包含 wrapper 并登记读回；源缺失或目标软链时拒绝。
render_wrapper() {
  local template="$1"
  local output="$2"
  local routing_file="$3"
  local routing_path="$REPO_ROOT/routing/$routing_file"
  local expected
  if [ ! -s "$template" ] || [ ! -s "$routing_path" ]; then
    echo "error: missing wrapper source" >&2
    return 1
  fi
  [ ! -L "$output" ] || { echo "error: wrapper is a symlink: $output" >&2; return 1; }

  mkdir -p "$(dirname "$output")"
  INSTALL_STAGE="$(mktemp -d "$(dirname "$output")/.ssf-install.XXXXXX")"
  awk -v f="$routing_path" -v root="$REPO_ROOT" '
    function emit(s,   out, i) {
      out = ""
      while ((i = index(s, "<pack>")) > 0) {
        out = out substr(s, 1, i - 1) root
        s = substr(s, i + 6)
      }
      print out s
    }
    index($0, "<repo>") > 0 { while ((getline line < f) > 0) emit(line); close(f); next }
    { emit($0) }
  ' "$template" > "$INSTALL_STAGE/content"
  expected="$(file_checksum "$INSTALL_STAGE/content")"
  mv "$INSTALL_STAGE/content" "$output"
  remember_install_write F "$expected" "$output" ""
  rm -rf "$INSTALL_STAGE"
  INSTALL_STAGE=""
}

# 写入并记录实际源码来源；拒绝跟随元数据软链，安装末尾必须读回同一内容。
write_pack_root() {
  local output="$1" expected

  [ ! -L "$output" ] || { echo "error: pack-root is a symlink: $output" >&2; return 1; }
  mkdir -p "$(dirname "$output")"
  expected="$(printf '%s\n' "$REPO_ROOT" | shasum -a 256 | awk '{print $1}')"
  printf '%s\n' "$REPO_ROOT" > "$output"
  remember_install_write F "$expected" "$output" ""
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
# 输出：成功或跳过信息至 stdout；已接入项登记到最终读回，未接入项设置 INCLUDES_PENDING 并提示。
# 约束：已接入判定必须是整行精确匹配——子串匹配会把注释掉或含尾随空行的同一路径误判为已接入，导致路由实际不生效且无任何警告；
# 目标是软链时改写其指向的真实文件并保留软链；追加后保持原文件权限不变。
ensure_include() {
  local target="$1"          # ~/.claude/CLAUDE.md、~/.codex/AGENTS.md 或 ~/.gemini/GEMINI.md
  local include_line="$2"    # 已生成 wrapper 的绝对路径 include
  local file

  file="$(resolve_instruction_target "$target")" || {
    INCLUDES_PENDING=1
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
    CONNECTED_INCLUDES+=("$file"$'\t'"$include_line")
    echo "✓ created $target with SuperSpecFlow include"
    return 0
  fi

  if grep -Fxq "$include_line" "$file"; then
    CONNECTED_INCLUDES+=("$file"$'\t'"$include_line")
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
    CONNECTED_INCLUDES+=("$file"$'\t'"$include_line")
    echo "✓ appended SuperSpecFlow include to $target"
    return 0
  fi

  INCLUDES_PENDING=1
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

# 只有本次写入全部通过读回才清理所选宿主的退役能力；不遍历其他宿主、源码包或未知目录。
if ! verify_install_writes; then
  echo "error: installation verification failed; retired cleanup not run" >&2
  exit 1
fi
if [ "$INSTALL_CLAUDE" -eq 1 ]; then
  prune_retired_capabilities "$HOME/.claude/superspecflow/install-manifest.tsv" "$HOME/.claude/skills" D "$REPO_ROOT/skills"
  prune_retired_capabilities "$HOME/.claude/superspecflow/install-manifest.tsv" "$HOME/.claude/commands" F "$REPO_ROOT/commands"
fi
if [ "$INSTALL_CODEX" -eq 1 ]; then
  prune_retired_capabilities "$HOME/.codex/superspecflow/install-manifest.tsv" "$HOME/.codex/skills" D "$REPO_ROOT/skills"
fi
if [ "$INSTALL_ANTIGRAVITY" -eq 1 ]; then
  for root in "$HOME/.gemini/config/skills" "$HOME/.gemini/antigravity-cli/skills"; do
    prune_retired_capabilities "$HOME/.gemini/superspecflow/install-manifest.tsv" "$root" D "$REPO_ROOT/skills"
  done
fi
echo "✓ retired cleanup: removed=${SSF_PRUNED:-0}, preserved=${SSF_PRUNE_PRESERVED:-0}"
if [ "$PRESERVED_COUNT" -gt 0 ]; then
  echo "⚠ partial installation: $PRESERVED_COUNT protected targets retained; not all capabilities updated"
fi

echo
echo "下一步："
step=1
if [ "$INSTALL_CLAUDE" -eq 1 ]; then
  echo "  $step. 重启 Claude Code 会话，以确保新安装的 /ssf-* 命令进入斜杠补全。"
  step=$((step + 1))
fi
if [ "$INSTALL_CODEX" -eq 1 ]; then
  echo "  $step. Codex：完成 include 接入后，新会话会加载 skills 与全局 rules。"
  step=$((step + 1))
fi
if [ "$INSTALL_ANTIGRAVITY" -eq 1 ]; then
  echo "  $step. Antigravity：完成 include 接入后重启 IDE / CLI 会话，加载 skills 与全局 rules；CLI 中可直接使用 /ssf-*。"
fi
if [ "$INCLUDES_PENDING" -eq 0 ]; then
  echo "  所选宿主的全局 rules 已接入；不想启用时，移除对应全局指令文件中的 include 行即可。"
else
  echo "  能力同步已处理，但部分宿主的全局 rules 尚未接入，请按上方提示手动追加 include，或使用 --append。"
fi
echo "  注意：若上面出现 \"skipped\" 警告，请确认对应文件，避免看到的并非 SuperSpecFlow 命令。"
echo
echo "按需使用工程 skills；项目规则优先。"
if [ "$PRESERVED_COUNT" -gt 0 ] || [ "$INCLUDES_PENDING" -gt 0 ] || [ "${SSF_PRUNE_PRESERVED:-0}" -gt 0 ]; then
  echo "Done with preserved or pending items; see warnings above."
else
  echo "Done. Installation verified."
fi
exit 0
