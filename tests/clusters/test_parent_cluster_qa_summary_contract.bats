#!/usr/bin/env bats

load '../lib/test_helper'

@test "integration gate template records cluster QA status details" {
  grep -q 'Browser QA Status' "$REPO_ROOT/templates/integration-gate.md"
  grep -q 'Visual QA Status' "$REPO_ROOT/templates/integration-gate.md"
  grep -q 'Manual QA Status' "$REPO_ROOT/templates/integration-gate.md"
  grep -q 'Blocked Reason' "$REPO_ROOT/templates/integration-gate.md"
  grep -q 'Parent Integration Regression' "$REPO_ROOT/templates/integration-gate.md"
}

@test "QA and ship instructions block parent ship when cluster evidence is missing" {
  grep -q 'Parent Integration Regression' "$REPO_ROOT/skills/ssf-qa/SKILL.md"
  grep -q 'missing cluster QA evidence blocks Ship' "$REPO_ROOT/skills/ssf-ship/SKILL.md"
  grep -q 'missing cluster QA evidence blocks Ship' "$REPO_ROOT/agents/release-manager.md"
}
