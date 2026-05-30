#!/usr/bin/env bats

load '../lib/test_helper'

@test "root instruction files are thin entries into centralized routing" {
  grep -q 'routing/AGENTS.routing.md' "$REPO_ROOT/AGENTS.md"
  grep -q 'routing/CLAUDE.routing.md' "$REPO_ROOT/CLAUDE.md"

  ! grep -q '| 类别 | 判定标准 | 处理方式 |' "$REPO_ROOT/AGENTS.md"
  ! grep -q '显式命令集合' "$REPO_ROOT/AGENTS.md"
  ! grep -q '/ssf-think <idea>' "$REPO_ROOT/AGENTS.md"

  ! grep -q 'Intake Gate 分类' "$REPO_ROOT/CLAUDE.md"
  ! grep -q '显式命令集合' "$REPO_ROOT/CLAUDE.md"
  ! grep -q '/ssf-think <idea>' "$REPO_ROOT/CLAUDE.md"
}

@test "validate-pack enforces thin root instruction entries" {
  grep -q 'check_root_instruction_files_thin' "$REPO_ROOT/scripts/validate-pack.sh"
}
