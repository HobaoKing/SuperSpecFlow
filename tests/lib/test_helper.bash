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

# 读取文件权限位（八进制，如 644）：GNU stat（Linux）用 -c '%a'，BSD stat（macOS）用 -f '%Lp'。
# 输入：$1 已存在文件路径；输出：权限位（stdout）。
# 约束：必须“先 GNU 后 BSD”——GNU stat 的 -f 是文件系统模式，会先把文件系统信息打印到 stdout
# 再非零退出，反着串联会把多行脏输出当成权限位，在 Linux 上让断言或 chmod 误判。
ssf_file_mode() {
  local mode
  if mode="$(stat -c '%a' "$1" 2>/dev/null)"; then
    printf '%s' "$mode"
    return 0
  fi
  stat -f '%Lp' "$1" 2>/dev/null || true
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

# 探测测试环境中可正常执行的 python3 命令，规避损坏的 pyenv shim 或架构不兼容。
# 输入：无；输出：输出可用的 python 命令名或路径（stdout）。
ssf_python_cmd() {
  local candidate
  for candidate in /usr/bin/python3 python3; do
    if command -v "$candidate" >/dev/null 2>&1 && "$candidate" -c 'exit(0)' >/dev/null 2>&1; then
      printf '%s' "$candidate"
      return 0
    fi
  done
  printf 'python3'
}
