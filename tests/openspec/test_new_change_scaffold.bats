#!/usr/bin/env bats

load '../lib/test_helper'

setup() {
  FIXTURE_REPO="$(ssf_make_tmp_repo_fixture)"
}

teardown() {
  ssf_cleanup_tmp "$FIXTURE_REPO"
}

@test "scripts/new-change.sh is executable" {
  [ -x "$REPO_ROOT/scripts/new-change.sh" ]
}

@test "scripts/new-change.sh creates OpenSpec and engineering scaffold plus ledger row" {
  run "$FIXTURE_REPO/scripts/new-change.sh" sample-change

  [ "$status" -eq 0 ]
  [[ "$output" == *"Created change scaffold: sample-change"* ]]

  [ -f "$FIXTURE_REPO/openspec/changes/sample-change/proposal.md" ]
  [ -f "$FIXTURE_REPO/openspec/changes/sample-change/design.md" ]
  [ -f "$FIXTURE_REPO/openspec/changes/sample-change/tasks.md" ]
  [ -f "$FIXTURE_REPO/openspec/changes/sample-change/specs/sample-change.md" ]
  [ -f "$FIXTURE_REPO/engineering/sample-change/spec-to-code-map.md" ]
  [ -f "$FIXTURE_REPO/engineering/sample-change/spec-readiness-review.md" ]

  grep -q '# Proposal: sample-change' "$FIXTURE_REPO/openspec/changes/sample-change/proposal.md"
  grep -q '# Spec: sample-change' "$FIXTURE_REPO/openspec/changes/sample-change/specs/sample-change.md"
  grep -q '| sample-change | active | Scaffold created' "$FIXTURE_REPO/openspec/change-ledger.md"
  [ ! -e "$FIXTURE_REPO/.superspecflow" ]

  run "$FIXTURE_REPO/scripts/validate-change-ledger.sh"
  [ "$status" -eq 0 ]
}

@test "scripts/new-change.sh rejects invalid change ids" {
  for change_id in '../x' 'foo/bar' '.hidden' 'Foo' 'foo_bar' '-leading' 'trailing-' 'bad--dash'; do
    run "$FIXTURE_REPO/scripts/new-change.sh" "$change_id"
    [ "$status" -eq 1 ]
    [[ "$output" == *"invalid change id"* ]]
  done
}

@test "scripts/new-change.sh refuses to overwrite existing changes" {
  run "$FIXTURE_REPO/scripts/new-change.sh" duplicate-change
  [ "$status" -eq 0 ]

  run "$FIXTURE_REPO/scripts/new-change.sh" duplicate-change
  [ "$status" -eq 1 ]
  [[ "$output" == *"change already exists"* ]]

  count="$(grep -c '| duplicate-change |' "$FIXTURE_REPO/openspec/change-ledger.md")"
  [ "$count" -eq 1 ]
}

@test "scripts/new-change.sh creates a validate-pack-ready scaffold" {
  run "$FIXTURE_REPO/scripts/new-change.sh" validate-ready-change
  [ "$status" -eq 0 ]

  run "$FIXTURE_REPO/scripts/validate-pack.sh"
  [ "$status" -eq 0 ]
}
