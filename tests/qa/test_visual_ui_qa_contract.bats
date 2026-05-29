#!/usr/bin/env bats

load '../lib/test_helper'

@test "visual QA runtime templates define plan report and evidence paths" {
  [ -f "$REPO_ROOT/templates/visual-execution-plan.md" ]
  [ -f "$REPO_ROOT/templates/visual-comparison-report.md" ]
  grep -q '.superspecflow/qa/\[change-id\]/visual-execution-plan.md' "$REPO_ROOT/templates/visual-execution-plan.md"
  grep -q '.superspecflow/qa/\[change-id\]/visual-comparison-report.md' "$REPO_ROOT/templates/visual-comparison-report.md"
  grep -q '.superspecflow/qa/\[change-id\]/qa-evidence/visual/' "$REPO_ROOT/templates/visual-comparison-report.md"
}

@test "visual QA templates expose comparable screenshot fields" {
  grep -q 'Platform: web | mini-program' "$REPO_ROOT/templates/visual-execution-plan.md"
  grep -q 'Baseline' "$REPO_ROOT/templates/visual-execution-plan.md"
  grep -q 'Actual Screenshot' "$REPO_ROOT/templates/visual-execution-plan.md"
  grep -q 'Optional Reference' "$REPO_ROOT/templates/visual-execution-plan.md"
  grep -q 'DPR' "$REPO_ROOT/templates/visual-execution-plan.md"
  grep -q 'Data Preconditions' "$REPO_ROOT/templates/visual-execution-plan.md"
  grep -q 'Diff Output' "$REPO_ROOT/templates/visual-comparison-report.md"
  grep -q 'Ignored Regions' "$REPO_ROOT/templates/visual-comparison-report.md"
  grep -q 'Manual Reviewer' "$REPO_ROOT/templates/visual-comparison-report.md"
  grep -q 'Redaction Check' "$REPO_ROOT/templates/visual-comparison-report.md"
}

@test "QA signoff template exposes controlled visual QA statuses" {
  grep -q 'Visual Passed' "$REPO_ROOT/templates/qa-signoff.md"
  grep -q 'Manual Visual Verified' "$REPO_ROOT/templates/qa-signoff.md"
  grep -q 'Visual Failed' "$REPO_ROOT/templates/qa-signoff.md"
  grep -q 'Blocked: Missing baseline' "$REPO_ROOT/templates/qa-signoff.md"
  grep -q 'Blocked: Missing actual screenshot' "$REPO_ROOT/templates/qa-signoff.md"
  grep -q 'Blocked: Diff tool unavailable' "$REPO_ROOT/templates/qa-signoff.md"
}

@test "ssf-qa skill and command require visual UI QA protocol" {
  grep -q 'visual-execution-plan.md' "$REPO_ROOT/skills/ssf-qa/SKILL.md"
  grep -q 'visual-comparison-report.md' "$REPO_ROOT/skills/ssf-qa/SKILL.md"
  grep -q 'platform: web | mini-program' "$REPO_ROOT/skills/ssf-qa/SKILL.md"
  grep -q 'Visual Passed' "$REPO_ROOT/skills/ssf-qa/SKILL.md"
  grep -q 'Manual Visual Verified' "$REPO_ROOT/skills/ssf-qa/SKILL.md"
  grep -q 'Blocked: Missing baseline' "$REPO_ROOT/skills/ssf-qa/SKILL.md"
  grep -q 'actual screenshot 自动提升为 baseline' "$REPO_ROOT/skills/ssf-qa/SKILL.md"
  grep -q 'visual-execution-plan.md' "$REPO_ROOT/commands/ssf-qa.md"
  grep -q 'visual-comparison-report.md' "$REPO_ROOT/commands/ssf-qa.md"
}

@test "qa-gatekeeper agent mirrors visual UI QA gate rules" {
  grep -q 'visual-execution-plan.md' "$REPO_ROOT/agents/qa-gatekeeper.md"
  grep -q 'visual-comparison-report.md' "$REPO_ROOT/agents/qa-gatekeeper.md"
  grep -q 'Visual Passed' "$REPO_ROOT/agents/qa-gatekeeper.md"
  grep -q 'Manual Visual Verified' "$REPO_ROOT/agents/qa-gatekeeper.md"
  grep -q 'Blocked: Missing actual screenshot' "$REPO_ROOT/agents/qa-gatekeeper.md"
  grep -q 'qa-evidence/visual' "$REPO_ROOT/agents/qa-gatekeeper.md"
  grep -q 'secret、token、凭据、生产客户数据、未脱敏个人信息' "$REPO_ROOT/agents/qa-gatekeeper.md"
}

@test "routing and README expose visual QA without binding concrete runners" {
  grep -q 'visual-execution-plan.md' "$REPO_ROOT/routing/AGENTS.routing.md"
  grep -q 'visual-comparison-report.md' "$REPO_ROOT/routing/AGENTS.routing.md"
  grep -q 'qa-evidence/visual' "$REPO_ROOT/routing/CLAUDE.routing.md"
  grep -q 'web | mini-program' "$REPO_ROOT/routing/CLAUDE.routing.md"
  grep -q 'visual-execution-plan.md' "$REPO_ROOT/README.md"
  grep -q 'visual-comparison-report.md' "$REPO_ROOT/README.md"
  ! grep -q 'WeChat DevTools' "$REPO_ROOT/skills/ssf-qa/SKILL.md" "$REPO_ROOT/agents/qa-gatekeeper.md" "$REPO_ROOT/templates/visual-execution-plan.md" "$REPO_ROOT/templates/visual-comparison-report.md"
}

@test "visual QA spec-to-code map records MUST NOT coverage" {
  grep -q 'SSF-QA-VISUAL-N1' "$REPO_ROOT/engineering/visual-ui-qa-adapter/spec-to-code-map.md"
  grep -q 'SSF-QA-VISUAL-N8' "$REPO_ROOT/engineering/visual-ui-qa-adapter/spec-to-code-map.md"
}

@test "validate-pack checks visual UI QA contract" {
  grep -q 'check_visual_ui_qa_contract' "$REPO_ROOT/scripts/validate-pack.sh"
}
