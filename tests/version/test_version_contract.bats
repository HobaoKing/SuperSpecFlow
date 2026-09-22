#!/usr/bin/env bats

load '../lib/test_helper'

setup() {
  HOME_DIR="$(ssf_make_tmp_home)"
}

teardown() {
  ssf_cleanup_tmp "$HOME_DIR"
}

@test "VERSION records a single numeric package version" {
  version="$(cat "$REPO_ROOT/VERSION")"
  [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "CHANGELOG contains exactly one dated current release section" {
  version="$(cat "$REPO_ROOT/VERSION")"
  run awk -v heading="## [$version] - " '
    index($0, heading) == 1 {
      date = substr($0, length(heading) + 1)
      if (date ~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/) count++
    }
    END { exit count != 1 }
  ' "$REPO_ROOT/CHANGELOG.md"
  [ "$status" -eq 0 ]
}

@test "update.sh --version prints version without installing" {
  run env HOME="$HOME_DIR" "$REPO_ROOT/update.sh" --version
  [ "$status" -eq 0 ]
  [ "$output" = "SuperSpecFlow $(cat "$REPO_ROOT/VERSION")" ]
  [ ! -e "$HOME_DIR/.claude/CLAUDE.md" ]
  [ ! -e "$HOME_DIR/.codex/AGENTS.md" ]
}
