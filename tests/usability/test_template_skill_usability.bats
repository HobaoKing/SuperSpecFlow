#!/usr/bin/env bats

load '../lib/test_helper'

setup() {
  FIXTURE_REPO=""
}

teardown() {
  if [ -n "$FIXTURE_REPO" ]; then
    ssf_cleanup_tmp "$FIXTURE_REPO"
  fi
}

@test "skeletal templates include local guidance and examples" {
  for template in \
    acceptance-matrix.md \
    proposal.md \
    design.md \
    risk-matrix.md \
    negative-test-matrix.md \
    spec-to-code-map.md \
    sync-check.md \
    tasks.md; do
    grep -q 'Fill guidance:' "$REPO_ROOT/templates/$template"
    grep -q 'Example:' "$REPO_ROOT/templates/$template"
  done
}

@test "validate-pack enforces template usability guidance" {
  grep -q 'check_template_skill_usability_contract' "$REPO_ROOT/scripts/validate-pack.sh"
  grep -q '缺少 Fill guidance' "$REPO_ROOT/scripts/validate-pack.sh"
}

@test "ssf-build cross references detailed discipline while keeping local gates" {
  grep -q 'skills/ssf-karpathy/SKILL.md' "$REPO_ROOT/skills/ssf-build/SKILL.md"
  grep -q 'skills/ssf-git/SKILL.md' "$REPO_ROOT/skills/ssf-build/SKILL.md"
  grep -q '/ssf-commit \[change-id\]' "$REPO_ROOT/skills/ssf-build/SKILL.md"
  grep -q 'git diff --check' "$REPO_ROOT/skills/ssf-build/SKILL.md"
  grep -q '.superspecflow/engineering/<change-id>/' "$REPO_ROOT/skills/ssf-build/SKILL.md"
  grep -q '.superspecflow/maps/<change-id>/' "$REPO_ROOT/skills/ssf-build/SKILL.md"
  grep -q 'engineering/<change-id>/spec-to-code-map.md' "$REPO_ROOT/skills/ssf-build/SKILL.md"
  grep -q '.superspecflow/progress/<change-id>/' "$REPO_ROOT/skills/ssf-build/SKILL.md"
  grep -q 'fresh verification' "$REPO_ROOT/skills/ssf-build/SKILL.md"
  grep -q 'Reviewer prompt unavailable' "$REPO_ROOT/skills/ssf-build/SKILL.md"
  grep -q 'cluster-plan.md' "$REPO_ROOT/skills/ssf-build/SKILL.md"
  grep -q 'cluster-status.md' "$REPO_ROOT/skills/ssf-build/SKILL.md"
}

@test "ssf-retro includes probing questions for process weaknesses" {
  grep -q '## Probing Questions' "$REPO_ROOT/skills/ssf-retro/SKILL.md"
  grep -q 'Evidence:' "$REPO_ROOT/skills/ssf-retro/SKILL.md"
  grep -q 'Gates:' "$REPO_ROOT/skills/ssf-retro/SKILL.md"
  grep -q 'Scope:' "$REPO_ROOT/skills/ssf-retro/SKILL.md"
  grep -q 'Handoff:' "$REPO_ROOT/skills/ssf-retro/SKILL.md"
}

@test "ssf-archive final step automatically continues to retro" {
  grep -q '## Step 7 — 自动续接' "$REPO_ROOT/skills/ssf-archive/SKILL.md"

  archive_tail="$(awk '
    /^## Step 7 — 自动续接/ { inside = 1 }
    inside { print }
  ' "$REPO_ROOT/skills/ssf-archive/SKILL.md")"

  printf '%s\n' "$archive_tail" | grep -q '/ssf-retro'
}

@test "template usability validator reports missing guidance in fixtures" {
  FIXTURE_REPO="$(ssf_make_tmp_repo_fixture)"

  awk 'index($0, "Fill guidance:") == 0 { print }' \
    "$FIXTURE_REPO/templates/acceptance-matrix.md" > "$FIXTURE_REPO/templates/acceptance-matrix.md.tmp"
  mv "$FIXTURE_REPO/templates/acceptance-matrix.md.tmp" "$FIXTURE_REPO/templates/acceptance-matrix.md"

  run "$FIXTURE_REPO/scripts/validate-pack.sh"

  [ "$status" -eq 1 ]
  [[ "$output" == *"FAIL: templates/acceptance-matrix.md 缺少 Fill guidance"* ]]
}
