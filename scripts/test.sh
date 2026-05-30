#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

list_file="$(mktemp "${TMPDIR:-/tmp}/ssf-tests.XXXXXX")"
selected_file="$(mktemp "${TMPDIR:-/tmp}/ssf-tests-selected.XXXXXX")"
trap 'rm -f "$list_file" "$selected_file"' EXIT

usage() {
  cat <<'EOF'
Usage: scripts/test.sh [--list] [--filter PATTERN] [tests/path.bats ...]

Runs all Bats tests by default. File arguments and --filter selections are
combined, de-duplicated, and passed to bats in deterministic order.
EOF
}

error() {
  echo "error: $*" >&2
  exit 1
}

append_selected() {
  local test_file="$1"

  if ! grep -Fxq "$test_file" "$selected_file"; then
    printf '%s\n' "$test_file" >> "$selected_file"
  fi
}

normalize_test_arg() {
  local arg="$1"
  local rel

  case "$arg" in
    "$ROOT_DIR"/*) rel="${arg#$ROOT_DIR/}" ;;
    /*) error "test file must be under tests/ and end with .bats: $arg" ;;
    *) rel="$arg" ;;
  esac

  while [ "${rel#./}" != "$rel" ]; do
    rel="${rel#./}"
  done

  case "$rel" in
    ../*|*/../*|*/..) error "test file must be under tests/ and end with .bats: $arg" ;;
  esac

  case "$rel" in
    tests/*.bats) ;;
    *) error "test file must be under tests/ and end with .bats: $arg" ;;
  esac

  if [ ! -f "$ROOT_DIR/$rel" ]; then
    error "missing bats test file: $arg"
  fi

  printf '%s\n' "$rel"
}

find tests -type f -name '*.bats' | sort > "$list_file"

list_mode=0
filters=()
explicit_files=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --list)
      list_mode=1
      ;;
    --filter)
      shift
      [ "$#" -gt 0 ] || error "--filter requires a pattern"
      [ -n "$1" ] || error "--filter requires a non-empty pattern"
      filters+=("$1")
      ;;
    --filter=*)
      filter="${1#--filter=}"
      [ -n "$filter" ] || error "--filter requires a non-empty pattern"
      filters+=("$filter")
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    --*)
      error "unknown option: $1"
      ;;
    *)
      explicit_files+=("$1")
      ;;
  esac
  shift
done

if [ ! -s "$list_file" ]; then
  echo "error: no bats tests found under tests/" >&2
  exit 1
fi

if [ "${#explicit_files[@]}" -eq 0 ] && [ "${#filters[@]}" -eq 0 ]; then
  while IFS= read -r test_file; do
    append_selected "$test_file"
  done < "$list_file"
fi

for explicit_file in "${explicit_files[@]}"; do
  normalized_file="$(normalize_test_arg "$explicit_file")"
  append_selected "$normalized_file"
done

for filter in "${filters[@]}"; do
  while IFS= read -r test_file; do
    if printf '%s\n' "$test_file" | grep -Fq -- "$filter"; then
      append_selected "$test_file"
    fi
  done < "$list_file"
done

if [ ! -s "$selected_file" ]; then
  echo "error: no bats tests matched selection" >&2
  exit 1
fi

if [ "$list_mode" -eq 1 ]; then
  cat "$selected_file"
  exit 0
fi

tests=()
while IFS= read -r test_file; do
  tests+=("$test_file")
done < "$selected_file"

bats "${tests[@]}"
