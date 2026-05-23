#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

FAILED=0

pass() {
  printf 'PASS: %s\n' "$1"
}

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  FAILED=1
}

tmp_file() {
  mktemp "${TMPDIR:-/tmp}/ssf-validate.XXXXXX"
}

# 选择递归搜索工具。优先 ripgrep；缺失时退化到 grep -REn。
# 之前直接 `if rg ... ; then` 把 "rg 不存在 (exit 127)" 当作 "未发现残留"，造成假阳性。
if command -v rg >/dev/null 2>&1; then
  SEARCH_TOOL="rg"
else
  SEARCH_TOOL="grep"
  printf 'WARN: 未检测到 ripgrep (rg)，使用 grep -REn 退化模式。\n' >&2
fi

# 在当前目录递归搜索正则。命中 -> 输出并返回 0；未命中 -> 返回 1。
# 第 1 参数：正则
# 第 2 参数：以空格分隔的相对路径白名单（除 .git 之外要额外排除的文件）
# 第 3 参数：以空格分隔的搜索根路径列表，默认 "."
search_repo() {
  local pattern="$1"
  local exclude_str="${2:-}"
  local roots_str="${3:-.}"

  local -a exclude_paths roots
  # shellcheck disable=SC2206
  exclude_paths=( ${exclude_str} )
  # shellcheck disable=SC2206
  roots=( ${roots_str} )

  local status
  if [ "$SEARCH_TOOL" = "rg" ]; then
    local -a args
    args=(--hidden -n "$pattern" --glob '!.git/**')
    local e
    for e in "${exclude_paths[@]}"; do
      [ -n "$e" ] && args+=(--glob "!$e")
    done
    rg "${args[@]}" "${roots[@]}" && status=0 || status=$?
    return "$status"
  fi

  # grep --exclude 只匹配 basename，本仓库豁免文件名唯一，够用。
  local -a args
  args=(-REn "$pattern" --exclude-dir=.git)
  local e base
  for e in "${exclude_paths[@]}"; do
    [ -z "$e" ] && continue
    base="$(basename "$e")"
    args+=(--exclude="$base")
  done
  grep "${args[@]}" "${roots[@]}" && status=0 || status=$?
  return "$status"
}

check_no_legacy_command_prefix() {
  local out_file
  out_file="$(tmp_file)"

  if search_repo 'ssf:' \
       'scripts/validate-pack.sh templates/git-hooks/commit-msg' \
       '.' \
       >"$out_file" 2>/dev/null; then
    cat "$out_file" >&2
    fail "发现旧命令前缀残留，请统一使用 /ssf-xxx 和 commands/ssf-xxx.md"
  else
    pass "未发现旧命令前缀残留"
  fi
  rm -f "$out_file"
}

check_no_hw_prefix() {
  local out_file
  out_file="$(tmp_file)"

  if search_repo '(^|[^A-Za-z0-9_/-])/?hw[-:]|commands/hw[-:]|skills/hw-' \
       'scripts/validate-pack.sh' \
       '.' \
       >"$out_file" 2>/dev/null; then
    cat "$out_file" >&2
    fail "发现 hw 旧前缀残留"
  else
    pass "未发现 hw 旧前缀残留"
  fi
  rm -f "$out_file"
}

check_no_colon_filenames() {
  local colon_files
  colon_files="$(find . -path './.git' -prune -o -name '*:*' -print)"

  if [ -n "$colon_files" ]; then
    printf '%s\n' "$colon_files" >&2
    fail "发现包含冒号的文件名"
  else
    pass "未发现包含冒号的文件名"
  fi
}

check_no_host_instruction_overwrite() {
  local out_file
  out_file="$(tmp_file)"

  set +e
  if [ "$SEARCH_TOOL" = "rg" ]; then
    rg -n 'cp[[:space:]]+AGENTS\.md|cp[[:space:]]+CLAUDE\.md' README.md docs templates \
      >"$out_file" 2>/dev/null
  else
    grep -REn 'cp[[:space:]]+AGENTS\.md|cp[[:space:]]+CLAUDE\.md' README.md docs templates \
      >"$out_file" 2>/dev/null
  fi
  local status=$?
  set -e

  if [ "$status" -eq 0 ]; then
    cat "$out_file" >&2
    fail "发现覆盖宿主项目 AGENTS.md / CLAUDE.md 的安装说明"
  elif [ "$status" -eq 1 ]; then
    pass "未发现覆盖宿主项目指令文件的安装说明"
  else
    cat "$out_file" >&2
    fail "检查宿主项目指令覆盖说明时搜索失败"
  fi
  rm -f "$out_file"
}

