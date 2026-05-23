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
