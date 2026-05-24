#!/usr/bin/env bats

load '../lib/test_helper'

@test "progress runtime templates define the four protocol files" {
  for template in \
    progress-state.json \
    progress-timeline.md \
    progress-verification.md \
    progress-handoff.md; do
    [ -f "$REPO_ROOT/templates/$template" ] || { echo "missing templates/$template"; return 1; }
  done

  grep -q '"change_id"' "$REPO_ROOT/templates/progress-state.json"
  grep -q '"last_verification"' "$REPO_ROOT/templates/progress-state.json"
  grep -q 'task-started' "$REPO_ROOT/templates/progress-timeline.md"
  grep -q 'Freshness' "$REPO_ROOT/templates/progress-verification.md"
  grep -q 'Read Next' "$REPO_ROOT/templates/progress-handoff.md"
}

@test "ssf-build requires progress tracking and fresh verification" {
  grep -q '.superspecflow/progress/<change-id>/' "$REPO_ROOT/skills/ssf-build/SKILL.md"
  grep -q 'state.json' "$REPO_ROOT/skills/ssf-build/SKILL.md"
  grep -q 'verification.md' "$REPO_ROOT/skills/ssf-build/SKILL.md"
  grep -q 'fresh verification' "$REPO_ROOT/skills/ssf-build/SKILL.md"
}

@test "routing requires progress recovery before OpenSpec on resumed work" {
  for routing in "$REPO_ROOT/routing/AGENTS.routing.md" "$REPO_ROOT/routing/CLAUDE.routing.md"; do
    grep -q '.superspecflow/progress/<change-id>/' "$routing"
    grep -q 'state.json' "$routing"
    grep -q 'handoff.md' "$routing"
    grep -q '再读取 OpenSpec' "$routing"
  done
}
