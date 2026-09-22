#!/usr/bin/env bash
set -euo pipefail

msg_file="${1:-}"
if [ -z "$msg_file" ] || [ ! -f "$msg_file" ]; then
  echo "error: commit message file is required" >&2
  exit 2
fi

msg="$(cat "$msg_file")"
first_line="$(head -n 1 "$msg_file")"

# 判断是否包含非 ASCII 文本，兼容不同 locale；这只是中文规范的粗检，不做语言识别。
has_non_ascii_text() {
  LC_ALL=C grep -Eq '[^ -~[:space:]]'
}

if ! printf '%s' "$msg" | has_non_ascii_text; then
  echo "错误：commit 标题必须包含中文。" >&2
  exit 1
fi

if printf '%s' "$first_line" | grep -Eiq '^(wip|update|updates|change|changes|fix bug|misc|temp)$'; then
  echo "错误：commit 标题过于模糊。请使用格式：<英文类型>(<英文范围>): <中文摘要>" >&2
  exit 1
fi

type_re='(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert|spec)'
scope_re='\([a-z0-9][a-z0-9:_-]*\)'
if ! printf '%s' "$first_line" | grep -Eq "^${type_re}${scope_re}: .+" ||
   ! printf '%s' "$first_line" | has_non_ascii_text; then
  echo "错误：commit 标题必须符合 <英文类型>(<英文范围>): <中文摘要> 格式。" >&2
  exit 1
fi
