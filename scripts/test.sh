#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

list_file="$(mktemp "${TMPDIR:-/tmp}/ssf-tests.XXXXXX")"
trap 'rm -f "$list_file"' EXIT

find tests -type f -name '*.bats' | sort > "$list_file"

if [ "${1:-}" = "--list" ]; then
  cat "$list_file"
  exit 0
fi

if [ ! -s "$list_file" ]; then
  echo "error: no bats tests found under tests/" >&2
  exit 1
fi

tests=()
while IFS= read -r test_file; do
  tests+=("$test_file")
done < "$list_file"

bats "${tests[@]}"
