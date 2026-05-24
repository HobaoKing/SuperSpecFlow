#!/usr/bin/env bash
# SuperSpecFlow bootstrap installer.
# 远程拉取并安装 SuperSpecFlow，然后透传参数给 install-global.sh。
#
# 一句话安装:
#   curl -fsSL https://raw.githubusercontent.com/HobaoKing/SuperSpecFlow/master/scripts/bootstrap.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/HobaoKing/SuperSpecFlow/master/scripts/bootstrap.sh | bash -s -- --claude-only
#
# 环境变量:
#   SUPERSPECFLOW_HOME  本地安装路径（默认 ~/.superspecflow）

set -euo pipefail

REPO_URL="https://github.com/HobaoKing/SuperSpecFlow.git"
REPO_BRANCH="master"
INSTALL_DIR="${SUPERSPECFLOW_HOME:-$HOME/.superspecflow}"

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
