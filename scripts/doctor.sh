#!/usr/bin/env bash
# 只读诊断当前源码包对应的安装与规则接入；不加载用户配置代码、不安装、不修复、不采集会话。
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/install-state.sh
source "$REPO_ROOT/scripts/install-state.sh"
ISSUES=0

case "${1:---all}" in
  --codex-only) HOSTS="codex" ;;
  --claude-only) HOSTS="claude" ;;
  --antigravity-only) HOSTS="antigravity" ;;
  --both) HOSTS="claude codex" ;;
  --all) HOSTS="claude codex antigravity" ;;
  -h|--help)
    echo 'Usage: doctor.sh [--codex-only|--claude-only|--antigravity-only|--both|--all]'
    echo '只读检查；默认检查所有宿主。退出码：0 安装与源码一致，1 有待处理项，2 参数错误。'
    exit 0 ;;
  *) echo "unknown arg: $1" >&2; exit 2 ;;
esac
[ "$#" -le 1 ] || { echo '只能选择一个宿主范围' >&2; exit 2; }

# 输出机器可区分的状态与中文原因；非 OK 项累积退出状态，但不阻止检查其他目标。
report() {
  local state="$1" target="$2" reason="$3"
  printf '%-13s %s — %s\n' "$state" "$target" "$reason"
  if [ "$state" != OK ]; then ISSUES=$((ISSUES + 1)); fi
}

# 只检查安装器约定的目标，比较当前源码、安装清单和文件实际内容，避免把旧版或用户修改混为未安装。
# $1 为 F/D 类型，后续为源、目标、清单；软链或特殊文件只报告不可核验，不跟随目录或阻塞读取。
check_capability() {
  local kind="$1" source_path="$2" target="$3" manifest="$4" actual expected
  if [ -L "$target" ]; then
    report UNVERIFIABLE "$target" '符号链接，未核验内容'
    return
  elif [ ! -e "$target" ]; then
    report MISSING "$target" '能力未安装或文件缺失'
    return
  fi
  if [ "$kind" = D ] && [ -d "$target" ]; then
    if ! actual="$(dir_checksum "$target")"; then
      report UNVERIFIABLE "$target" '目录含软链、特殊文件或读取失败'
      return
    fi
    if [ ! -f "$target/.superspecflow-installed" ] ||
       [ -L "$target/.superspecflow-installed" ] ||
       ! grep -Fxq "$REPO_ROOT" "$target/.superspecflow-installed"; then
      report UNOWNED "$target" '缺少本源码包的归属标记；不应直接覆盖'
      return
    fi
    expected="$(dir_checksum "$source_path")"
  elif [ "$kind" = F ] && [ -f "$target" ]; then
    actual="$(file_checksum "$target")"
    expected="$(file_checksum "$source_path")"
  else
    report UNVERIFIABLE "$target" '目标类型与安装契约不符'
    return
  fi
  if [ ! -f "$manifest" ] || [ -L "$manifest" ] || ! manifest_has_path "$manifest" "$target"; then
    report UNOWNED "$target" '无可核验的安装记录；保留现有内容'
  elif ! manifest_checksum_matches "$manifest" "$kind" "$actual" "$target"; then
    report MODIFIED "$target" '实际内容与最近安装记录不同；需先核对本地修改'
  elif [ "$actual" != "$expected" ]; then
    report STALE "$target" '已安装内容与当前源码不同；确认所需版本后同步'
  else
    report OK "$target" '内容与当前源码、最近安装记录一致'
  fi
}

# 按安装器的模板规则在内存渲染预期 wrapper；输入宿主文件名前缀，不写临时文件。
expected_wrapper() {
  local host_file="$1"
  awk -v f="$REPO_ROOT/routing/$host_file.routing.md" -v root="$REPO_ROOT" '
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
  ' "$REPO_ROOT/routing/$host_file.global.md"
}

# 检查一个宿主的来源、全局入口、渲染规则与能力；入口允许安装器支持的普通文件软链。
# 只识别安装器生成的整行 include，自定义加载方式须由会话证据补充，不据此宣称宿主已实际加载。
check_host() {
  local host="$1" base host_file roots wrapper source_path root manifest target
  case "$host" in
    codex) base="$HOME/.codex"; host_file=AGENTS; roots=("$HOME/.codex/skills") ;;
    claude) base="$HOME/.claude"; host_file=CLAUDE; roots=("$HOME/.claude/skills") ;;
    antigravity)
      base="$HOME/.gemini"; host_file=GEMINI
      roots=("$HOME/.gemini/config/skills" "$HOME/.gemini/antigravity-cli/skills") ;;
  esac
  printf '\n[%s]\n' "$host"
  wrapper="$base/superspecflow/$host_file.global.md"
  manifest="$base/superspecflow/install-manifest.tsv"
  target="$base/superspecflow/pack-root"
  if [ -f "$target" ] && [ ! -L "$target" ] && grep -Fxq "$REPO_ROOT" "$target"; then
    report OK "$target" '来源为当前源码包'
  else
    report SOURCE "$target" '来源缺失或不同；确认正在检查的源码包与安装来源'
  fi
  target="$base/$host_file.md"
  if [ -f "$target" ] && grep -Fxq "@$wrapper" "$target"; then
    report OK "$target" '存在标准 include；宿主是否实际读取须查看会话'
  else
    report DISCONNECTED "$target" '未找到标准 include；自然语言路由未确认，独立 skill 仍可能可用'
  fi
  if [ -L "$wrapper" ] || [ ! -f "$wrapper" ]; then
    report UNVERIFIABLE "$wrapper" '规则文件缺失或不是普通文件'
  elif ! cmp -s "$wrapper" <(expected_wrapper "$host_file"); then
    report STALE "$wrapper" '规则内容与当前源码不同；可能为旧版或本地修改'
  else
    report OK "$wrapper" '规则内容与当前源码一致'
  fi
  for root in "${roots[@]}"; do
    if [ -L "$root" ]; then
      report UNVERIFIABLE "$root" 'skills 根目录为符号链接，未继续核验'
      continue
    fi
    for source_path in "$REPO_ROOT"/skills/ssf-*; do
      check_capability D "$source_path" "$root/${source_path##*/}" "$manifest"
    done
  done
  if [ "$host" = claude ]; then
    if [ -L "$base/commands" ]; then
      report UNVERIFIABLE "$base/commands" '命令目录为符号链接，未继续核验'
    else
      for source_path in "$REPO_ROOT"/commands/ssf-*.md; do
        check_capability F "$source_path" "$base/commands/${source_path##*/}" "$manifest"
      done
    fi
  fi
}

printf 'SuperSpecFlow 安装诊断（只读）\n对照源码：%s\n' "$REPO_ROOT"
for host in $HOSTS; do check_host "$host"; done
printf '\n待处理项：%s\n' "$ISSUES"
echo '本检查只证明磁盘上的安装/接入状态，不证明当前会话使用了 skill，也不证明质量提升。'
echo '会话中核对：实际读取的 SKILL.md → 采用的方法与操作 → 对应结果和验证证据。'
[ "$ISSUES" -eq 0 ]
