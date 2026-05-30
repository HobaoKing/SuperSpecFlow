#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ledger="${1:-$root_dir/openspec/change-ledger.md}"

if [ ! -f "$ledger" ]; then
  echo "error: missing openspec/change-ledger.md" >&2
  exit 1
fi

failed=0

for change_dir in "$root_dir"/openspec/changes/*; do
  [ -d "$change_dir" ] || continue
  change="$(basename "$change_dir")"
  if ! grep -Fq "| $change |" "$ledger"; then
    echo "error: openspec/change-ledger.md missing $change" >&2
    failed=1
  fi
done

while IFS= read -r change; do
  [ -n "$change" ] || continue
  if [ ! -d "$root_dir/openspec/changes/$change" ]; then
    echo "error: openspec/change-ledger.md contains unknown change: $change" >&2
    failed=1
  fi
done < <(awk -F '|' '
  NR > 1 {
    change = $2
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", change)
    if (change != "" && change != "---" && change != "Change ID") {
      print change
    }
  }
' "$ledger")

if awk -F '|' '
  function trim(value) {
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
    return value
  }
  function missing(value) {
    value = trim(value)
    return value == "" || value == "-" || value == "N/A" || value == "n/a" || value == "TBD" || value == "tbd"
  }
  NR > 1 {
    change = trim($2)
    if (change == "" || change == "---" || change == "Change ID") {
      next
    }
    status = trim($3)
    evidence = trim($4)
    gaps = trim($5)

    if (missing(evidence)) {
      print "error: missing ledger evidence for: " change
      bad = 1
    }

    gsub(/^[[:space:]]+|[[:space:]]+$/, "", status)
    if (status != "active" && status != "complete" && status != "archived" && status != "superseded") {
      print "error: invalid ledger status: " status
      bad = 1
    }

    archive_notes = tolower(evidence " " gaps)
    if (status == "archived" && archive_notes !~ /(archive|released|release evidence|status rationale|rationale)/) {
      print "error: archived change lacks archive evidence or rationale: " change
      bad = 1
    }
  }
  END { exit bad ? 1 : 0 }
' "$ledger"; then
  :
else
  failed=1
fi

exit "$failed"
