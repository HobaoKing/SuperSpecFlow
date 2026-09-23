#!/usr/bin/env bats

load '../lib/test_helper'

@test "root instruction files are thin entries into centralized routing" {
  grep -q 'routing/AGENTS.routing.md' "$REPO_ROOT/AGENTS.md"
  grep -q 'routing/CLAUDE.routing.md' "$REPO_ROOT/CLAUDE.md"
  grep -q 'routing/GEMINI.routing.md' "$REPO_ROOT/GEMINI.md"

  ! grep -q '| 类别 | 判定标准 | 处理方式 |' "$REPO_ROOT/AGENTS.md"
  ! grep -q '显式命令集合' "$REPO_ROOT/AGENTS.md"
  ! grep -q '/ssf-think <idea>' "$REPO_ROOT/AGENTS.md"

  ! grep -q 'Intake Gate 分类' "$REPO_ROOT/CLAUDE.md"
  ! grep -q '显式命令集合' "$REPO_ROOT/CLAUDE.md"
  ! grep -q '/ssf-think <idea>' "$REPO_ROOT/CLAUDE.md"

  ! grep -q '显式命令集合' "$REPO_ROOT/GEMINI.md"
  ! grep -q '/ssf-think <idea>' "$REPO_ROOT/GEMINI.md"
}

@test "三个根入口正文一致，仅 include 行不同" {
  agents_body="$(tail -n +2 "$REPO_ROOT/AGENTS.md")"
  claude_body="$(tail -n +2 "$REPO_ROOT/CLAUDE.md")"
  gemini_body="$(tail -n +2 "$REPO_ROOT/GEMINI.md")"
  [ "$agents_body" = "$claude_body" ]
  [ "$agents_body" = "$gemini_body" ]
}

@test "validate-pack enforces thin root instruction entries" {
  grep -q 'check_root_instruction_files_thin' "$REPO_ROOT/scripts/validate-pack.sh"
}

@test "public routing files are materialized from canonical routing source" {
  [ -f "$REPO_ROOT/routing/default.routing.md" ]
  [ ! -L "$REPO_ROOT/routing/default.routing.md" ]
  [ ! -L "$REPO_ROOT/routing/AGENTS.routing.md" ]
  [ ! -L "$REPO_ROOT/routing/CLAUDE.routing.md" ]
  [ ! -L "$REPO_ROOT/routing/GEMINI.routing.md" ]

  cmp -s "$REPO_ROOT/routing/default.routing.md" "$REPO_ROOT/routing/AGENTS.routing.md"
  cmp -s "$REPO_ROOT/routing/default.routing.md" "$REPO_ROOT/routing/CLAUDE.routing.md"
  cmp -s "$REPO_ROOT/routing/default.routing.md" "$REPO_ROOT/routing/GEMINI.routing.md"
}

@test "validate-pack enforces canonical routing drift guard" {
  grep -q 'routing/default.routing.md' "$REPO_ROOT/scripts/validate-pack.sh"
  grep -q 'public routing files match canonical' "$REPO_ROOT/scripts/validate-pack.sh"
}
