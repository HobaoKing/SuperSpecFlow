#!/usr/bin/env bash
set -euo pipefail

msg_file="${1:-}"
if [ -z "$msg_file" ] || [ ! -f "$msg_file" ]; then
  echo "error: commit message file is required" >&2
  exit 2
fi

msg="$(cat "$msg_file")"
first_line="$(head -n 1 "$msg_file")"

if ! printf '%s' "$msg" | grep -Eq '[一-龥]'; then
  echo "错误：commit 摘要与正文必须包含中文。" >&2
  exit 1
fi

if printf '%s' "$first_line" | grep -Eiq '^(wip|update|updates|change|changes|fix bug|misc|temp)$'; then
  echo "错误：commit 标题过于模糊。请使用格式：<英文类型>(<英文范围>): <中文摘要>" >&2
  exit 1
fi

type_re='(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert|spec)'
scope_re='\([a-z0-9][a-z0-9:_-]*\)'
if ! printf '%s' "$first_line" | grep -Eq "^${type_re}${scope_re}: .*[一-龥]"; then
  echo "错误：commit 标题必须符合 <英文类型>(<英文范围>): <中文摘要> 格式。" >&2
  exit 1
fi

for field in '变更编号：' '关联规格：' '变更内容：' '验证方式：' '风险与回滚：'; do
  if ! printf '%s\n' "$msg" | grep -Fq "$field"; then
    echo "错误：commit 正文缺少 $field" >&2
    exit 1
  fi
done

if printf '%s\n' "$msg" | grep -Eq '变更编号：[[:space:]]*$'; then
  echo "错误：变更编号不能为空。" >&2
  exit 1
fi

if printf '%s\n' "$msg" | grep -Eq '关联规格：[[:space:]]*$'; then
  echo "错误：关联规格不能为空。" >&2
  exit 1
fi
