#!/usr/bin/env bats

load '../lib/test_helper'

@test "visual QA templates require comparable evidence for Visual Passed" {
  grep -q 'Visual Pass Consistency Check' "$REPO_ROOT/templates/qa-signoff.md"
  grep -q 'Baseline approval required for `Visual Passed`' "$REPO_ROOT/templates/visual-comparison-report.md"
  grep -q 'Actual screenshot required for `Visual Passed`' "$REPO_ROOT/templates/visual-comparison-report.md"
  grep -q 'Diff output or threshold result required for `Visual Passed`' "$REPO_ROOT/templates/visual-comparison-report.md"
}

@test "manual visual verification requires reviewer evidence" {
  grep -q 'Manual Visual Verification Check' "$REPO_ROOT/templates/qa-signoff.md"
  grep -q 'Accepted Differences' "$REPO_ROOT/templates/visual-comparison-report.md"
  grep -q 'Manual reviewer required for `Manual Visual Verified`' "$REPO_ROOT/skills/ssf-qa/SKILL.md"
  grep -q 'Manual reviewer required for `Manual Visual Verified`' "$REPO_ROOT/agents/qa-gatekeeper.md"
}

@test "validate-pack checks visual QA state consistency contract" {
  grep -q 'Visual Pass Consistency Check' "$REPO_ROOT/scripts/validate-pack.sh"
}
