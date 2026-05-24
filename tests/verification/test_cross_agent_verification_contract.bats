#!/usr/bin/env bats

load '../lib/test_helper'

@test "cross-agent verification templates define the handoff files" {
  for template in \
    verification-request.md \
    verification-evidence.md \
    verification-reviewer-notes.md \
    verification-signoff.md; do
    [ -f "$REPO_ROOT/templates/$template" ] || { echo "missing templates/$template"; return 1; }
  done

  grep -Fq '.superspecflow/verification/[change-id]/request.md' "$REPO_ROOT/templates/verification-request.md"
  grep -q 'Evidence Reviewed' "$REPO_ROOT/templates/verification-signoff.md"
  grep -q 'approve | changes-requested | blocked' "$REPO_ROOT/templates/verification-signoff.md"
  grep -q 'progress 不可用' "$REPO_ROOT/templates/verification-reviewer-notes.md"
}

@test "ssf-review enforces evidence-based cross-agent verification" {
  grep -q '.superspecflow/verification/<change-id>/' "$REPO_ROOT/skills/ssf-review/SKILL.md"
  grep -q 'request.md' "$REPO_ROOT/skills/ssf-review/SKILL.md"
  grep -q 'evidence.md' "$REPO_ROOT/skills/ssf-review/SKILL.md"
  grep -q 'reviewer-notes.md' "$REPO_ROOT/skills/ssf-review/SKILL.md"
  grep -q 'signoff.md' "$REPO_ROOT/skills/ssf-review/SKILL.md"
  grep -q 'approve / changes-requested / blocked' "$REPO_ROOT/skills/ssf-review/SKILL.md"
  grep -q '不得把聊天上下文' "$REPO_ROOT/skills/ssf-review/SKILL.md"
}

@test "routing exposes lightweight cross-agent verification without heavy protocols" {
  for routing in "$REPO_ROOT/routing/AGENTS.routing.md" "$REPO_ROOT/routing/CLAUDE.routing.md"; do
    grep -q '.superspecflow/verification/<change-id>/' "$routing"
    grep -q 'OpenSpec、diff、progress 和 evidence' "$routing"
    grep -q 'approve / changes-requested / blocked' "$routing"
    grep -q '不引入自动 agent 通信' "$routing"
  done
}

@test "cross-agent verification OpenSpec records template implementation scope" {
  grep -q 'templates/verification-' "$REPO_ROOT/openspec/changes/cross-agent-verification/proposal.md"
  grep -q 'templates/' "$REPO_ROOT/openspec/changes/cross-agent-verification/proposal.md"
  grep -q 'skills/ssf-review/SKILL.md' "$REPO_ROOT/openspec/changes/cross-agent-verification/proposal.md"
  grep -q 'SSF-XAV-011' "$REPO_ROOT/openspec/changes/cross-agent-verification/specs/verification.md"
}
