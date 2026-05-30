#!/usr/bin/env bats

load '../lib/test_helper'

setup() {
  TMP_PROJECT="$(ssf_make_tmp_project)"
}

teardown() {
  ssf_cleanup_tmp "$TMP_PROJECT"
}

@test "commit message validator rejects missing traceability fields" {
  msg="$TMP_PROJECT/msg.txt"
  cat > "$msg" <<'MSG'
feat(skills:test): 增加测试能力

变更内容：
- 增加测试。
MSG

  run "$REPO_ROOT/scripts/validate-commit-message.sh" "$msg"
  [ "$status" -ne 0 ]
  [[ "$output" == *"变更编号"* ]] || [[ "$stderr" == *"变更编号"* ]]
}

@test "commit message validator accepts complete Chinese traceability body" {
  msg="$TMP_PROJECT/msg.txt"
  cat > "$msg" <<'MSG'
feat(skills:test): 增加测试能力

变更编号：runtime-gate-validators
关联规格：SSF-RUNTIME-GATE-001

变更内容：
- 增加提交信息校验。

验证方式：
- rtk bats tests/validators/test_runtime_validators.bats

风险与回滚：
- 风险较低，可回滚脚本变更。
MSG

  run "$REPO_ROOT/scripts/validate-commit-message.sh" "$msg"
  [ "$status" -eq 0 ]
}

@test "commit message validator rejects titles without scope" {
  msg="$TMP_PROJECT/msg.txt"
  cat > "$msg" <<'MSG'
feat: 增加测试能力

变更编号：runtime-gate-validators
关联规格：SSF-RUNTIME-GATE-001

变更内容：
- 增加提交信息校验。

验证方式：
- rtk bats tests/validators/test_runtime_validators.bats

风险与回滚：
- 风险较低，可回滚脚本变更。
MSG

  run "$REPO_ROOT/scripts/validate-commit-message.sh" "$msg"
  [ "$status" -ne 0 ]
  [[ "$output" == *"英文范围"* ]] || [[ "$stderr" == *"英文范围"* ]]
}

@test "commit message validator avoids locale-dependent CJK grep ranges" {
  ! grep -q '\[一-龥\]' "$REPO_ROOT/scripts/validate-commit-message.sh"
  ! grep -q '\[一-龥\]' "$REPO_ROOT/templates/git-hooks/commit-msg"
  grep -q 'has_non_ascii_text' "$REPO_ROOT/scripts/validate-commit-message.sh"
  grep -q 'has_non_ascii_text' "$REPO_ROOT/templates/git-hooks/commit-msg"
}

@test "QA signoff validator rejects blocked status that still recommends ship without waiver" {
  signoff="$TMP_PROJECT/qa-signoff.md"
  cat > "$signoff" <<'MD'
# QA Signoff: demo

## Browser / MCP QA Status
- Status: Blocked: No runnable target

## Recommendation
- Ship with monitoring
MD

  run "$REPO_ROOT/scripts/validate-qa-signoff.sh" "$signoff"
  [ "$status" -ne 0 ]
  [[ "$output" == *"waiver"* ]] || [[ "$stderr" == *"waiver"* ]]
}

@test "QA signoff validator accepts blocked ship recommendation with explicit waiver" {
  signoff="$TMP_PROJECT/qa-signoff.md"
  cat > "$signoff" <<'MD'
# QA Signoff: demo

## Browser / MCP QA Status
- Status: Blocked: No runnable target

## Blocked Waiver
- Waiver: protocol-only change has no runnable target.
- Approved By: reviewer
- Residual Risk: concrete browser runner deferred.

## Recommendation
- Ship with monitoring
MD

  run "$REPO_ROOT/scripts/validate-qa-signoff.sh" "$signoff"
  [ "$status" -eq 0 ]
}

@test "QA signoff validator rejects Automated Browser Passed without evidence fields" {
  signoff="$TMP_PROJECT/qa-signoff.md"
  cat > "$signoff" <<'MD'
# QA Signoff: demo

## Browser / MCP QA Status
- Status: Automated Browser Passed

## Recommendation
- Ship
MD

  run "$REPO_ROOT/scripts/validate-qa-signoff.sh" "$signoff"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Browser Run Report"* ]] || [[ "$stderr" == *"Browser Run Report"* ]]
}

@test "QA signoff validator rejects Automated Browser Passed with evidence but no browser run report" {
  signoff="$TMP_PROJECT/qa-signoff.md"
  cat > "$signoff" <<'MD'
# QA Signoff: demo

## Browser / MCP QA Status
- Status: Automated Browser Passed
- Evidence: .superspecflow/qa/demo/qa-evidence/

## Recommendation
- Ship
MD

  run "$REPO_ROOT/scripts/validate-qa-signoff.sh" "$signoff"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Browser Run Report"* ]] || [[ "$stderr" == *"Browser Run Report"* ]]
}

@test "QA signoff validator accepts Automated Browser Passed with report and evidence" {
  signoff="$TMP_PROJECT/qa-signoff.md"
  cat > "$signoff" <<'MD'
# QA Signoff: demo

## Browser / MCP QA Status
- Status: Automated Browser Passed
- Browser Run Report: .superspecflow/qa/demo/browser-run-report.md
- Evidence: .superspecflow/qa/demo/qa-evidence/

## Recommendation
- Ship
MD

  run "$REPO_ROOT/scripts/validate-qa-signoff.sh" "$signoff"
  [ "$status" -eq 0 ]
}
