#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  cat <<'EOF'
Usage: scripts/new-change.sh <change-id>

Creates an OpenSpec change scaffold under openspec/changes/<change-id>/,
engineering/<change-id>/, and appends a validate-ready active row to
openspec/change-ledger.md.
EOF
}

die() {
  echo "error: $*" >&2
  exit 1
}

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  usage
  exit 0
fi

[ "$#" -eq 1 ] || {
  usage >&2
  exit 1
}

change_id="$1"

if ! [[ "$change_id" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  die "invalid change id: $change_id"
fi

change_dir="$ROOT_DIR/openspec/changes/$change_id"
spec_dir="$change_dir/specs"
engineering_dir="$ROOT_DIR/engineering/$change_id"
ledger="$ROOT_DIR/openspec/change-ledger.md"

[ -f "$ledger" ] || die "missing openspec/change-ledger.md"

if [ -e "$change_dir" ] || [ -e "$engineering_dir" ] ||
   grep -Fq "| $change_id |" "$ledger"; then
  die "change already exists: $change_id"
fi

mkdir -p "$spec_dir" "$engineering_dir"

cat > "$change_dir/proposal.md" <<EOF
# Proposal: $change_id

## Summary

## Problem

## Goals

## Non-goals

## User Impact

## Affected Areas

## Success Metrics

## Risks

## Rollout Strategy

## Open Questions
EOF

cat > "$change_dir/design.md" <<EOF
# Design: $change_id

## Architecture Summary

## Data Flow

## API / Interface Changes

## Data Model Changes

## Security / Permission Considerations

## Failure Modes

## Observability

## Migration Plan

## Rollback Plan

## Alternatives Considered
EOF

cat > "$change_dir/tasks.md" <<EOF
# Tasks: $change_id

- [ ] T1: Define implementation tasks
  - Spec: TBD
  - Files: TBD
  - Test: TBD
  - Acceptance: Replace this scaffold with verifiable tasks before implementation.
EOF

cat > "$spec_dir/$change_id.md" <<EOF
# Spec: $change_id

### Requirement: TBD-001 Initial requirement

The system MUST replace this scaffold with concrete requirements before implementation.

#### Scenario: requirement is implemented
- GIVEN the change is ready for implementation
- WHEN the maintainer updates this spec
- THEN every requirement has a stable Spec ID, scenario, and acceptance signal.
EOF

cat > "$engineering_dir/spec-to-code-map.md" <<EOF
# Spec to Code Map: $change_id

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| TBD-001 | Initial requirement scaffold | TBD | TBD | Planned |
EOF

cat > "$engineering_dir/spec-readiness-review.md" <<EOF
# Spec Readiness Review: $change_id

## Review Status

Pending.

## Notes

- Replace this scaffold after proposal, design, tasks, and specs are ready.
EOF

printf '| %s | active | Scaffold created by scripts/new-change.sh; OpenSpec and engineering skeletons are ready for requirements discovery. | Pending proposal refinement, tasks, implementation, verification, and completion evidence. |\n' "$change_id" >> "$ledger"

printf 'Created change scaffold: %s\n' "$change_id"
printf 'OpenSpec: openspec/changes/%s/\n' "$change_id"
printf 'Engineering: engineering/%s/\n' "$change_id"
