#!/usr/bin/env bats

load '../lib/test_helper'

teardown() {
  rm -rf "$REPO_ROOT/.superspecflow/verification/bats-invalid-signoff"
  rmdir "$REPO_ROOT/.superspecflow/verification" "$REPO_ROOT/.superspecflow" 2>/dev/null || true
}

@test "cross-agent verification templates define the handoff files" {
  for template in \
    verification-request.md \
    verification-evidence.md \
    verification-reviewer-notes.md \
    verification-signoff.md; do
    [ -f "$REPO_ROOT/templates/$template" ] || { echo "missing templates/$template"; return 1; }
  done

  grep -Fq '.superspecflow/verification/[change-id]/request.md' "$REPO_ROOT/templates/verification-request.md"
  grep -q '本文件用于说明跨 agent 核验请求' "$REPO_ROOT/templates/verification-request.md"
  grep -q '不得只写结论' "$REPO_ROOT/templates/verification-evidence.md"
  grep -q '本文件用于记录 review agent 的独立核验过程' "$REPO_ROOT/templates/verification-reviewer-notes.md"
  grep -q '本文件只能在 evidence 存在且包含可复查内容后生成' "$REPO_ROOT/templates/verification-signoff.md"
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
    grep -q 'Cross-agent verification' "$routing"
    grep -q '.superspecflow/verification/<change-id>/' "$routing"
    grep -q 'OpenSpec' "$routing"
    grep -q 'evidence' "$routing"
    grep -q 'approve / changes-requested / blocked' "$routing"
  done
}

@test "cross-agent verification OpenSpec records template implementation scope" {
  grep -q 'templates/verification-' "$REPO_ROOT/openspec/changes/cross-agent-verification/proposal.md"
  grep -q 'templates/' "$REPO_ROOT/openspec/changes/cross-agent-verification/proposal.md"
  grep -q 'skills/ssf-review/SKILL.md' "$REPO_ROOT/openspec/changes/cross-agent-verification/proposal.md"
  grep -q 'SSF-XAV-011' "$REPO_ROOT/openspec/changes/cross-agent-verification/specs/verification.md"
  grep -q 'SSF-XAV-012' "$REPO_ROOT/openspec/changes/cross-agent-verification/specs/verification.md"
  grep -q '宿主项目策略决定' "$REPO_ROOT/openspec/changes/cross-agent-verification/specs/verification.md"
}

@test "spec-to-code maps record MUST NOT coverage" {
  grep -q '## MUST NOT 覆盖' "$REPO_ROOT/engineering/cross-agent-verification/spec-to-code-map.md"
  grep -q 'SSF-XAV-N1' "$REPO_ROOT/engineering/cross-agent-verification/spec-to-code-map.md"
  grep -q 'SSF-XAV-N4' "$REPO_ROOT/engineering/cross-agent-verification/spec-to-code-map.md"
  grep -q 'SSF-XAV-N8' "$REPO_ROOT/engineering/cross-agent-verification/spec-to-code-map.md"

  grep -q '## MUST NOT 覆盖' "$REPO_ROOT/engineering/progress-tracking/spec-to-code-map.md"
  grep -q 'SSF-PROGRESS-N3' "$REPO_ROOT/engineering/progress-tracking/spec-to-code-map.md"
  grep -q 'SSF-PROGRESS-N5' "$REPO_ROOT/engineering/progress-tracking/spec-to-code-map.md"
}

@test "cross-agent validation uses stable structural signals instead of brittle prose" {
  grep -q 'Cross-agent verification' "$REPO_ROOT/scripts/validate-pack.sh"
  ! grep -q 'OpenSpec、diff、progress 和 evidence' "$REPO_ROOT/scripts/validate-pack.sh"
  ! grep -q '不引入自动 agent 通信' "$REPO_ROOT/scripts/validate-pack.sh"
  ! grep -q '不得把聊天上下文' "$REPO_ROOT/scripts/validate-pack.sh"
}

@test "validate-pack rejects invalid cross-agent verification signoff result" {
  local signoff_dir="$REPO_ROOT/.superspecflow/verification/bats-invalid-signoff"
  mkdir -p "$signoff_dir"
  cat >"$signoff_dir/signoff.md" <<'SIGNOFF'
# Cross-Agent Verification Signoff: bats-invalid-signoff

Result: maybe
Reviewer: bats
Reviewed At: 2026-05-24T00:00:00Z

## Checked Spec IDs

- SSF-XAV-N4

## Evidence Reviewed

- test fixture

## Findings

- invalid enum

## Residual Risks

- none
SIGNOFF

  run bash "$REPO_ROOT/scripts/validate-pack.sh"

  [ "$status" -ne 0 ]
  [[ "$output" == *"非法 signoff result"* ]]
}
