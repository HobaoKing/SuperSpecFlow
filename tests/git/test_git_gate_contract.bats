#!/usr/bin/env bats

load '../lib/test_helper'

@test "ssf-build implementation plan does not embed direct git commit" {
  ! grep -q 'git commit -m' "$REPO_ROOT/skills/ssf-build/SKILL.md"
  grep -q '/ssf-commit \[change-id\]' "$REPO_ROOT/skills/ssf-build/SKILL.md"
  grep -q 'git diff --check' "$REPO_ROOT/skills/ssf-build/SKILL.md"
}

@test "ssf-spec commit example uses allowed conventional type and openspec scope" {
  grep -q 'spec(openspec:members): 建立续费提醒变更合同' "$REPO_ROOT/skills/ssf-spec/SKILL.md"
  ! grep -q '^规格(会员):' "$REPO_ROOT/skills/ssf-spec/SKILL.md"
}

@test "root instruction files include openspec as a valid commit scope" {
  grep -q 'openspec' "$REPO_ROOT/AGENTS.md"
  grep -q 'openspec' "$REPO_ROOT/CLAUDE.md"
}
