#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ENABLE_NATURAL_LANGUAGE=0
PROJECT_DIR=""

usage() {
  cat <<'MSG'
Usage:
  ./update.sh
  ./update.sh --enable-natural-language <project>

Options:
  --enable-natural-language <project>
      After global installation, initialize SuperSpecFlow routing for the given
      project by creating .superspecflow/ symlinks. Host AGENTS.md / CLAUDE.md
      files are not overwritten.
MSG
}

while [ "$#" -gt 0 ]; do
  case "$1" in
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

mkdir -p ~/.claude/skills ~/.claude/agents ~/.claude/commands
cp -R "$SCRIPT_DIR/skills/"* ~/.claude/skills/
cp -R "$SCRIPT_DIR/agents/"* ~/.claude/agents/
cp -R "$SCRIPT_DIR/commands/"* ~/.claude/commands/

echo "✓ Installed SuperSpecFlow Claude Code skills, agents, and commands"

if [ -d ~/.codex ]; then
  mkdir -p ~/.codex/skills
  cp -R "$SCRIPT_DIR/skills/"* ~/.codex/skills/ || true
  echo "✓ Synced SuperSpecFlow skills to Codex"
fi

if [ "$ENABLE_NATURAL_LANGUAGE" -eq 1 ]; then
  "$SCRIPT_DIR/scripts/install-project-symlinks.sh" "$PROJECT_DIR"
else
  echo "Natural-language routing not enabled. Run /ssf-init in a project, or rerun:"
  echo "  ./update.sh --enable-natural-language <project>"
fi

echo "Done. Restart the session to reload instructions."
