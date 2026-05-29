#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_FILE="$SCRIPT_DIR/VERSION"

ENABLE_NATURAL_LANGUAGE=0
PROJECT_DIR=""

usage() {
  cat <<'MSG'
Usage:
  ./update.sh
  ./update.sh --enable-natural-language <project>
  ./update.sh --version

Options:
  --version
      Print the SuperSpecFlow package version and exit without installing.

  --enable-natural-language <project>
      After global installation, initialize SuperSpecFlow routing for the given
      project by creating .superspecflow/enabled. Host AGENTS.md / CLAUDE.md
      files are not overwritten.
MSG
}

print_version() {
  local version
  version="$(cat "$VERSION_FILE")"
  printf 'SuperSpecFlow %s\n' "$version"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --version)
      print_version
      exit 0
      ;;
    --enable-natural-language)
      if [ "$#" -lt 2 ]; then
        echo "error: --enable-natural-language requires a project path" >&2
        usage >&2
        exit 1
      fi
      ENABLE_NATURAL_LANGUAGE=1
      PROJECT_DIR="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

"$SCRIPT_DIR/scripts/install-global.sh" --both

if [ "$ENABLE_NATURAL_LANGUAGE" -eq 1 ]; then
  SSF_INIT_PROJECT_DIR="$PROJECT_DIR" "$SCRIPT_DIR/scripts/_ssf_init_apply.sh"
else
  echo "Natural-language routing not enabled for any project. Run /ssf-init in a project, or rerun:"
  echo "  ./update.sh --enable-natural-language <project>"
fi

echo "Done. Restart the session to reload instructions."
