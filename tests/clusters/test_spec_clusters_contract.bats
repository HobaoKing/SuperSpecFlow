#!/usr/bin/env bats

load '../lib/test_helper'

@test "cluster runtime templates define plan status and integration gate" {
  [ -f "$REPO_ROOT/templates/cluster-plan.md" ]
  [ -f "$REPO_ROOT/templates/cluster-status.md" ]
  [ -f "$REPO_ROOT/templates/integration-gate.md" ]
  grep -q '.superspecflow/clusters/\[parent-change\]/cluster-plan.md' "$REPO_ROOT/templates/cluster-plan.md"
  grep -q '.superspecflow/clusters/\[parent-change\]/cluster-status.md' "$REPO_ROOT/templates/cluster-status.md"
  grep -q '.superspecflow/clusters/\[parent-change\]/integration-gate.md' "$REPO_ROOT/templates/integration-gate.md"
}

@test "skills expose cluster planning and parent gate rules" {
  grep -q 'Spec cluster' "$REPO_ROOT/skills/ssf-spec/SKILL.md"
  grep -q 'cluster-plan.md' "$REPO_ROOT/skills/ssf-build/SKILL.md"
  grep -q 'cluster-status.md' "$REPO_ROOT/skills/ssf-build/SKILL.md"
  grep -q 'worktree' "$REPO_ROOT/skills/ssf-git/SKILL.md"
  grep -q 'integration-gate.md' "$REPO_ROOT/skills/ssf-ship/SKILL.md"
  grep -q 'cluster QA evidence' "$REPO_ROOT/skills/ssf-qa/SKILL.md"
}

@test "release manager mirrors parent cluster ship gate rules" {
  grep -q 'integration-gate.md' "$REPO_ROOT/agents/release-manager.md"
  grep -q 'cluster QA' "$REPO_ROOT/agents/release-manager.md"
  grep -q 'review' "$REPO_ROOT/agents/release-manager.md"
  grep -q 'commit evidence' "$REPO_ROOT/agents/release-manager.md"
  grep -q '不得推荐 Ship' "$REPO_ROOT/agents/release-manager.md"
}

@test "ssf-ship does not auto-archive blocked recommendations" {
  grep -q 'Ship blocked by cluster integration gate' "$REPO_ROOT/skills/ssf-ship/SKILL.md"
  grep -q 'Ship blocked by Git hygiene' "$REPO_ROOT/skills/ssf-ship/SKILL.md"
  grep -q '只有 recommendation 为 `Ship` 或 `Ship with monitoring`' "$REPO_ROOT/skills/ssf-ship/SKILL.md"
}

@test "commands mention parent cluster QA and ship gates" {
  grep -q 'cluster' "$REPO_ROOT/commands/ssf-qa.md"
  grep -q 'integration-gate.md' "$REPO_ROOT/commands/ssf-ship.md"
}

@test "validate-pack checks spec cluster contract" {
  grep -q 'check_spec_cluster_contract' "$REPO_ROOT/scripts/validate-pack.sh"
}
