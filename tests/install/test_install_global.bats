#!/usr/bin/env bats

load '../lib/test_helper'

setup() {
  HOME_DIR="$(ssf_make_tmp_home)"
  INSTALL="$REPO_ROOT/scripts/install-global.sh"
  UNINSTALL="$REPO_ROOT/scripts/uninstall-global.sh"
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
  grep -q ".claude/superspecflow/CLAUDE.global.md" "$HOME/.claude/CLAUDE.md"
}

@test "首次运行：~/.codex/AGENTS.md 不存在时直接创建并写入 include 行" {
  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]
  [ -f "$HOME/.codex/AGENTS.md" ]
  grep -q ".codex/superspecflow/AGENTS.global.md" "$HOME/.codex/AGENTS.md"
}

@test "首次运行：安装 Claude commands skills agents 和 Codex skills" {
  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]
  [ -f "$HOME/.claude/commands/ssf-init.md" ]
  [ -f "$HOME/.claude/skills/ssf-qa/SKILL.md" ]
  [ -f "$HOME/.claude/agents/qa-gatekeeper.md" ]
  [ -f "$HOME/.codex/skills/ssf-qa/SKILL.md" ]
}

@test "首次运行：生成不含 <repo> 占位符的 global wrapper" {
  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]

  claude_wrapper="${HOME}/.claude/superspecflow/CLAUDE.global.md"
  codex_wrapper="${HOME}/.codex/superspecflow/AGENTS.global.md"
  [ -f "$claude_wrapper" ]
  [ -f "$codex_wrapper" ]
  ! grep -q '<repo>' "$claude_wrapper"
  ! grep -q '<repo>' "$codex_wrapper"
  grep -q "$REPO_ROOT/routing/CLAUDE.routing.md" "$claude_wrapper"
  grep -q "$REPO_ROOT/routing/AGENTS.routing.md" "$codex_wrapper"
}

@test "已有 CLAUDE.md 且已含 include 行：脚本跳过，文件不变" {
  mkdir -p "$HOME/.claude"
  printf 'EXISTING\n@%s/.claude/superspecflow/CLAUDE.global.md\n' "$HOME" > "$HOME/.claude/CLAUDE.md"
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
  [[ "$output" == *"@${HOME}/.claude/superspecflow/CLAUDE.global.md"* ]]
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

@test "卸载会移除 include、generated wrappers 和已安装能力文件" {
  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]

  run "$UNINSTALL" --both
  [ "$status" -eq 0 ]
  [ ! -e "$HOME/.claude/CLAUDE.md" ]
  [ ! -e "$HOME/.codex/AGENTS.md" ]
  [ ! -e "$HOME/.claude/superspecflow/CLAUDE.global.md" ]
  [ ! -e "$HOME/.codex/superspecflow/AGENTS.global.md" ]
  [ ! -e "$HOME/.claude/commands/ssf-init.md" ]
  [ ! -e "$HOME/.claude/skills/ssf-qa" ]
  [ ! -e "$HOME/.claude/agents/qa-gatekeeper.md" ]
  [ ! -e "$HOME/.codex/skills/ssf-qa" ]
}

@test "安装不会覆盖已有同名用户能力文件，卸载也不会删除它们" {
  mkdir -p "$HOME/.claude/commands" "$HOME/.claude/skills/ssf-qa" "$HOME/.claude/agents" "$HOME/.codex/skills/ssf-qa"
  printf 'USER COMMAND\n' > "$HOME/.claude/commands/ssf-init.md"
  printf 'USER SKILL\n' > "$HOME/.claude/skills/ssf-qa/SKILL.md"
  printf 'USER AGENT\n' > "$HOME/.claude/agents/code-reviewer.md"
  printf 'USER CODEX SKILL\n' > "$HOME/.codex/skills/ssf-qa/SKILL.md"

  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.claude/commands/ssf-init.md")" = "USER COMMAND" ]
  [ "$(cat "$HOME/.claude/skills/ssf-qa/SKILL.md")" = "USER SKILL" ]
  [ "$(cat "$HOME/.claude/agents/code-reviewer.md")" = "USER AGENT" ]
  [ "$(cat "$HOME/.codex/skills/ssf-qa/SKILL.md")" = "USER CODEX SKILL" ]

  run "$UNINSTALL" --both
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.claude/commands/ssf-init.md")" = "USER COMMAND" ]
  [ "$(cat "$HOME/.claude/skills/ssf-qa/SKILL.md")" = "USER SKILL" ]
  [ "$(cat "$HOME/.claude/agents/code-reviewer.md")" = "USER AGENT" ]
  [ "$(cat "$HOME/.codex/skills/ssf-qa/SKILL.md")" = "USER CODEX SKILL" ]
}

@test "重装和卸载不会覆盖或删除用户修改过的已安装能力文件" {
  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]

  printf 'LOCAL COMMAND EDIT\n' > "$HOME/.claude/commands/ssf-init.md"
  printf 'LOCAL CLAUDE SKILL EDIT\n' > "$HOME/.claude/skills/ssf-qa/SKILL.md"
  printf 'LOCAL CODEX SKILL EDIT\n' > "$HOME/.codex/skills/ssf-qa/SKILL.md"

  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.claude/commands/ssf-init.md")" = "LOCAL COMMAND EDIT" ]
  [ "$(cat "$HOME/.claude/skills/ssf-qa/SKILL.md")" = "LOCAL CLAUDE SKILL EDIT" ]
  [ "$(cat "$HOME/.codex/skills/ssf-qa/SKILL.md")" = "LOCAL CODEX SKILL EDIT" ]

  run "$UNINSTALL" --both
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.claude/commands/ssf-init.md")" = "LOCAL COMMAND EDIT" ]
  [ "$(cat "$HOME/.claude/skills/ssf-qa/SKILL.md")" = "LOCAL CLAUDE SKILL EDIT" ]
  [ "$(cat "$HOME/.codex/skills/ssf-qa/SKILL.md")" = "LOCAL CODEX SKILL EDIT" ]
}
