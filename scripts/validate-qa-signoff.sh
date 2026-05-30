#!/usr/bin/env bash
set -euo pipefail

signoff="${1:-}"
if [ -z "$signoff" ] || [ ! -f "$signoff" ]; then
  echo "error: qa-signoff.md path is required" >&2
  exit 2
fi

field_value() {
  local label="$1"
  awk -v label="$label" '
    $0 ~ "^[[:space:]]*-?[[:space:]]*" label ":" {
      sub("^[[:space:]]*-?[[:space:]]*" label ":[[:space:]]*", "")
      print
      exit
    }
  ' "$signoff"
}

is_empty_value() {
  local value="$1"
  case "$value" in
    ""|"-"|"N/A"|"n/a"|"NA"|"na") return 0 ;;
    *) return 1 ;;
  esac
}

has_blocked=0
if grep -Eq 'Status:[[:space:]]*Blocked:' "$signoff"; then
  has_blocked=1
fi

recommends_ship=0
if grep -Eq '^-?[[:space:]]*(Recommendation:|-[[:space:]])[[:space:]]*Ship( with monitoring)?[[:space:]]*$' "$signoff"; then
  recommends_ship=1
fi

if [ "$has_blocked" -eq 1 ] && [ "$recommends_ship" -eq 1 ]; then
  if ! grep -q '## Blocked Waiver' "$signoff" ||
     ! grep -q 'Waiver:' "$signoff" ||
     ! grep -q 'Approved By:' "$signoff" ||
     ! grep -q 'Residual Risk:' "$signoff"; then
    echo "error: blocked QA status recommending ship requires waiver, approval, and residual risk evidence" >&2
    exit 1
  fi
fi

if grep -Eq 'Status:[[:space:]]*Automated Browser Passed' "$signoff"; then
  browser_run_report="$(field_value 'Browser Run Report')"
  evidence="$(field_value 'Evidence')"
  manual_notes="$(field_value 'Manual Verification Notes')"

  if is_empty_value "$browser_run_report"; then
    echo "error: Automated Browser Passed requires Browser Run Report" >&2
    exit 1
  fi

  if is_empty_value "$evidence" && is_empty_value "$manual_notes"; then
    echo "error: Automated Browser Passed requires Evidence or Manual Verification Notes" >&2
    exit 1
  fi
fi
