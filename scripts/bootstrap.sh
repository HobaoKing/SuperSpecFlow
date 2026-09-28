#!/usr/bin/env bash
# SuperSpecFlow bootstrap installer.
# 远程拉取并安装 SuperSpecFlow，然后透传参数给 install-global.sh。
#
# 一句话安装:
#   curl -fsSL https://raw.githubusercontent.com/HobaoKing/SuperSpecFlow/master/scripts/bootstrap.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/HobaoKing/SuperSpecFlow/master/scripts/bootstrap.sh | bash -s -- --claude-only
#
# 环境变量:
#   SUPERSPECFLOW_HOME   本地安装路径（默认 ~/.superspecflow）
#   SUPERSPECFLOW_REPO   源仓库地址（默认 https://github.com/HobaoKing/SuperSpecFlow.git）
#   SUPERSPECFLOW_BRANCH 源仓库分支（默认 master；测试或试用未发布能力时可指向 develop）

set -euo pipefail

REPO_URL="${SUPERSPECFLOW_REPO:-https://github.com/HobaoKing/SuperSpecFlow.git}"
REPO_BRANCH="${SUPERSPECFLOW_BRANCH:-master}"
INSTALL_DIR="${SUPERSPECFLOW_HOME:-$HOME/.superspecflow}"

# 比较目标提交的文件路径与所有本地未跟踪文件（包括被忽略文件），拒绝同名或父子路径冲突。
# $1 是已 fetch 的提交；仅读取工作区，失败时列出冲突并返回 1，不切换分支或执行安装。
check_untracked_conflicts() {
  local commit="$1" path target conflict=0
  local targets=()
  while IFS= read -r -d '' target; do
    targets+=("$target")
  done < <(git -C "$INSTALL_DIR" ls-tree -r --name-only -z "$commit")
  while IFS= read -r -d '' path; do
    # Git 将未跟踪的嵌套仓库表示为目录路径，去掉结尾 / 后同样检查父子冲突。
    path="${path%/}"
    for target in ${targets[@]+"${targets[@]}"}; do
      case "$path/" in
        "$target/"*) conflict=1; break ;;
      esac
      case "$target/" in
        "$path/"*) conflict=1; break ;;
      esac
    done
    if [ "$conflict" -eq 1 ]; then
      printf 'error: 本地未跟踪或被忽略路径与更新冲突，已中止更新：%s\n' "$path" >&2
      return 1
    fi
  done < <(git -C "$INSTALL_DIR" ls-files --others -z)
}

usage() {
  cat <<MSG
Usage: bootstrap.sh [install-global.sh 参数...]

从 \$SUPERSPECFLOW_REPO（默认 GitHub 官方仓库）的 \$SUPERSPECFLOW_BRANCH（默认 master）
拉取本包到 \$SUPERSPECFLOW_HOME（默认 ~/.superspecflow），然后执行 install-global.sh。

其余参数原样透传给 install-global.sh，例如:
  --claude-only / --codex-only / --antigravity-only / --both / --all
  --append / --yes / --no-hook
MSG
}

# --help 必须在本脚本内消化：install-global.sh 有自己的 --help 与目标选项，
# 透传过去会改变“仅打印帮助”的语义。
for arg in "$@"; do
  case "$arg" in
    -h|--help)
      usage
      exit 0
      ;;
  esac
done

if ! command -v git >/dev/null 2>&1; then
  echo "error: git not found in PATH，请先安装 git 再运行此脚本。" >&2
  exit 1
fi

if [ -e "$INSTALL_DIR" ] && [ ! -d "$INSTALL_DIR/.git" ]; then
  echo "error: $INSTALL_DIR 已存在但不是 git 仓库。" >&2
  echo "       请手动检查或移除后重试，脚本不会擅自删除目录。" >&2
  exit 1
fi

if [ -d "$INSTALL_DIR/.git" ]; then
  current_remote="$(git -C "$INSTALL_DIR" remote get-url origin 2>/dev/null || true)"
  if [ "${current_remote}" != "$REPO_URL" ]; then
    echo "error: $INSTALL_DIR 的 origin 是 ${current_remote:-<empty>}，与 $REPO_URL 不匹配。" >&2
    echo "       请手动处理后重试，脚本不会改写已有 remote。" >&2
    exit 1
  fi
  # 先拒绝已跟踪文件的本地改动；未跟踪及被忽略文件在 fetch 后按目标版本检查路径冲突。
  if [ -n "$(git -C "$INSTALL_DIR" status --porcelain -uno 2>/dev/null)" ]; then
    echo "error: $INSTALL_DIR 的已跟踪文件有未提交改动，已中止更新。" >&2
    echo "       请先自行处理这些改动（提交、转移或确认可丢弃），再重试：" >&2
    git -C "$INSTALL_DIR" status --porcelain -uno >&2 || true
    exit 1
  fi
  echo "→ updating existing checkout at $INSTALL_DIR"
  git -C "$INSTALL_DIR" fetch --depth=1 origin "$REPO_BRANCH"
  target_commit="$(git -C "$INSTALL_DIR" rev-parse --verify 'FETCH_HEAD^{commit}')"
  check_untracked_conflicts "$target_commit"
  # 直接切到已检查的提交，避免先切换到本地旧分支时写入另一组未检查的路径。
  git -C "$INSTALL_DIR" checkout -B "$REPO_BRANCH" "$target_commit"
else
  echo "→ cloning $REPO_URL into $INSTALL_DIR"
  git clone --depth=1 --branch "$REPO_BRANCH" "$REPO_URL" "$INSTALL_DIR"
fi

echo
echo "→ running install-global.sh $*"
echo
exec "$INSTALL_DIR/scripts/install-global.sh" "$@"
