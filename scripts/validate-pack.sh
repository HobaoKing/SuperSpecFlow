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

check_no_legacy_command_prefix() {
  local legacy_prefix
  legacy_prefix='ssf:'

  if rg --hidden -n "$legacy_prefix" \
    --glob '!.git/**' \
    --glob '!scripts/validate-pack.sh' \
    --glob '!templates/git-hooks/commit-msg' \
    . >/tmp/ssf-legacy-prefix.txt; then
    cat /tmp/ssf-legacy-prefix.txt >&2
    fail "发现旧命令前缀残留，请统一使用 /ssf-xxx 和 commands/ssf-xxx.md"
  else
    pass "未发现旧命令前缀残留"
  fi
}

check_no_hw_prefix() {
  if rg --hidden -n '(^|[^A-Za-z0-9_/-])/?hw[-:]|commands/hw[-:]|skills/hw-' \
    --glob '!.git/**' \
    --glob '!scripts/validate-pack.sh' \
    . >/tmp/ssf-hw-prefix.txt; then
    cat /tmp/ssf-hw-prefix.txt >&2
    fail "发现 hw 旧前缀残留"
  else
    pass "未发现 hw 旧前缀残留"
  fi
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
  local expected actual doc expected_file actual_file

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

check_no_legacy_command_prefix
check_no_hw_prefix
check_no_colon_filenames
check_skill_frontmatter
check_command_file_names
check_command_docs_consistency

if [ "$FAILED" -ne 0 ]; then
  exit 1
fi

printf 'SuperSpecFlow pack validation passed.\n'
