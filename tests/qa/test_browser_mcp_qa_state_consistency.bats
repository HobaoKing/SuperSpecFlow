#!/usr/bin/env bats

load '../lib/test_helper'

@test "browser QA templates require consistency between pass status and evidence" {
  grep -q 'Pass Consistency Check' "$REPO_ROOT/templates/qa-signoff.md"
  grep -q 'Missing target requires `Blocked: No runnable target`' "$REPO_ROOT/templates/browser-run-report.md"
  grep -q 'Tool unavailable requires `Blocked: Tool unavailable`' "$REPO_ROOT/templates/browser-run-report.md"
  grep -q 'Failed journey forbids `Automated Browser Passed`' "$REPO_ROOT/templates/browser-run-report.md"
}

@test "ssf-qa and qa-gatekeeper forbid false browser pass states" {
  grep -q 'Failed journey forbids `Automated Browser Passed`' "$REPO_ROOT/skills/ssf-qa/SKILL.md"
  grep -q 'Missing target requires `Blocked: No runnable target`' "$REPO_ROOT/skills/ssf-qa/SKILL.md"
  grep -q 'Tool unavailable requires `Blocked: Tool unavailable`' "$REPO_ROOT/agents/qa-gatekeeper.md"
  grep -q 'browser pass consistency' "$REPO_ROOT/routing/AGENTS.routing.md"
}

@test "validate-pack checks browser QA state consistency contract" {
  grep -q 'check_qa_evidence_consistency_contract' "$REPO_ROOT/scripts/validate-pack.sh"
  grep -q 'Pass Consistency Check' "$REPO_ROOT/scripts/validate-pack.sh"
}
