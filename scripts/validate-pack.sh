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
    [ "$(wc -l < "$host.md")" -le 40 ] || fail "$host.md is not a thin entry: $(wc -l < "$host.md" | tr -d ' ') lines (max 40); fix: move rules into routing/default.routing.md"
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
      fail "root instruction bodies drift: $host.md differs from AGENTS.md; fix: apply the same body edit to AGENTS.md, CLAUDE.md and GEMINI.md (only line 1 may differ)"
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
      fail "public routing files match canonical: routing/$host.routing.md drift; fix: edit routing/default.routing.md, then cp routing/default.routing.md routing/$host.routing.md"
    fi
  done
}

# 每个已安装 skill 自包含：frontmatter 与目录一致，SKILL.md 链接与技能内资源双向对齐（排除署名许可证文件）。
# 计划与 QA 模板校验安装副本一致；本项目发布清单与 skill 通用模板用途不同，不做同步。
check_skills() {
  local dir file name ref res rel mapping skill template
  for dir in skills/ssf-*; do
    file="$dir/SKILL.md"
    require_file "$file" || continue
    name="${dir##*/}"
    [ "$(head -n 1 "$file")" = '---' ] || fail "$file missing frontmatter"
    grep -Fxq "name: $name" "$file" || fail "$file invalid name"
    while IFS= read -r ref; do
      require_file "$dir/$ref" || true
    done < <(grep -Eo '\]\((references|assets|scripts)/[^)]+\)' "$file" | sed 's/^](//; s/)$//' || true)
    for res in "$dir"/{references,assets,scripts}/*; do
      [ -f "$res" ] || continue
      rel="${res#"$dir/"}"
      case "$rel" in
        references/mattpocock-LICENSE.txt) continue ;;
      esac
      grep -Fq "($rel)" "$file" ||
        fail "unlinked skill resource: $res; fix: link ($rel) in $file or remove the file"
    done
  done
  for mapping in plan:implementation-plan.md qa:qa-signoff.md; do
    skill="${mapping%%:*}"
    template="${mapping#*:}"
    cmp -s "templates/$template" "skills/ssf-$skill/assets/$template" ||
      fail "skill template drift: skills/ssf-$skill/assets/$template; fix: cp templates/$template skills/ssf-$skill/assets/$template (or edit both identically)"
  done
  while IFS= read -r file; do
    bash -n "$file" || fail "shell syntax: $file"
  done < <(find skills -type f -name '*.sh')
  require_file skills/ssf-build/references/mattpocock-LICENSE.txt || true
  require_file skills/ssf-review/references/mattpocock-LICENSE.txt || true
}

# 体积预算（单位：字节，用 wc -c 统计，不依赖 locale）。description 须位于闭合 frontmatter 中且为单行无引号文本，校验后统计值字节，
# SKILL.md 每次激活整份加载，references 按需加载；超限即失败，提示把细节下沉或拆分，避免入口逐版膨胀。
# 输入：skills/ssf-*/ 下的 SKILL.md 与 references/*.md；输出：逐项报告实际值、上限与修复方式，累计到 FAILED。
SKILL_DESCRIPTION_MAX_BYTES=1024
SKILL_ENTRY_MAX_BYTES=4096
SKILL_ENTRIES_TOTAL_MAX_BYTES=16384
SKILL_REFERENCE_MAX_BYTES=8192
check_skill_budgets() {
  local file bytes description description_bytes total=0
  for file in skills/ssf-*/SKILL.md; do
    [ -f "$file" ] || continue
    bytes="$(wc -c < "$file" | tr -d ' ')"
    total=$((total + bytes))
    [ "$bytes" -le "$SKILL_ENTRY_MAX_BYTES" ] ||
      fail "skill entry over budget: $file is $bytes bytes (max $SKILL_ENTRY_MAX_BYTES); fix: move method detail into references/ and link it from the entry"
    if ! description="$(
      awk '
        NR == 1 && $0 == "---" { in_fm = 1; next }
        in_fm && $0 == "---" { closed = 1; exit }
        in_fm && /^description:[[:space:]]*/ {
          if (found++) invalid = 1
          sub(/^description:[[:space:]]*/, "")
          if ($0 == "" || index("|>\"\047&*!{[#", substr($0, 1, 1))) invalid = 1
          value = $0
          in_description = 1
          next
        }
        in_fm && in_description && /^[[:space:]]+[^[:space:]#]/ { invalid = 1 }
        in_fm && /^[^[:space:]#]/ { in_description = 0 }
        END {
          if (!closed || !found || invalid) exit 1
          printf "%s", value
        }
      ' "$file"
    )"; then
      fail "$file description must be single-line plain text inside closed frontmatter; fix: close frontmatter with --- and use one nonempty unquoted description line without YAML block syntax or continuation lines"
      continue
    fi
    description_bytes="$(printf '%s' "$description" | wc -c | tr -d ' ')"
    [ "$description_bytes" -le "$SKILL_DESCRIPTION_MAX_BYTES" ] ||
      fail "skill description over budget: $file description is $description_bytes bytes (max $SKILL_DESCRIPTION_MAX_BYTES); fix: keep only trigger conditions and boundaries in description"
  done
  [ "$total" -le "$SKILL_ENTRIES_TOTAL_MAX_BYTES" ] ||
    fail "skill entries total over budget: $total bytes (max $SKILL_ENTRIES_TOTAL_MAX_BYTES); fix: remove duplicated rules across entries or move them into references/"
  for file in skills/ssf-*/references/*.md; do
    [ -f "$file" ] || continue
    bytes="$(wc -c < "$file" | tr -d ' ')"
    [ "$bytes" -le "$SKILL_REFERENCE_MAX_BYTES" ] ||
      fail "skill reference over budget: $file is $bytes bytes (max $SKILL_REFERENCE_MAX_BYTES); fix: split by task signal into a separate reference and link it from SKILL.md"
  done
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
check_skill_budgets
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
