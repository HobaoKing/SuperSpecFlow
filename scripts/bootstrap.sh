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
  # 更新前拒绝脏工作区：reset --hard 会无声丢弃用户对已跟踪文件的本地改动（例如自建的
  # routing 覆盖或调试脚本）。只用 -uno 判定——未跟踪文件不会被 reset --hard 删除，
  # macOS 上 Finder 留下的 .DS_Store 之类的未跟踪文件不该阻断更新。
  if [ -n "$(git -C "$INSTALL_DIR" status --porcelain -uno 2>/dev/null)" ]; then
    echo "error: $INSTALL_DIR 的已跟踪文件有未提交改动，已中止更新。" >&2
    echo "       请先自行处理这些改动（提交、转移或确认可丢弃），再重试：" >&2
    git -C "$INSTALL_DIR" status --porcelain -uno >&2 || true
    exit 1
  fi
  echo "→ updating existing checkout at $INSTALL_DIR"
  git -C "$INSTALL_DIR" fetch --depth=1 origin "$REPO_BRANCH"
  git -C "$INSTALL_DIR" checkout "$REPO_BRANCH"
  git -C "$INSTALL_DIR" reset --hard "origin/$REPO_BRANCH"
else
  echo "→ cloning $REPO_URL into $INSTALL_DIR"
  git clone --depth=1 --branch "$REPO_BRANCH" "$REPO_URL" "$INSTALL_DIR"
fi

echo
echo "→ running install-global.sh $*"
echo
exec "$INSTALL_DIR/scripts/install-global.sh" "$@"
