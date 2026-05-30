#!/usr/bin/env bash
# 共享测试帮手。bats 测试用 `load '../lib/test_helper'` 引入。

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export REPO_ROOT

# 统一规范化 TMPDIR：去掉可能存在的结尾 `/`，避免在 macOS 上拼出 `//`。
ssf__tmpdir() {
  local d
  if [ "${TMPDIR+x}" = x ]; then
    d="$TMPDIR"
  else
    d="/tmp"
  fi

  while [ "${#d}" -gt 1 ] && [ "${d%/}" != "$d" ]; do
    d="${d%/}"
  done
  echo "$d"
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

ssf__physical_dir() {
  local dir="$1"
  [ -n "$dir" ] || return 1
  [ -d "$dir" ] || return 1
  (cd -P "$dir" 2>/dev/null && pwd -P)
}

ssf_cleanup_tmp() {
  local dir="$1"
  local tmp_root tmp_phys dir_phys dir_parent dir_base

  tmp_root="$(ssf__tmpdir)"
  tmp_phys="$(ssf__physical_dir "$tmp_root")" || {
    echo "拒绝清理可疑路径: $dir" >&2
    return 1
  }

  if [ "$tmp_phys" = "/" ]; then
    echo "拒绝清理可疑路径: $dir" >&2
    return 1
  fi

  dir_phys="$(ssf__physical_dir "$dir")" || {
    echo "拒绝清理可疑路径: $dir" >&2
    return 1
  }
  dir_parent="$(dirname "$dir_phys")"
  dir_base="$(basename "$dir_phys")"

  if [ "$dir_parent" != "$tmp_phys" ]; then
    echo "拒绝清理可疑路径: $dir" >&2
    return 1
  fi

  case "$dir_base" in
    ssf-home.*|ssf-proj.*) rm -rf "$dir" ;;
    *) echo "拒绝清理可疑路径: $dir" >&2; return 1 ;;
  esac
}

ssf_make_tmp_repo_fixture() {
  local fixture file target_dir
  fixture="$(ssf_make_tmp_project)"

  while IFS= read -r -d '' file; do
    [ -e "$REPO_ROOT/$file" ] || [ -L "$REPO_ROOT/$file" ] || continue
    target_dir="$(dirname "$fixture/$file")"
    mkdir -p "$target_dir"
    cp -p "$REPO_ROOT/$file" "$fixture/$file"
  done < <(cd "$REPO_ROOT" && git ls-files -co --exclude-standard -z)

  git -C "$fixture" init -q
  git -C "$fixture" add -A
  echo "$fixture"
}
