#!/usr/bin/env bats

load '../lib/test_helper'

setup() {
  HOME_DIR="$(ssf_make_tmp_home)"
}

teardown() {
  ssf_cleanup_tmp "$HOME_DIR"
}

@test "VERSION records the current package version" {
  [ -f "$REPO_ROOT/VERSION" ]
  [ "$(cat "$REPO_ROOT/VERSION")" = "1.2.0" ]
  grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' "$REPO_ROOT/VERSION"
}

@test "CHANGELOG records the 1.2.0 release" {
  [ -f "$REPO_ROOT/CHANGELOG.md" ]
  grep -q '## \[1.2.0\] - 2026-05-30' "$REPO_ROOT/CHANGELOG.md"
  grep -q 'Visual UI QA' "$REPO_ROOT/CHANGELOG.md"
  grep -q 'visual-comparison-report.md' "$REPO_ROOT/CHANGELOG.md"
  grep -q '## \[1.1.0\] - 2026-05-30' "$REPO_ROOT/CHANGELOG.md"
}

@test "update.sh --version prints version without installing" {
  run env HOME="$HOME_DIR" "$REPO_ROOT/update.sh" --version
  [ "$status" -eq 0 ]
  [ "$output" = "SuperSpecFlow 1.2.0" ]
  [ ! -e "$HOME_DIR/.claude/CLAUDE.md" ]
  [ ! -e "$HOME_DIR/.codex/AGENTS.md" ]
}