check_skill_frontmatter() {
  local skill header

  for skill in skills/*/SKILL.md; do
    if [ ! -f "$skill" ]; then
      continue
    fi

    if [ "$(sed -n '1p' "$skill")" != "---" ]; then
      fail "$skill 缺少 frontmatter 起始分隔符"
      continue
    fi

    header="$(awk '
      NR == 1 && $0 == "---" { inside = 1; next }
      NR > 1 && inside && $0 == "---" { exit }
      inside { print }
    ' "$skill")"

    if ! printf '%s\n' "$header" | grep -Eq '^name:[[:space:]]*ssf-[A-Za-z0-9_-]+'; then
      fail "$skill 缺少 ssf-* 格式的 name frontmatter"
    elif ! printf '%s\n' "$header" | grep -Eq '^description:[[:space:]]*.+'; then
      fail "$skill 缺少 description frontmatter"
    else
      pass "$skill frontmatter 合法"
    fi
  done
}

check_command_docs_consistency() {
  local doc expected_file actual_file
  expected_file="$(tmp_file)"
  actual_file="$(tmp_file)"

  find commands -maxdepth 1 -type f -name 'ssf-*.md' \
    -exec basename {} .md \; \
    | sed 's#^#/#' \
    | sort -u >"$expected_file"

  for doc in README.md AGENTS.md CLAUDE.md; do
    grep -Eo '/ssf-[a-z]+' "$doc" | sort -u >"$actual_file" || true

    if diff -u "$expected_file" "$actual_file" >/tmp/ssf-command-diff.txt; then
      pass "$doc 命令集合与 commands/ 一致"
    else
      printf '%s\n' "命令集合不一致：$doc" >&2
      cat /tmp/ssf-command-diff.txt >&2
      fail "$doc 命令集合与 commands/ 不一致"
    fi
  done

  rm -f "$expected_file" "$actual_file"
}

check_command_file_names() {
  local bad_files
  bad_files="$(find commands -maxdepth 1 -type f ! -name 'ssf-*.md' -print)"

  if [ -n "$bad_files" ]; then
    printf '%s\n' "$bad_files" >&2
    fail "commands/ 下存在非 ssf-*.md 文件"
  else
    pass "commands/ 文件名均为 ssf-*.md"
  fi
}

check_routing_files() {
  local routing_file

  for routing_file in routing/AGENTS.routing.md routing/CLAUDE.routing.md; do
    if [ ! -f "$routing_file" ]; then
      fail "$routing_file 不存在"
      continue
    fi

    if ! grep -q 'Intake Gate' "$routing_file"; then
      fail "$routing_file 缺少 Intake Gate"
    elif ! grep -q '轻量任务' "$routing_file"; then
      fail "$routing_file 缺少轻量任务边界"
    elif ! grep -q 'Karpathy 编码纪律' "$routing_file"; then
      fail "$routing_file 缺少 Karpathy 编码纪律"
    elif ! grep -q '外科手术式修改' "$routing_file"; then
      fail "$routing_file 缺少外科手术式修改规则"
    elif ! grep -q '目标驱动验证' "$routing_file"; then
      fail "$routing_file 缺少目标驱动验证规则"
    else
      pass "$routing_file 包含 Intake Gate、轻量任务边界和 Karpathy 编码纪律"
    fi
  done
}

check_integration_snippets_thin() {
  local snippet

  for snippet in templates/integration/AGENTS.snippet.md templates/integration/CLAUDE.snippet.md; do
    if [ ! -f "$snippet" ]; then
      fail "$snippet 不存在"
      continue
    fi

    if ! grep -q '.superspecflow/.*routing.md' "$snippet"; then
      fail "$snippet 缺少 .superspecflow routing 引用"
    elif grep -q '^| 纯问答' "$snippet"; then
      fail "$snippet 包含完整路由表，应保持极薄入口"
    else
      pass "$snippet 是极薄入口"
    fi
  done
}

check_no_legacy_command_prefix
check_no_hw_prefix
check_no_colon_filenames
check_no_host_instruction_overwrite
check_skill_frontmatter
check_command_file_names
check_routing_files
check_integration_snippets_thin
check_command_docs_consistency

if [ "$FAILED" -ne 0 ]; then
  exit 1
fi

printf 'SuperSpecFlow pack validation passed.\n'
