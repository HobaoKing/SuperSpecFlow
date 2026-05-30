#!/usr/bin/env bats

load '../lib/test_helper'

@test "risk matrix captures owner mitigation detection waiver and residual risk" {
  for term in Owner Mitigation Detection Waiver "Residual Risk"; do
    grep -q "$term" "$REPO_ROOT/templates/risk-matrix.md" || {
      echo "missing $term"
      return 1
    }
  done
}

@test "rollback and monitoring templates include drill and alert ownership fields" {
  grep -q 'Rollback Drill' "$REPO_ROOT/templates/rollback-plan.md"
  grep -q 'Decision Owner' "$REPO_ROOT/templates/rollback-plan.md"
  grep -q 'Detection Query' "$REPO_ROOT/templates/monitoring-plan.md"
  grep -q 'Alert Owner' "$REPO_ROOT/templates/monitoring-plan.md"
}

@test "validate-pack checks high risk release template fields" {
  grep -q 'check_high_risk_release_templates' "$REPO_ROOT/scripts/validate-pack.sh"
}
