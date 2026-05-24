#!/usr/bin/env bats

load '../lib/test_helper'

teardown() {
  rm -rf "$REPO_ROOT/qa/test-fake-change"
  rm -rf "$REPO_ROOT/progress/test-fake-change"
  rm -rf "$REPO_ROOT/verification/test-fake-change"
  rmdir "$REPO_ROOT/qa" 2>/dev/null || true
  rmdir "$REPO_ROOT/progress" "$REPO_ROOT/verification" 2>/dev/null || true
  rm -rf "$REPO_ROOT/.superspecflow/qa/test-fake-change"
  rm -rf "$REPO_ROOT/.superspecflow/maps/progress-tracking"
  rmdir "$REPO_ROOT/.superspecflow/qa" "$REPO_ROOT/.superspecflow/maps" "$REPO_ROOT/.superspecflow" 2>/dev/null || true
}

artifact_namespaces() {
  cat <<'EOF'
.superspecflow/engineering/<change-id>/
.superspecflow/qa/<change-id>/
.superspecflow/release/<change-id>/
.superspecflow/archive/<change-id>/
.superspecflow/retro/<change-id>/
.superspecflow/decisions/
.superspecflow/maps/<change-id>/
.superspecflow/reviews/<change-id>/
.superspecflow/karpathy/<change-id>/
EOF
}

extract_artifact_paths_section() {
  local file="$1"
  awk '
    /^## Artifact Paths$/ { inside = 1 }
    inside && /^## / && $0 != "## Artifact Paths" { exit }
    inside { print }
  ' "$file"
}

@test "routing files declare the nine runtime artifact namespaces" {
  for routing in "$REPO_ROOT/routing/AGENTS.routing.md" "$REPO_ROOT/routing/CLAUDE.routing.md"; do
    section="$(extract_artifact_paths_section "$routing")"
    [ -n "$section" ] || { echo "missing Artifact Paths section in $routing"; return 1; }

    while IFS= read -r namespace; do
      [ -n "$namespace" ] || continue
      printf '%s\n' "$section" | grep -Fq "$namespace" || {
        echo "missing $namespace in $routing Artifact Paths section"
        return 1
      }
    done < <(artifact_namespaces)

    printf '%s\n' "$section" | grep -qE '(new path first|新路径优先|new-path-first)'
    printf '%s\n' "$section" | grep -qE '(fallback|兼容期|回退)'
    printf '%s\n' "$section" | grep -q 'openspec/'
    printf '%s\n' "$section" | grep -q 'engineering/<change-id>/'
    printf '%s\n' "$section" | grep -q 'progress-tracking'
    printf '%s\n' "$section" | grep -q 'cross-agent-verification'
  done
}

@test "skills declare artifact path context and runtime namespaces" {
  for skill in \
    "$REPO_ROOT/skills/ssf-build/SKILL.md" \
    "$REPO_ROOT/skills/ssf-review/SKILL.md" \
    "$REPO_ROOT/skills/ssf-qa/SKILL.md" \
    "$REPO_ROOT/skills/ssf-ship/SKILL.md" \
    "$REPO_ROOT/skills/ssf-archive/SKILL.md" \
    "$REPO_ROOT/skills/ssf-retro/SKILL.md" \
    "$REPO_ROOT/skills/ssf-karpathy/SKILL.md"; do
    grep -Fq '.superspecflow/' "$skill" || { echo "missing .superspecflow path in $skill"; return 1; }
  done

  grep -Fq '.superspecflow/engineering/<change-id>/' "$REPO_ROOT/skills/ssf-build/SKILL.md"
  grep -Fq '.superspecflow/maps/<change-id>/' "$REPO_ROOT/skills/ssf-build/SKILL.md"
  grep -Fq 'engineering/<change-id>/' "$REPO_ROOT/skills/ssf-build/SKILL.md"
  grep -Fq '.superspecflow/qa/<change-id>/' "$REPO_ROOT/skills/ssf-qa/SKILL.md"
  grep -Fq '.superspecflow/release/<change-id>/' "$REPO_ROOT/skills/ssf-ship/SKILL.md"
  grep -Fq '.superspecflow/archive/<change-id>/' "$REPO_ROOT/skills/ssf-archive/SKILL.md"
  grep -Fq '.superspecflow/retro/<change-id>/' "$REPO_ROOT/skills/ssf-retro/SKILL.md"
  grep -Fq '.superspecflow/karpathy/<change-id>/' "$REPO_ROOT/skills/ssf-karpathy/SKILL.md"
}

