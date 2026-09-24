#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_FILE="$SCRIPT_DIR/VERSION"

# 透传给 install-global.sh 的参数；用标志位而非数组长度判断是否显式指定目标，规避 Bash 3.2 nounset 下空数组问题
PASSTHROUGH_ARGS=()
TARGET_EXPLICIT=0

usage() {
  cat <<'MSG'
Usage:
  ./update.sh [install-global.sh 参数...]
  ./update.sh --version

Options:
  --version
      Print the SuperSpecFlow package version and exit without installing.

  其余参数原样透传给 scripts/install-global.sh（如 --claude-only、--append、--yes）。
  不传目标参数时，按各宿主 pack-root 记录探测已安装范围；探测不到才默认安装全部宿主。
MSG
}

print_version() {
  local version
  version="$(cat "$VERSION_FILE")"
  printf 'SuperSpecFlow %s\n' "$version"
}

# 探测某宿主此前是否安装过：install-global.sh 会写 ~/.<宿主>/superspecflow/pack-root，
# 该文件存在即说明这个目标已经接入，更新时不应扩大或缩小安装范围。
# 输入：$1 宿主 HOME 子目录名（.claude / .codex / .gemini，注意前导点）；输出：已安装返回 0，未安装返回 1。
# 约束：调用方必须用 if 判断，不能在 set -e 下写成 `host_was_installed x && ...`——未安装时
# 该链返回非零会被 set -e 当成致命错误直接中断脚本。
host_was_installed() {
  local host_dir="$1"
  [ -f "$HOME/$host_dir/superspecflow/pack-root" ]
}

# 按探测结果给出 install-global.sh 的目标参数；未显式传目标时才调用。
# 输入：无；输出：单个目标参数（stdout）。
# 约束：install-global.sh 的目标选项互斥，只能单选，因此按“命中数量与组合”收敛：
# 恰好命中 1 个宿主用对应 --<host>-only；恰好命中 Claude+Codex 用 --both；
# 其余组合（0 个、3 个或含 Gemini 的多选）统一用 --all，由安装脚本自行处理。
detected_target_args() {
  local found=0
  local claude_hit=0
  local codex_hit=0
  local target="--all"

  if host_was_installed .claude; then
    found=$((found + 1))
    claude_hit=1
    target="--claude-only"
  fi
  if host_was_installed .codex; then
    found=$((found + 1))
    codex_hit=1
    target="--codex-only"
  fi
  if host_was_installed .gemini; then
    found=$((found + 1))
    target="--antigravity-only"
  fi

  if [ "$found" -eq 1 ]; then
    printf '%s' "$target"
  elif [ "$found" -eq 2 ] && [ "$claude_hit" -eq 1 ] && [ "$codex_hit" -eq 1 ]; then
    # Claude+Codex 组合有专门的 --both，语义与逐项安装等价且不重复执行公共步骤
    printf '%s' "--both"
  else
    printf '%s' "--all"
  fi
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --version)
      print_version
      exit 0
      ;;
    --enable-natural-language)
      echo "error: --enable-natural-language 已删除：不再使用标记文件，启用状态由 include 行决定" >&2
      exit 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      # 其余参数一律透传，不再自行拒绝 install-global.sh 支持的选项
      PASSTHROUGH_ARGS+=("$1")
      case "$1" in
        --claude-only|--codex-only|--antigravity-only|--both|--all) TARGET_EXPLICIT=1 ;;
      esac
      shift
      ;;
  esac
done

# 只有“目标参数”算显式指定：--yes / --no-hook / --append 之类的选项不应抑制探测，
# 否则老用户每次更新都会被动扩容到全部宿主。
if [ "$TARGET_EXPLICIT" -eq 1 ]; then
  "$SCRIPT_DIR/scripts/install-global.sh" ${PASSTHROUGH_ARGS[@]+"${PASSTHROUGH_ARGS[@]}"}
else
  TARGET_ARGS="$(detected_target_args)"
  echo "→ 未指定目标，按已安装范围更新：$TARGET_ARGS"
  "$SCRIPT_DIR/scripts/install-global.sh" "$TARGET_ARGS" ${PASSTHROUGH_ARGS[@]+"${PASSTHROUGH_ARGS[@]}"}
fi

echo "Done. Restart the session to reload instructions."
