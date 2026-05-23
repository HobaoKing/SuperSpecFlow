#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "用法：$0 <宿主项目路径>" >&2
  exit 1
fi

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_DIR="$1"

if [ ! -d "$PROJECT_DIR" ]; then
  echo "错误：宿主项目路径不存在：$PROJECT_DIR" >&2
  exit 1
fi

mkdir -p "$PROJECT_DIR/.claude/agents"
mkdir -p "$PROJECT_DIR/.claude/commands"
mkdir -p "$PROJECT_DIR/.claude/skills"
mkdir -p "$PROJECT_DIR/.superspecflow"

ln -sfn "$PACK_DIR/routing/AGENTS.routing.md" "$PROJECT_DIR/.superspecflow/AGENTS.routing.md"
ln -sfn "$PACK_DIR/routing/CLAUDE.routing.md" "$PROJECT_DIR/.superspecflow/CLAUDE.routing.md"
ln -sfn "$PACK_DIR/templates" "$PROJECT_DIR/.superspecflow/templates"

for path in "$PACK_DIR/agents/"*.md; do
  ln -sfn "$path" "$PROJECT_DIR/.claude/agents/$(basename "$path")"
done

for path in "$PACK_DIR/commands/"ssf-*.md; do
  ln -sfn "$path" "$PROJECT_DIR/.claude/commands/$(basename "$path")"
done

for path in "$PACK_DIR/skills/"ssf-*; do
  ln -sfn "$path" "$PROJECT_DIR/.claude/skills/$(basename "$path")"
done

cat <<'MSG'
SuperSpecFlow 软连安装完成。

请在宿主项目已有 AGENTS.md / CLAUDE.md 中保留自己的项目规则，并只加入极薄入口说明，例如：

AGENTS.md:
@./.superspecflow/AGENTS.routing.md

CLAUDE.md:
@./.superspecflow/CLAUDE.routing.md

不要复制或覆盖宿主项目已有 AGENTS.md / CLAUDE.md。
MSG