@test "runtime templates advertise .superspecflow output paths" {
  grep -Fq 'Path: `.superspecflow/maps/[change-id]/spec-to-code-map.md`' "$REPO_ROOT/templates/spec-to-code-map.md"
  grep -Fq 'Path: `.superspecflow/qa/[change-id]/acceptance-matrix.md`' "$REPO_ROOT/templates/acceptance-matrix.md"
  grep -Fq 'Path: `.superspecflow/reviews/[change-id]/review-report.md`' "$REPO_ROOT/templates/review-report.md"
  grep -Fq 'Path: `.superspecflow/karpathy/[change-id]/karpathy-diff-audit.md`' "$REPO_ROOT/templates/karpathy-diff-audit.md"
}

@test "openspec remains a committable contract and is not ignored" {
  run git -C "$REPO_ROOT" check-ignore openspec
  [ "$status" -ne 0 ]

  run bash "$REPO_ROOT/scripts/validate-pack.sh"
  [ "$status" -eq 0 ]
}

@test "committed engineering delivery directories are not treated as illegal runtime artifacts" {
  for dir in init-project-routing progress-tracking cross-agent-verification; do
    run git -C "$REPO_ROOT" ls-files "engineering/$dir"
    [ "$status" -eq 0 ]
    [[ "$output" == *"engineering/$dir/"* ]]
  done

  run bash "$REPO_ROOT/scripts/validate-pack.sh"
  [ "$status" -eq 0 ]
}

@test "new root-level qa runtime artifacts are rejected while .superspecflow qa is ignored" {
  mkdir -p "$REPO_ROOT/qa/test-fake-change"
  printf 'runtime fixture\n' > "$REPO_ROOT/qa/test-fake-change/notes.md"

  run bash "$REPO_ROOT/scripts/validate-pack.sh"
  [ "$status" -ne 0 ]
  [[ "$output" == *"qa/test-fake-change"* ]]

  rm -rf "$REPO_ROOT/qa/test-fake-change"
  rmdir "$REPO_ROOT/qa" 2>/dev/null || true

  mkdir -p "$REPO_ROOT/.superspecflow/qa/test-fake-change"
  printf 'runtime fixture\n' > "$REPO_ROOT/.superspecflow/qa/test-fake-change/notes.md"

  run git -C "$REPO_ROOT" check-ignore .superspecflow/qa/test-fake-change/notes.md
  [ "$status" -eq 0 ]
}

@test "new root-level progress and verification runtime artifacts are rejected" {
  mkdir -p "$REPO_ROOT/progress/test-fake-change" "$REPO_ROOT/verification/test-fake-change"
  printf 'runtime fixture\n' > "$REPO_ROOT/progress/test-fake-change/state.json"
  printf 'runtime fixture\n' > "$REPO_ROOT/verification/test-fake-change/signoff.md"

  run bash "$REPO_ROOT/scripts/validate-pack.sh"
  [ "$status" -ne 0 ]
  [[ "$output" == *"progress/test-fake-change"* ]]
  [[ "$output" == *"verification/test-fake-change"* ]]
}

@test "engineering source delivery and .superspecflow runtime can coexist" {
  mkdir -p "$REPO_ROOT/.superspecflow/maps/progress-tracking"
  printf 'host runtime fixture\n' > "$REPO_ROOT/.superspecflow/maps/progress-tracking/spec-to-code-map.md"

  run bash "$REPO_ROOT/scripts/validate-pack.sh"
  [ "$status" -eq 0 ]

  [ -f "$REPO_ROOT/engineering/progress-tracking/spec-to-code-map.md" ]
}

@test "artifact migration spec-to-code map records requirement and MUST NOT coverage" {
  map="$REPO_ROOT/engineering/artifact-path-migration/spec-to-code-map.md"

  grep -q 'SSF-ARTIFACT-007 因为有三个不同语境的 Scenario' "$map"
  grep -q 'SSF-ARTIFACT-001' "$map"
  grep -q 'SSF-ARTIFACT-007 Scenario 1' "$map"
  grep -q 'SSF-ARTIFACT-007 Scenario 2' "$map"
  grep -q 'SSF-ARTIFACT-007 Scenario 3' "$map"
  grep -q 'agents/code-reviewer.md' "$map"
  grep -q 'agents/implementation-engineer.md' "$map"
  grep -q 'agents/product-strategist.md' "$map"
  grep -q 'agents/qa-gatekeeper.md' "$map"
  grep -q 'agents/release-manager.md' "$map"
  grep -q 'agents/spec-architect.md' "$map"
  grep -q '## MUST NOT 覆盖' "$map"

  for must_not in N1 N2 N3 N4 N5 N6; do
    grep -q "SSF-ARTIFACT-$must_not" "$map" || { echo "missing $must_not"; return 1; }
  done
}
