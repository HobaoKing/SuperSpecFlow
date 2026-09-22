#!/usr/bin/env bats

load '../lib/test_helper'

setup() {
  HOME_DIR="$(ssf_make_tmp_home)"
  PROJECT="$(ssf_make_tmp_project)"
  export HOME="$HOME_DIR"
  rm -rf "$HOME/.claude" "$HOME/.codex"
}

teardown() {
  ssf_cleanup_tmp "$HOME_DIR"
  ssf_cleanup_tmp "$PROJECT"
}

# 与 Task 2 一致：从 hook 输出 JSON 中提取 additionalContext。
extract_context() {
  printf '%s' "$1" | sed -nE 's/.*"additionalContext":"([^"]*)".*/\1/p'
}

@test "端到端：全局安装 → 默认全局开启 → hook additionalContext 为 enabled 标签（无需 init）" {
  bash "$REPO_ROOT/scripts/install-global.sh" --yes --no-hook
  [ -f "$HOME/.claude/CLAUDE.md" ]
  [ -f "$HOME/.codex/AGENTS.md" ]

  cd "$PROJECT"
  run bash "$REPO_ROOT/scripts/hooks/session-start-detect.sh"
  ctx="$(extract_context "$output")"
  [ "$ctx" = "<ssf-status>enabled</ssf-status>" ]
}

@test "端到端：显式禁用（存在 .superspecflow/disabled）→ hook 为 disabled 标签" {
  mkdir -p "$PROJECT/.superspecflow"
  touch "$PROJECT/.superspecflow/disabled"
  cd "$PROJECT"
  run bash "$REPO_ROOT/scripts/hooks/session-start-detect.sh"
  ctx="$(extract_context "$output")"
  [ "$ctx" = "<ssf-status>disabled</ssf-status>" ]
}

@test "端到端：init 恢复启用后清除 disabled 标记且宿主 CLAUDE.md / AGENTS.md 仍然零改动" {
  cd "$PROJECT"
  # 模拟宿主已有指令文件
  printf 'HOST-CLAUDE\n' > CLAUDE.md
  printf 'HOST-AGENTS\n' > AGENTS.md
  mkdir -p "$PROJECT/.superspecflow"
  touch "$PROJECT/.superspecflow/disabled"

  SSF_INIT_PROJECT_DIR="$PROJECT" bash "$REPO_ROOT/scripts/_ssf_init_apply.sh"

  [ ! -f "$PROJECT/.superspecflow/disabled" ]
  [ -f "$PROJECT/.superspecflow/enabled" ]
  [ "$(cat CLAUDE.md)" = "HOST-CLAUDE" ]
  [ "$(cat AGENTS.md)" = "HOST-AGENTS" ]

  run bash "$REPO_ROOT/scripts/hooks/session-start-detect.sh"
  ctx="$(extract_context "$output")"
  [ "$ctx" = "<ssf-status>enabled</ssf-status>" ]
}
