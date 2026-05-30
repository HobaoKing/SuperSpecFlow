#!/usr/bin/env bats

load '../lib/test_helper'

@test "browser execution plan documents derivation from acceptance matrix" {
  grep -q 'Derivation Rules' "$REPO_ROOT/templates/qa-execution-plan.md"
  grep -q 'E2E' "$REPO_ROOT/templates/qa-execution-plan.md"
  grep -q 'user journey' "$REPO_ROOT/templates/qa-execution-plan.md"
  grep -q 'preserve Spec ID mapping' "$REPO_ROOT/templates/qa-execution-plan.md"
}

@test "visual execution plan documents visual-only derivation from acceptance matrix" {
  grep -q 'Derivation Rules' "$REPO_ROOT/templates/visual-execution-plan.md"
  grep -q 'UI restoration' "$REPO_ROOT/templates/visual-execution-plan.md"
  grep -q 'screenshot comparison' "$REPO_ROOT/templates/visual-execution-plan.md"
  grep -q 'preserve Spec ID mapping' "$REPO_ROOT/templates/visual-execution-plan.md"
}

@test "ssf-qa and qa-gatekeeper preserve acceptance matrix as source of truth" {
  grep -q 'preserve Spec ID mapping' "$REPO_ROOT/skills/ssf-qa/SKILL.md"
  grep -q 'preserve Spec ID mapping' "$REPO_ROOT/agents/qa-gatekeeper.md"
}
