#!/usr/bin/env bash
# 在目标项目生成一份轻量计划，不写启用标记或覆盖已有计划。
set -euo pipefail

PACK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  echo '用法：scripts/new-plan.sh <topic> [project-dir]'
  echo '在指定项目（默认当前目录）创建 docs/plans/<topic>.md；不覆盖已有文件。'
}

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  usage
  exit 0
fi
[ "$#" -ge 1 ] && [ "$#" -le 2 ] || { usage >&2; exit 2; }
topic="$1"
project="${2:-$PWD}"
if ! [[ "$topic" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "error: invalid topic: $topic" >&2
  exit 1
fi
[ -d "$project" ] || { echo "error: project directory does not exist: $project" >&2; exit 1; }
plan="$project/docs/plans/$topic.md"
[ ! -e "$plan" ] && [ ! -L "$plan" ] || { echo "error: plan already exists: $plan" >&2; exit 1; }
mkdir -p "$(dirname "$plan")"
# noclobber 防止并发创建时覆盖用户文件；主题限定为安全 slug。
(set -o noclobber; sed "s/<主题>/$topic/g" "$PACK_ROOT/templates/implementation-plan.md" > "$plan")
printf 'Created plan: %s\n' "$plan"
