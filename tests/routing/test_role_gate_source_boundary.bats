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

@test "runtime instructions do not present SuperSpecFlow as proprietary role gates" {
  bad_pattern='SuperSpecFlow 角色门禁|项目自有角色做门禁|项目自有门禁|SuperSpecFlow 的门禁|SuperSpecFlow 负责流程门禁|SuperSpecFlow 产品三重门禁'

  if grep -R -E "$bad_pattern" \
    "$REPO_ROOT/README.md" \
    "$REPO_ROOT/AGENTS.md" \
    "$REPO_ROOT/CLAUDE.md" \
    "$REPO_ROOT/routing" \
    "$REPO_ROOT/skills" \
    "$REPO_ROOT/commands" \
    "$REPO_ROOT/agents" \
    "$REPO_ROOT/docs/installation.md" \
    "$REPO_ROOT/docs/compatibility.md"; then
    return 1
  fi
}

@test "workflow docs define OpenSpec Superpowers and SuperSpecFlow layers" {
  for file in \
    "$REPO_ROOT/README.md" \
    "$REPO_ROOT/AGENTS.md" \
    "$REPO_ROOT/CLAUDE.md" \
    "$REPO_ROOT/routing/AGENTS.routing.md" \
    "$REPO_ROOT/routing/CLAUDE.routing.md"; do
    grep -q 'OpenSpec 合同层' "$file"
    grep -q 'Superpowers 执行纪律层' "$file"
    grep -q 'SuperSpecFlow 路由与适配层' "$file"
  done
}

@test "workflow docs define routing contract and discipline traceability" {
  for file in \
    "$REPO_ROOT/README.md" \
    "$REPO_ROOT/routing/AGENTS.routing.md" \
    "$REPO_ROOT/routing/CLAUDE.routing.md"; do
    grep -q '路由输入' "$file"
    grep -q '路由输出' "$file"
    grep -q '执行纪律选择记录' "$file"
  done
}

@test "validate-pack enforces layer and gstack attribution boundary" {
  grep -q 'check_gstack_attribution_boundary' "$REPO_ROOT/scripts/validate-pack.sh"
  grep -q 'check_superspecflow_layer_boundary' "$REPO_ROOT/scripts/validate-pack.sh"
}
