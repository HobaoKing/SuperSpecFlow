#!/usr/bin/env bats

load '../lib/test_helper'

@test "REPO_ROOT 指向仓库根" {
  [ -f "$REPO_ROOT/CLAUDE.md" ]
  [ -d "$REPO_ROOT/routing" ]
}

@test "ssf_make_tmp_home 创建可写目录并含 .claude / .codex" {
  home="$(ssf_make_tmp_home)"
  [ -d "$home/.claude" ]
  [ -d "$home/.codex" ]
  ssf_cleanup_tmp "$home"
}

@test "ssf_cleanup_tmp accepts helper dirs under custom TMPDIR with spaces and trailing slash" {
  local root old_tmpdir had_tmpdir project home
  root="$(mktemp -d "${TMPDIR:-/tmp}/ssf tmp.XXXXXX")"
  if [ "${TMPDIR+x}" = x ]; then
    had_tmpdir=1
    old_tmpdir="$TMPDIR"
  else
    had_tmpdir=0
    old_tmpdir=
  fi

  TMPDIR="$root/"
  export TMPDIR
  project="$(ssf_make_tmp_project)"
  home="$(ssf_make_tmp_home)"

  [[ "$project" == "$root"/ssf-proj.* ]]
  [[ "$home" == "$root"/ssf-home.* ]]

  ssf_cleanup_tmp "$project"
  ssf_cleanup_tmp "$home"
  [ ! -e "$project" ]
  [ ! -e "$home" ]

  if [ "$had_tmpdir" -eq 1 ]; then
    TMPDIR="$old_tmpdir"
    export TMPDIR
  else
    unset TMPDIR
  fi
  rmdir "$root"
}

@test "ssf_cleanup_tmp refuses suspicious paths and preserves sentinels" {
  local root outside nonhelper sibling_escape traversal_escape sentinel
  root="$(mktemp -d "${TMPDIR:-/tmp}/ssf tmp.XXXXXX")"
  outside="$(mktemp -d "${TMPDIR:-/tmp}/ssf-outside.XXXXXX")"
  nonhelper="$root/not-ssf-home.x"
  sibling_escape="${root}-extra/ssf-home.escape"
  traversal_escape="$root/../$(basename "$outside")/ssf-home.escape"
  mkdir -p "$nonhelper" "${root}-extra" "$sibling_escape" "$traversal_escape"
  sentinel="$outside/ssf-home.escape/sentinel"
  mkdir -p "$(dirname "$sentinel")"
  printf 'keep\n' > "$sentinel"

  TMPDIR="$root/"
  export TMPDIR

  run ssf_cleanup_tmp ""
  [ "$status" -ne 0 ]

  run ssf_cleanup_tmp "/"
  [ "$status" -ne 0 ]

  run ssf_cleanup_tmp "$REPO_ROOT"
  [ "$status" -ne 0 ]

  run ssf_cleanup_tmp "$outside/ssf-home.escape"
  [ "$status" -ne 0 ]

  run ssf_cleanup_tmp "$nonhelper"
  [ "$status" -ne 0 ]
  [ -d "$nonhelper" ]

  run ssf_cleanup_tmp "$sibling_escape"
  [ "$status" -ne 0 ]
  [ -d "$sibling_escape" ]

  run ssf_cleanup_tmp "$traversal_escape"
  [ "$status" -ne 0 ]
  [ -f "$sentinel" ]

  rm -rf "$root" "${root}-extra" "$outside"
}

@test "ssf_cleanup_tmp refuses invalid active TMPDIR values" {
  local root target file_tmp missing_tmp
  root="$(mktemp -d "${TMPDIR:-/tmp}/ssf-invalid-tmp.XXXXXX")"
  target="$root/ssf-home.keep"
  mkdir -p "$target"
  printf 'keep\n' > "$target/sentinel"
  file_tmp="$root/not-a-dir"
  missing_tmp="$root/missing"
  printf 'file\n' > "$file_tmp"

  TMPDIR=""
  export TMPDIR
  run ssf_cleanup_tmp "$target"
  [ "$status" -ne 0 ]
  [ -f "$target/sentinel" ]

  TMPDIR="/"
  export TMPDIR
  run ssf_cleanup_tmp "$target"
  [ "$status" -ne 0 ]
  [ -f "$target/sentinel" ]

  TMPDIR="$file_tmp"
  export TMPDIR
  run ssf_cleanup_tmp "$target"
  [ "$status" -ne 0 ]
  [ -f "$target/sentinel" ]

  TMPDIR="$missing_tmp"
  export TMPDIR
  run ssf_cleanup_tmp "$target"
  [ "$status" -ne 0 ]
  [ -f "$target/sentinel" ]

  rm -rf "$root"
}

@test "ssf_make_tmp_repo_fixture preserves git ignore and tracked-file semantics" {
  local fixture
  fixture="$(ssf_make_tmp_repo_fixture)"

  run git -C "$fixture" check-ignore .superspecflow/test-ignore
  [ "$status" -eq 0 ]

  run git -C "$fixture" check-ignore openspec
  [ "$status" -ne 0 ]

  run git -C "$fixture" ls-files engineering/progress-tracking
  [ "$status" -eq 0 ]
  [[ "$output" == *"engineering/progress-tracking/"* ]]

  run bash "$fixture/scripts/validate-pack.sh"
  [ "$status" -eq 0 ]

  ssf_cleanup_tmp "$fixture"
}
