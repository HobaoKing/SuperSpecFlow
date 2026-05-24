#!/usr/bin/env bats

load '../lib/test_helper'

@test "Git tracked files exclude runtime and install artifacts" {
  run git -C "$REPO_ROOT" ls-files
  [ "$status" -eq 0 ]

  if printf '%s\n' "$output" | grep -Eq '^(superpowers|\.superspecflow|\.claude|\.codex)/|(^|/)\.DS_Store$'; then
    printf '%s\n' "$output" | grep -E '^(superpowers|\.superspecflow|\.claude|\.codex)/|(^|/)\.DS_Store$' >&2
    return 1
  fi
}

@test "OpenSpec change contracts remain tracked" {
  run git -C "$REPO_ROOT" ls-files openspec/changes/init-project-routing/proposal.md
  [ "$status" -eq 0 ]
  [ "$output" = "openspec/changes/init-project-routing/proposal.md" ]
}
