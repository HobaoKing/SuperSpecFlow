#!/usr/bin/env bash
# 检查两个提交之间的空白错误，与当前工作区是否 clean 无关。
# 参数为 base、head；PR 加 --merge-base 只检查本分支新增差异，push 检查前后提交差异。
# 首次 push 的空 base / 全零 SHA 以空树为基线，缺少有效提交时直接失败。
set -euo pipefail

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ] || { [ "$#" -eq 3 ] && [ "$3" != --merge-base ]; }; then
  echo 'Usage: check-commit-whitespace.sh <base-sha> <head-sha> [--merge-base]' >&2
  exit 2
fi
base="$1"
head="$(git rev-parse --verify "$2^{commit}")"
if [ -z "$base" ] || [[ "$base" =~ ^0+$ ]]; then
  base="$(git hash-object -w -t tree /dev/null)"
else
  base="$(git rev-parse --verify "$base^{commit}")"
  if [ "${3:-}" = --merge-base ]; then
    base="$(git merge-base "$base" "$head")"
  fi
fi
git diff --check "$base" "$head" --
