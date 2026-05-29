#!/usr/bin/env bats

load '../lib/test_helper'

@test "browser QA runtime templates define execution plan and run report" {
  [ -f "$REPO_ROOT/templates/qa-execution-plan.md" ]
  [ -f "$REPO_ROOT/templates/browser-run-report.md" ]
  grep -q '.superspecflow/qa/\[change-id\]/qa-execution-plan.md' "$REPO_ROOT/templates/qa-execution-plan.md"
  grep -q '.superspecflow/qa/\[change-id\]/browser-run-report.md' "$REPO_ROOT/templates/browser-run-report.md"
  grep -q 'qa-evidence' "$REPO_ROOT/templates/browser-run-report.md"
}

@test "QA signoff template exposes controlled browser QA statuses" {
  grep -q 'Automated Browser Passed' "$REPO_ROOT/templates/qa-signoff.md"
  grep -q 'Manual Verified' "$REPO_ROOT/templates/qa-signoff.md"
  grep -q 'Blocked: No runnable target' "$REPO_ROOT/templates/qa-signoff.md"
  grep -q 'Blocked: Tool unavailable' "$REPO_ROOT/templates/qa-signoff.md"
  grep -q 'Failed' "$REPO_ROOT/templates/qa-signoff.md"
  ! grep -q 'Status: Pending' "$REPO_ROOT/templates/qa-signoff.md"
}

@test "ssf-qa skill and command require evidence-backed browser QA" {
  grep -q 'qa-execution-plan.md' "$REPO_ROOT/skills/ssf-qa/SKILL.md"
  grep -q 'browser-run-report.md' "$REPO_ROOT/skills/ssf-qa/SKILL.md"
  grep -q 'Blocked: No runnable target' "$REPO_ROOT/skills/ssf-qa/SKILL.md"
  grep -q 'Blocked: Tool unavailable' "$REPO_ROOT/skills/ssf-qa/SKILL.md"
  grep -q 'qa-execution-plan.md' "$REPO_ROOT/commands/ssf-qa.md"
  grep -q 'browser-run-report.md' "$REPO_ROOT/commands/ssf-qa.md"
}

@test "qa-gatekeeper agent mirrors browser QA gate rules" {
  grep -q 'qa-execution-plan.md' "$REPO_ROOT/agents/qa-gatekeeper.md"
  grep -q 'browser-run-report.md' "$REPO_ROOT/agents/qa-gatekeeper.md"
  grep -q 'Blocked: No runnable target' "$REPO_ROOT/agents/qa-gatekeeper.md"
  grep -q 'Blocked: Tool unavailable' "$REPO_ROOT/agents/qa-gatekeeper.md"
  grep -q 'qa-evidence' "$REPO_ROOT/agents/qa-gatekeeper.md"
}

@test "validate-pack checks browser MCP QA contract" {
  grep -q 'check_browser_mcp_qa_contract' "$REPO_ROOT/scripts/validate-pack.sh"
}
