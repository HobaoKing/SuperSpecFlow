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

@test "Git gates reject docs/superpowers runtime artifacts" {
  grep -q 'docs/superpowers' "$REPO_ROOT/templates/git-hooks/commit-msg"
  grep -q 'docs/superpowers' "$REPO_ROOT/templates/commit-gate.md"
  grep -q 'docs/superpowers' "$REPO_ROOT/templates/git-checklist.md"
  grep -q 'docs/superpowers' "$REPO_ROOT/skills/ssf-git/SKILL.md"
  grep -q 'docs/superpowers' "$REPO_ROOT/commands/ssf-commit.md"
}

@test "OpenSpec change contracts remain tracked" {
  run git -C "$REPO_ROOT" ls-files openspec/changes/init-project-routing/proposal.md
  [ "$status" -eq 0 ]
  [ "$output" = "openspec/changes/init-project-routing/proposal.md" ]
}
