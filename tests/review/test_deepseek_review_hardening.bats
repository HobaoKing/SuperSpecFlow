#!/usr/bin/env bats

load '../lib/test_helper'

@test "validate-pack command docs diff uses TMPDIR-backed helper and not shared /tmp path" {
  ! grep -q '/tmp/ssf-command-diff.txt' "$REPO_ROOT/scripts/validate-pack.sh"
  grep -q 'command_diff_file="$(tmp_file)"' "$REPO_ROOT/scripts/validate-pack.sh"
  grep -q 'rm -f "$expected_file" "$actual_file" "$command_diff_file"' "$REPO_ROOT/scripts/validate-pack.sh"
}

@test "root AGENTS entry contains no user-specific absolute include" {
  ! grep -q '@/Users/' "$REPO_ROOT/AGENTS.md"
  grep -q '@./routing/AGENTS.routing.md' "$REPO_ROOT/AGENTS.md"
}

@test "branch decision and map commands have explicit contract coverage" {
  grep -q 'Use the `ssf-git` skill.' "$REPO_ROOT/commands/ssf-branch.md"
  grep -q 'ssf/<change-id>-<short-slug>' "$REPO_ROOT/commands/ssf-branch.md"
  grep -q '.superspecflow/decisions/' "$REPO_ROOT/commands/ssf-decision.md"
  grep -q 'Linked Specs / PRs' "$REPO_ROOT/commands/ssf-decision.md"
  grep -q '.superspecflow/maps/<change-id>/spec-to-code-map.md' "$REPO_ROOT/commands/ssf-map.md"
  grep -q 'engineering/<change-id>/spec-to-code-map.md' "$REPO_ROOT/commands/ssf-map.md"
}

@test "compatibility docs list shell platform tools and test dependencies" {
  grep -q '## Platform and Tool Requirements' "$REPO_ROOT/docs/compatibility.md"
  grep -q 'Bash 3.2+' "$REPO_ROOT/docs/compatibility.md"
  grep -q '`git`' "$REPO_ROOT/docs/compatibility.md"
  grep -q '`curl`' "$REPO_ROOT/docs/compatibility.md"
  grep -q '`bats`' "$REPO_ROOT/docs/compatibility.md"
  grep -q '`shellcheck`' "$REPO_ROOT/docs/compatibility.md"
  grep -q '`rg`' "$REPO_ROOT/docs/compatibility.md"
}

@test "OpenSpec design artifacts use design.md naming" {
  grep -q 'proposal.md.*spec.md.*design.md.*tasks.md' "$REPO_ROOT/README.md"
  ! grep -q 'technical-design.md' "$REPO_ROOT/README.md"
  [ -f "$REPO_ROOT/templates/design.md" ]
  [ ! -e "$REPO_ROOT/templates/technical-design.md" ]
}

@test "three stage review PoC lives under docs/research" {
  [ -f "$REPO_ROOT/docs/research/three-stage-review-poc-2026-05-24.md" ]
  [ ! -e "$REPO_ROOT/docs/three-stage-review-poc-2026-05-24.md" ]
}

@test "CI workflow runs validate pack full tests and shellcheck" {
  [ -f "$REPO_ROOT/.github/workflows/validate.yml" ]
  grep -q 'scripts/validate-pack.sh' "$REPO_ROOT/.github/workflows/validate.yml"
  grep -q 'scripts/test.sh' "$REPO_ROOT/.github/workflows/validate.yml"
  grep -q 'shellcheck' "$REPO_ROOT/.github/workflows/validate.yml"
  grep -q 'update.sh' "$REPO_ROOT/.github/workflows/validate.yml"
}

@test "shellcheck configuration documents intentional literal grep patterns" {
  grep -q 'shellcheck disable=SC2016' "$REPO_ROOT/scripts/validate-pack.sh"
  ! grep -q 'HOOK_DIR=' "$REPO_ROOT/templates/git-hooks/commit-msg"
}

@test "review notes mention CI and shellcheck gates are implemented" {
  grep -q 'GitHub Actions' "$REPO_ROOT/REVIEW_NOTES.md"
  grep -q 'shellcheck' "$REPO_ROOT/REVIEW_NOTES.md"
}

@test "change ledger no longer leaves completed implementation contracts active" {
  ! grep -Eq '^\| [^|]+ \| active \|' "$REPO_ROOT/openspec/change-ledger.md"
  grep -q '| deepseek-review-hardening | complete |' "$REPO_ROOT/openspec/change-ledger.md"
  grep -q 'Historical final evidence gap' "$REPO_ROOT/openspec/change-ledger.md"
}

@test "validate-pack enforces DeepSeek review hardening contract" {
  grep -q 'check_deepseek_review_hardening_contract' "$REPO_ROOT/scripts/validate-pack.sh"
  grep -q 'commands/ssf-branch.md' "$REPO_ROOT/scripts/validate-pack.sh"
  grep -q 'commands/ssf-decision.md' "$REPO_ROOT/scripts/validate-pack.sh"
  grep -q 'commands/ssf-map.md' "$REPO_ROOT/scripts/validate-pack.sh"
  grep -q 'Use the `ssf-git` skill.' "$REPO_ROOT/scripts/validate-pack.sh"
  grep -q 'ssf/<change-id>-<short-slug>' "$REPO_ROOT/scripts/validate-pack.sh"
  grep -q '.superspecflow/decisions/' "$REPO_ROOT/scripts/validate-pack.sh"
  grep -q 'Linked Specs / PRs' "$REPO_ROOT/scripts/validate-pack.sh"
  grep -q '.superspecflow/maps/<change-id>/spec-to-code-map.md' "$REPO_ROOT/scripts/validate-pack.sh"
  grep -q 'engineering/<change-id>/spec-to-code-map.md' "$REPO_ROOT/scripts/validate-pack.sh"
}
