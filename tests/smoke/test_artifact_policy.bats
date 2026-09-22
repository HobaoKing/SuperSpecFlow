#!/usr/bin/env bats

load '../lib/test_helper'

@test "Git tracked files exclude runtime and install artifacts" {
  run git -C "$REPO_ROOT" ls-files
  [ "$status" -eq 0 ]

  if printf '%s\n' "$output" | grep -Eq '^(superpowers|docs/superpowers|\.superspecflow|\.claude|\.codex)/|(^|/)\.DS_Store$'; then
    printf '%s\n' "$output" | grep -E '^(superpowers|docs/superpowers|\.superspecflow|\.claude|\.codex)/|(^|/)\.DS_Store$' >&2
    return 1
  fi
}

@test "可复用技能和路由不携带源码仓库的提交忽略策略" {
  run grep -REn 'docs/superpowers|本仓库不提交|运行时产物|gitignore' \
    "$REPO_ROOT/skills" "$REPO_ROOT/commands" "$REPO_ROOT/routing"
  [ "$status" -eq 1 ]
}
