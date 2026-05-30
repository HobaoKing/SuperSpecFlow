#!/usr/bin/env bats

load '../lib/test_helper'

setup() {
  TMP_PROJECT="$(ssf_make_tmp_project)"
}

teardown() {
  ssf_cleanup_tmp "$TMP_PROJECT"
}

@test "intake gate has a runtime artifact path and init creates intake namespace" {
  grep -q 'Path: `.superspecflow/intake/\[change-id\]/intake-gate.md`' "$REPO_ROOT/templates/intake-gate.md"
  grep -q 'intake' "$REPO_ROOT/scripts/_ssf_init_apply.sh"
  grep -q '.superspecflow/{intake,engineering,qa,release,archive,retro,decisions,maps,reviews,karpathy}/' "$REPO_ROOT/commands/ssf-init.md"
}

@test "change ledger tracks every active OpenSpec change" {
  [ -f "$REPO_ROOT/openspec/change-ledger.md" ]
  for change_dir in "$REPO_ROOT"/openspec/changes/*; do
    change="$(basename "$change_dir")"
    grep -q "| $change |" "$REPO_ROOT/openspec/change-ledger.md" || {
      echo "missing ledger row for $change"
      return 1
    }
  done
}

@test "change ledger validator rejects archived rows without archive evidence or rationale" {
  ledger="$TMP_PROJECT/change-ledger.md"
  sed 's/| visual-ui-qa-adapter | archived |.*|.*|/| visual-ui-qa-adapter | archived | - | - |/' \
    "$REPO_ROOT/openspec/change-ledger.md" > "$ledger"

  run "$REPO_ROOT/scripts/validate-change-ledger.sh" "$ledger"
  [ "$status" -ne 0 ]
  [[ "$output" == *"archived"* ]] || [[ "$stderr" == *"archived"* ]]
}

@test "change ledger validator rejects rows for unknown changes" {
  ledger="$TMP_PROJECT/change-ledger.md"
  cp "$REPO_ROOT/openspec/change-ledger.md" "$ledger"
  printf '| stale-change | active | stale evidence | stale note |\n' >> "$ledger"

  run "$REPO_ROOT/scripts/validate-change-ledger.sh" "$ledger"
  [ "$status" -ne 0 ]
  [[ "$output" == *"unknown"* ]] || [[ "$stderr" == *"unknown"* ]]
}

@test "validate-pack checks change ledger and root evidence lifecycle" {
  grep -q 'check_change_ledger_contract' "$REPO_ROOT/scripts/validate-pack.sh"
  grep -q 'openspec/change-ledger.md' "$REPO_ROOT/scripts/validate-pack.sh"
}
