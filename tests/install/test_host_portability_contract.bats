#!/usr/bin/env bats

load '../lib/test_helper'

@test "install-global writes pack root metadata for deterministic ssf-init" {
  grep -q 'pack-root' "$REPO_ROOT/scripts/install-global.sh"
  grep -q 'pack-root' "$REPO_ROOT/commands/ssf-init.md"
}

@test "runtime skills do not hardcode a Claude Superpowers plugin cache path" {
  run grep -R -n 'claude-plugins-official/superpowers/5.0.5' "$REPO_ROOT/skills"
  [ "$status" -ne 0 ]
  grep -q 'Reviewer prompt unavailable' "$REPO_ROOT/skills/ssf-spec/SKILL.md"
  grep -q 'Reviewer prompt unavailable' "$REPO_ROOT/skills/ssf-build/SKILL.md"
  grep -q 'Reviewer prompt unavailable' "$REPO_ROOT/skills/ssf-think/SKILL.md"
}
