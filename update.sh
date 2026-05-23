#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

echo "Done. Restart the session to reload instructions."
