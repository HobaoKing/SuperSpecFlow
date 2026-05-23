#!/usr/bin/env bats

load '../lib/test_helper'

setup() {
  PROJECT="$(ssf_make_tmp_project)"
  HOOK="$REPO_ROOT/scripts/hooks/session-start-detect.sh"
}

teardown() {
  ssf_cleanup_tmp "$PROJECT"
}

# 解析 JSON 中 additionalContext 字段的工具函数（不依赖 jq，使用 grep + sed）
extract_context() {
  # 输入：JSON 单行；输出：additionalContext 字符串值
  printf '%s' "$1" | sed -nE 's/.*"additionalContext":"([^"]*)".*/\1/p'
}

@test "cwd 无 .superspecflow/enabled 时 additionalContext 为 disabled 标签" {
  cd "$PROJECT"
  run "$HOOK"
  [ "$status" -eq 0 ]
  ctx="$(extract_context "$output")"
  [ "$ctx" = "<ssf-status>disabled</ssf-status>" ]
}

@test "cwd 有 .superspecflow/enabled 时 additionalContext 为 enabled 标签" {
  mkdir -p "$PROJECT/.superspecflow"
  touch "$PROJECT/.superspecflow/enabled"
  cd "$PROJECT"
  run "$HOOK"
  [ "$status" -eq 0 ]
  ctx="$(extract_context "$output")"
  [ "$ctx" = "<ssf-status>enabled</ssf-status>" ]
}

@test "CLAUDE_PROJECT_DIR 环境变量优先于 cwd" {
  mkdir -p "$PROJECT/.superspecflow"
  touch "$PROJECT/.superspecflow/enabled"
  cd /tmp
  CLAUDE_PROJECT_DIR="$PROJECT" run "$HOOK"
  [ "$status" -eq 0 ]
  ctx="$(extract_context "$output")"
  [ "$ctx" = "<ssf-status>enabled</ssf-status>" ]
}

@test "stdin JSON 中的 cwd 字段优先于 CLAUDE_PROJECT_DIR 和 PWD" {
  mkdir -p "$PROJECT/.superspecflow"
  touch "$PROJECT/.superspecflow/enabled"
  # PWD 与 CLAUDE_PROJECT_DIR 均指向无 sentinel 的临时目录
  OTHER="$(ssf_make_tmp_project)"
  cd "$OTHER"
  payload=$(printf '{"session_id":"x","cwd":"%s","hook_event_name":"SessionStart","source":"startup"}' "$PROJECT")
  CLAUDE_PROJECT_DIR="$OTHER" run bash -c "printf '%s' '$payload' | '$HOOK'"
  [ "$status" -eq 0 ]
  ctx="$(extract_context "$output")"
  [ "$ctx" = "<ssf-status>enabled</ssf-status>" ]
  ssf_cleanup_tmp "$OTHER"
}

@test "stdin JSON 顶层 cwd 优先于嵌套对象中的 cwd（防止 sed 贪婪回归）" {
  # 顶层 cwd 指向 enabled 项目；payload 后续嵌套对象的 cwd 指向 disabled 项目
  mkdir -p "$PROJECT/.superspecflow"
  touch "$PROJECT/.superspecflow/enabled"
  NESTED="$(ssf_make_tmp_project)"
  payload=$(printf '{"session_id":"x","cwd":"%s","hook_event_name":"SessionStart","source":"startup","tool_input":{"cwd":"%s"}}' "$PROJECT" "$NESTED")
  cd /tmp
  run bash -c "printf '%s' '$payload' | '$HOOK'"
  [ "$status" -eq 0 ]
  ctx="$(extract_context "$output")"
  [ "$ctx" = "<ssf-status>enabled</ssf-status>" ]
  ssf_cleanup_tmp "$NESTED"
}

@test "stdin JSON cwd 路径含空格时能正确解析" {
  SPACED="$(mktemp -d "${TMPDIR:-/tmp}/ssf-proj space.XXXXXX")"
  mkdir -p "$SPACED/.superspecflow"
  touch "$SPACED/.superspecflow/enabled"
  payload=$(printf '{"session_id":"x","cwd":"%s","hook_event_name":"SessionStart","source":"startup"}' "$SPACED")
  cd /tmp
  run bash -c "printf '%s' '$payload' | '$HOOK'"
  [ "$status" -eq 0 ]
  ctx="$(extract_context "$output")"
  [ "$ctx" = "<ssf-status>enabled</ssf-status>" ]
  rm -rf "$SPACED"
}

@test "输出始终是符合 hook 协议的单行 JSON" {
  cd "$PROJECT"
  run "$HOOK"
  [ "$status" -eq 0 ]
  # 必须包含官方协议三个关键字段
  [[ "$output" == *"hookSpecificOutput"* ]]
  [[ "$output" == *"\"hookEventName\":\"SessionStart\""* ]]
  [[ "$output" == *"additionalContext"* ]]
  # 必须是单行（行数 = 1）
  line_count="$(printf '%s' "$output" | wc -l | tr -d ' ')"
  [ "$line_count" = "0" ] || [ "$line_count" = "1" ]
}

@test "任何不可预期错误也只输出 disabled，不抛非零退出" {
  CLAUDE_PROJECT_DIR="/nonexistent/$(uuidgen 2>/dev/null || echo xxx)" run "$HOOK"
  [ "$status" -eq 0 ]
  ctx="$(extract_context "$output")"
  [ "$ctx" = "<ssf-status>disabled</ssf-status>" ]
}
