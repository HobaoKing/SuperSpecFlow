#!/usr/bin/env bats

load '../lib/test_helper'

@test "spec readiness template captures Superpowers review evidence" {
  grep -q 'Brainstorming Context' "$REPO_ROOT/templates/spec-readiness-review.md"
  grep -q 'Assumption Audit' "$REPO_ROOT/templates/spec-readiness-review.md"
  grep -q 'Alternatives Considered' "$REPO_ROOT/templates/spec-readiness-review.md"
  grep -q 'Open Questions Disposition' "$REPO_ROOT/templates/spec-readiness-review.md"
  grep -q 'Reviewer Result' "$REPO_ROOT/templates/spec-readiness-review.md"
  grep -q 'Blocked / Waived Evidence' "$REPO_ROOT/templates/spec-readiness-review.md"
}

@test "ssf-spec skill requires brainstorming context or waiver" {
  grep -q 'Brainstorming Context' "$REPO_ROOT/skills/ssf-spec/SKILL.md"
  grep -q 'Assumption Audit' "$REPO_ROOT/skills/ssf-spec/SKILL.md"
  grep -q 'Open Questions Disposition' "$REPO_ROOT/skills/ssf-spec/SKILL.md"
  grep -q 'Blocked / Waived Evidence' "$REPO_ROOT/skills/ssf-spec/SKILL.md"
}

@test "spec command agent and routing expose spec review loop evidence" {
  grep -q 'Brainstorming Context' "$REPO_ROOT/commands/ssf-spec.md"
  grep -q 'Spec Document Review Loop' "$REPO_ROOT/commands/ssf-spec.md"
  grep -q 'Blocked / Waived Evidence' "$REPO_ROOT/agents/spec-architect.md"
  grep -q 'Brainstorming Context' "$REPO_ROOT/routing/AGENTS.routing.md"
  grep -q 'Spec Document Review Loop' "$REPO_ROOT/routing/CLAUDE.routing.md"
  grep -q 'Superpowers spec review' "$REPO_ROOT/README.md"
}

@test "validate-pack enforces Superpowers spec discipline" {
  grep -q 'check_superpowers_spec_discipline' "$REPO_ROOT/scripts/validate-pack.sh"
}
