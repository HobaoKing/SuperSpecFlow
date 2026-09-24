#!/usr/bin/env bash
# 只校验当前包的可加载结构、入口一致性和运行时边界，不以历史流程文案作为门禁。
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
FAILED=0

# 累积错误，避免首个缺失遮蔽其他入口问题。
fail() {
  printf 'FAIL: %s\n' "$1" >&2
  FAILED=1
}

# 缺文件时报告具体路径；调用方仍可继续其他独立检查。
require_file() {
  [ -s "$1" ] || { fail "missing or empty: $1"; return 1; }
}

# 三个根入口都只引用集中规则并限制体积，防止重复粘贴完整工作流。
check_root_instruction_files_thin() {
  local host
  for host in AGENTS CLAUDE GEMINI; do
    require_file "$host.md" || continue
    grep -Fq "@./routing/$host.routing.md" "$host.md" || fail "$host.md missing routing include"
    [ "$(wc -l < "$host.md")" -le 40 ] || fail "$host.md is not a thin entry"
  done
}

# 三个根入口描述同一个仓库规则，除 include 行外正文必须一致，避免只改一处造成多入口漂移。
check_root_instruction_bodies_in_sync() {
  local reference host body
  reference=""
  for host in AGENTS CLAUDE GEMINI; do
    [ -f "$host.md" ] || continue
    body="$(tail -n +2 "$host.md")"
    if [ -z "$reference" ]; then
      reference="$body"
    elif [ "$body" != "$reference" ]; then
      fail "root instruction bodies drift: $host.md differs from AGENTS.md"
    fi
  done
}

# global wrapper 是安装时渲染的模板，必须带有该宿主的 routing 占位符；
# 安装测试只断言渲染产物无残留占位符，这里在 pre-commit 层先挡一次。
check_global_wrapper_placeholders() {
  local host
  for host in CLAUDE AGENTS GEMINI; do
    require_file "routing/$host.global.md" || continue
    grep -Fq "<repo>/routing/$host.routing.md" "routing/$host.global.md" ||
      fail "routing/$host.global.md missing routing placeholder"
  done
}

# 各端发布实体副本以适应不同安装方式；源文件必须与副本完全一致。
check_routing_files() {
  local host
  require_file routing/default.routing.md || return 0
  for host in AGENTS CLAUDE GEMINI; do
    if ! cmp -s routing/default.routing.md "routing/$host.routing.md"; then
      fail "public routing files match canonical: routing/$host.routing.md drift"
    fi
  done
}

# 每个已安装 skill 自包含：frontmatter 与目录一致，本地 Markdown 引用必须可解析。
check_skills() {
  local dir file name ref
  for dir in skills/ssf-*; do
    file="$dir/SKILL.md"
    require_file "$file" || continue
    name="${dir##*/}"
    [ "$(head -n 1 "$file")" = '---' ] || fail "$file missing frontmatter"
    grep -Fxq "name: $name" "$file" || fail "$file invalid name"
    grep -Eq '^description: .+' "$file" || fail "$file missing description"
    while IFS= read -r ref; do
      require_file "$dir/$ref" || true
    done < <(grep -Eo '\]\(references/[^)]+\)' "$file" | sed 's/^](//; s/)$//' || true)
  done
  require_file skills/ssf-build/references/diagnosing-bugs.md || true
  require_file skills/ssf-build/references/mattpocock-LICENSE.txt || true
  require_file skills/ssf-review/references/mattpocock-LICENSE.txt || true
}

# 同时校验反引号能力名与斜杠命令的文件存在性，再检查 skill 引用。
check_commands() {
  local file name skill command declared=0
  # shellcheck disable=SC2016 # 正则按字面匹配 Markdown 反引号。
  while IFS= read -r command; do
    declared=1
    require_file "commands/$command.md" || true
  done < <(grep -Eo '/ssf-[a-z-]+|`ssf-[a-z-]+`' routing/default.routing.md | tr -d '/`' | sort -u)
  [ "$declared" -eq 1 ] || fail "routing/default.routing.md declares no commands"
  for file in commands/ssf-*.md; do
    require_file "$file" || continue
    # shellcheck disable=SC2016 # 按字面匹配 Markdown 反引号，不执行变量展开。
    skill="$(sed -nE 's/.*使用 `(ssf-[a-z-]+)` skill.*/\1/p' "$file")"
    if [ -z "$skill" ]; then
      fail "$file missing skill target"
    else
      require_file "skills/$skill/SKILL.md" || true
    fi
  done
}

# 源码包不得跟踪本地安装或运行记录；历史合同不参与新任务完成判定。
check_runtime_boundary() {
  local paths
  paths="$(git ls-files | grep -E '^(superpowers|docs/superpowers|\.superspecflow|\.claude|\.codex|\.gemini)/|(^|/)\.DS_Store$' || true)"
  [ -z "$paths" ] || fail "tracked runtime artifacts: $paths"
  git check-ignore -q .superspecflow/test-ignore || fail '.superspecflow/ must be ignored in this source repository'
}

check_root_instruction_files_thin
check_root_instruction_bodies_in_sync
check_global_wrapper_placeholders
check_routing_files
check_skills
check_commands
check_runtime_boundary
for file in templates/implementation-plan.md templates/qa-signoff.md templates/release-checklist.md; do
  require_file "$file" || true
done
for file in scripts/*.sh update.sh; do
  bash -n "$file" || fail "shell syntax: $file"
done
[ "$FAILED" -eq 0 ] || exit 1
printf 'SuperSpecFlow pack validation passed.\n'
