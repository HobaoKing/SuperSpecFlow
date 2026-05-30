#!/usr/bin/env bats

load '../lib/test_helper'

@test "implementation plan template uses strong Superpowers writing plan structure" {
  grep -q '\*\*Goal:\*\*' "$REPO_ROOT/templates/implementation-plan.md"
  grep -q '\*\*Architecture:\*\*' "$REPO_ROOT/templates/implementation-plan.md"
  grep -q '\*\*Spec Contract:\*\*' "$REPO_ROOT/templates/implementation-plan.md"
  grep -q '\*\*Tech Stack:\*\*' "$REPO_ROOT/templates/implementation-plan.md"
  grep -q '## Scope Check' "$REPO_ROOT/templates/implementation-plan.md"
  grep -q '## File Structure' "$REPO_ROOT/templates/implementation-plan.md"
  grep -q '## Bite-Sized Tasks' "$REPO_ROOT/templates/implementation-plan.md"
  grep -q '## Plan Review Loop' "$REPO_ROOT/templates/implementation-plan.md"
  grep -q '## Execution Handoff' "$REPO_ROOT/templates/implementation-plan.md"
}

@test "implementation plan template requires executable TDD five steps" {
  grep -q 'Step 1: 写失败测试' "$REPO_ROOT/templates/implementation-plan.md"
  grep -q 'Expected: FAIL with' "$REPO_ROOT/templates/implementation-plan.md"
  grep -q 'Step 3: 写最小实现' "$REPO_ROOT/templates/implementation-plan.md"
  grep -q 'Expected: PASS' "$REPO_ROOT/templates/implementation-plan.md"
  grep -q '/ssf-commit \[change-id\]' "$REPO_ROOT/templates/implementation-plan.md"
}

@test "build command agent and routing require plan review loop" {
  grep -q 'Plan Review Loop' "$REPO_ROOT/commands/ssf-build.md"
  grep -q 'Expected: FAIL with' "$REPO_ROOT/commands/ssf-build.md"
  grep -q 'Plan Review Loop' "$REPO_ROOT/agents/implementation-engineer.md"
  grep -q 'Bite-Sized Tasks' "$REPO_ROOT/routing/AGENTS.routing.md"
  grep -q 'Execution Handoff' "$REPO_ROOT/routing/CLAUDE.routing.md"
  grep -q 'Superpowers writing-plans' "$REPO_ROOT/README.md"
}

@test "validate-pack enforces implementation plan contract" {
  grep -q 'check_superpowers_implementation_plan_contract' "$REPO_ROOT/scripts/validate-pack.sh"
}
