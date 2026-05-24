#!/usr/bin/env bats

load '../lib/test_helper'

setup() {
  HOME_DIR="$(ssf_make_tmp_home)"
  INSTALL="$REPO_ROOT/scripts/install-global.sh"
  # 隔离用户环境
  export HOME="$HOME_DIR"
  rm -rf "$HOME_DIR/.claude" "$HOME_DIR/.codex"
}

teardown() {
  ssf_cleanup_tmp "$HOME_DIR"
}

@test "首次运行：~/.claude/CLAUDE.md 不存在时直接创建并写入 include 行" {
  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]
  [ -f "$HOME/.claude/CLAUDE.md" ]
  grep -q "routing/CLAUDE.global.md" "$HOME/.claude/CLAUDE.md"
}

@test "首次运行：~/.codex/AGENTS.md 不存在时直接创建并写入 include 行" {
  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]
  [ -f "$HOME/.codex/AGENTS.md" ]
  grep -q "routing/AGENTS.global.md" "$HOME/.codex/AGENTS.md"
}

@test "已有 CLAUDE.md 且已含 include 行：脚本跳过，文件不变" {
  mkdir -p "$HOME/.claude"
  printf 'EXISTING\n@%s/routing/CLAUDE.global.md\n' "$REPO_ROOT" > "$HOME/.claude/CLAUDE.md"
  before="$(cat "$HOME/.claude/CLAUDE.md")"
  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.claude/CLAUDE.md")" = "$before" ]
}

@test "已有 CLAUDE.md 但缺 include 行：脚本不擅自改写，打印应追加的行" {
  mkdir -p "$HOME/.claude"
  printf 'EXISTING\n' > "$HOME/.claude/CLAUDE.md"
  before="$(cat "$HOME/.claude/CLAUDE.md")"
  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.claude/CLAUDE.md")" = "$before" ]
  [[ "$output" == *"@${REPO_ROOT}/routing/CLAUDE.global.md"* ]]
  [[ "$output" == *"请手动追加"* || "$output" == *"manually append"* ]]
}

@test "--no-hook 时不打印 hook 配置片段" {
  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]
  [[ "$output" != *"session-start-detect.sh"* ]]
}

@test "默认（带 hook）打印 settings.json 应合并的官方 schema JSON 片段，且不擅自改写" {
  mkdir -p "$HOME/.claude"
  printf '{}' > "$HOME/.claude/settings.json"
  before="$(cat "$HOME/.claude/settings.json")"
  run "$INSTALL" --yes
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.claude/settings.json")" = "$before" ]
  # 官方 hook schema 关键字段必须全部出现
  [[ "$output" == *"session-start-detect.sh"* ]]
  [[ "$output" == *"SessionStart"* ]]
  [[ "$output" == *"matcher"* ]]
  [[ "$output" == *"\"type\": \"command\""* ]] || [[ "$output" == *"\"type\":\"command\""* ]]
}

@test "退出码恒为 0（脚本不应因用户拒绝合并而失败）" {
  mkdir -p "$HOME/.claude"
  printf 'EXISTING\n' > "$HOME/.claude/CLAUDE.md"
  run "$INSTALL" --yes
  [ "$status" -eq 0 ]
}
