#!/usr/bin/env bats

load '../lib/test_helper'

@test "runtime instructions do not present gstack as execution style" {
  bad_pattern='gstack 风格|gstack 能力|本阶段体现 gstack|gstack 的发布门禁|gstack 三重审判|gstack 的 Release Manager'

  if grep -R -E "$bad_pattern" \
    "$REPO_ROOT/AGENTS.md" \
    "$REPO_ROOT/CLAUDE.md" \
    "$REPO_ROOT/routing" \
    "$REPO_ROOT/skills" \
    "$REPO_ROOT/commands" \
    "$REPO_ROOT/agents"; then
    return 1
  fi
}

@test "source attribution may mention gstack only outside runtime guidance" {
  grep -q 'gstack' "$REPO_ROOT/NOTICE.md"
  grep -q '设计来源' "$REPO_ROOT/README.md"
  grep -q 'gstack' "$REPO_ROOT/README.md"
}

@test "workflow docs keep SuperSpecFlow-owned role gate language" {
  grep -q 'SuperSpecFlow 角色门禁' "$REPO_ROOT/README.md"
  grep -q 'SuperSpecFlow 角色门禁' "$REPO_ROOT/routing/AGENTS.routing.md"
  grep -q 'SuperSpecFlow 角色门禁' "$REPO_ROOT/routing/CLAUDE.routing.md"
}

@test "validate-pack enforces gstack attribution boundary" {
  grep -q 'check_gstack_attribution_boundary' "$REPO_ROOT/scripts/validate-pack.sh"
}
