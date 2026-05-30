#!/usr/bin/env bats

load '../lib/test_helper'

setup() {
  FIXTURE_REPO="$(ssf_make_tmp_repo_fixture)"
}

teardown() {
  ssf_cleanup_tmp "$FIXTURE_REPO"
}

remove_lines_containing() {
  local file="$1"
  local marker="$2"
  local tmp_file="$file.tmp"

  awk -v marker="$marker" 'index($0, marker) == 0 { print }' "$file" > "$tmp_file"
  mv "$tmp_file" "$file"
}

@test "validate-pack reports multiple browser QA missing predicates" {
  remove_lines_containing \
    "$FIXTURE_REPO/templates/qa-execution-plan.md" \
    '.superspecflow/qa/[change-id]/qa-execution-plan.md'
  remove_lines_containing \
    "$FIXTURE_REPO/templates/qa-signoff.md" \
    'Automated Browser Passed'

  run "$FIXTURE_REPO/scripts/validate-pack.sh"

  [ "$status" -eq 1 ]
  [[ "$output" == *"FAIL: qa-execution-plan template 缺少 runtime 路径"* ]]
  [[ "$output" == *"FAIL: qa-signoff template 缺少 browser QA 状态枚举"* ]]
}

@test "validate-pack reports multiple visual QA missing predicates" {
  remove_lines_containing \
    "$FIXTURE_REPO/templates/visual-execution-plan.md" \
    'Platform: web | mini-program'
  remove_lines_containing \
    "$FIXTURE_REPO/templates/qa-signoff.md" \
    'Visual Passed'

  run "$FIXTURE_REPO/scripts/validate-pack.sh"

  [ "$status" -eq 1 ]
  [[ "$output" == *"FAIL: visual-execution-plan template 缺少 Web/小程序 platform 枚举"* ]]
  [[ "$output" == *"FAIL: qa-signoff template 缺少 visual QA 状态枚举"* ]]
}
