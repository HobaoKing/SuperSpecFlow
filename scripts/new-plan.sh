#!/usr/bin/env bash
# 保留公开 CLI 入口，透传到 skill 自带生成器；两种调用共享相同的默认路径与不覆盖契约。
set -euo pipefail
PACK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec bash "$PACK_ROOT/skills/ssf-plan/scripts/new-plan.sh" "$@"
