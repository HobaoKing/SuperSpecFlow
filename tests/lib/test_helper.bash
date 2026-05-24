#!/usr/bin/env bash
# 共享测试帮手。bats 测试用 `load '../lib/test_helper'` 引入。

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export REPO_ROOT

# 统一规范化 TMPDIR：去掉可能存在的结尾 `/`，避免在 macOS 上拼出 `//`。
ssf__tmpdir() {
  local d="${TMPDIR:-/tmp}"
  echo "${d%/}"
}

# 创建隔离的临时 HOME，避免污染用户环境。
ssf_make_tmp_home() {
  local tmp
  tmp="$(mktemp -d "$(ssf__tmpdir)/ssf-home.XXXXXX")"
  mkdir -p "$tmp/.claude" "$tmp/.codex"
  echo "$tmp"
}

# 创建一个临时 project 目录。
ssf_make_tmp_project() {
  mktemp -d "$(ssf__tmpdir)/ssf-proj.XXXXXX"
}

ssf_cleanup_tmp() {
  local dir="$1"
  case "$dir" in
    /tmp/ssf-*|/var/folders/*/T/ssf-*) rm -rf "$dir" ;;
    *) echo "拒绝清理可疑路径: $dir" >&2; return 1 ;;
  esac
}
