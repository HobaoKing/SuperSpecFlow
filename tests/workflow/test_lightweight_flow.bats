#!/usr/bin/env bats
load '../lib/test_helper'

@test "活动入口没有恢复旧版强制合同和阶段门禁" {
  run grep -REn 'No Spec ID, no|无 change-id / Spec ID 的行为变更不提交|每个行为变更和实现必须映射到 Spec ID|先读取 OpenSpec change|必须有 OpenSpec change-id|superpowers:writing-plans|Plan Review Loop 不可用' \
    "$REPO_ROOT/routing" "$REPO_ROOT/skills" "$REPO_ROOT/commands"
  [ "$status" -eq 1 ]
}

@test "技能参考在安装目录内可解析并带来源授权" {
  for ref in ssf-build/references/tdd.md ssf-build/references/diagnosing-bugs.md ssf-review/references/code-review.md; do
    [ -s "$REPO_ROOT/skills/$ref" ]
    grep -q 'c55ee46073ed923f86ce59a5eb3b6d895095d1b7' "$REPO_ROOT/skills/$ref"
  done
  for skill in ssf-build ssf-review; do
    grep -q 'Copyright (c) 2026 Matt Pocock' "$REPO_ROOT/skills/$skill/references/mattpocock-LICENSE.txt"
  done
  [ -s "$REPO_ROOT/skills/ssf-build/references/karpathy.md" ]
  grep -q 'multica-ai/andrej-karpathy-skills' "$REPO_ROOT/skills/ssf-build/references/karpathy.md"
}

@test "包不提供旧命令别名或历史模板兼容层" {
  [ ! -e "$REPO_ROOT/templates/legacy" ]
  [ ! -e "$REPO_ROOT/scripts/new-change.sh" ]
  [ ! -e "$REPO_ROOT/scripts/install-project-symlinks.sh" ]
  for name in spec map decision archive retro karpathy branch commit pr; do
    [ ! -e "$REPO_ROOT/commands/ssf-$name.md" ]
  done
  [ -f "$REPO_ROOT/commands/ssf-plan.md" ]
  [ -x "$REPO_ROOT/scripts/new-plan.sh" ]
}
