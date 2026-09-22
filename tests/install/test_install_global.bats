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

@test "首次运行：安装 Claude commands skills 和 Codex skills，不创建角色目录" {
  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]
  [ -f "$HOME/.claude/commands/ssf-init.md" ]
  [ -f "$HOME/.claude/skills/ssf-qa/SKILL.md" ]
  [ ! -e "$HOME/.claude/agents" ]
  [ -f "$HOME/.codex/skills/ssf-qa/SKILL.md" ]
  [ -f "$HOME/.claude/commands/ssf-plan.md" ]
  [ -f "$HOME/.codex/skills/ssf-plan/SKILL.md" ]
  for name in spec archive retro karpathy; do
    [ ! -e "$HOME/.codex/skills/ssf-$name" ]
    [ ! -e "$HOME/.claude/commands/ssf-$name.md" ]
  done
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

@test "已有 CLAUDE.md 但缺 include 行：传入 --append 时自动追加到文件顶部" {
  mkdir -p "$HOME/.claude"
  printf 'EXISTING CONTENT\n' > "$HOME/.claude/CLAUDE.md"
  run "$INSTALL" --yes --no-hook --append
  [ "$status" -eq 0 ]
  [[ "$output" == *"appended SuperSpecFlow include to"* ]]
  first_line="$(head -n 1 "$HOME/.claude/CLAUDE.md")"
  [ "$first_line" = "@${HOME}/.claude/superspecflow/CLAUDE.global.md" ]
  grep -Fxq "EXISTING CONTENT" "$HOME/.claude/CLAUDE.md"
}

@test "已有 AGENTS.md 但缺 include 行：传入 --append 时自动追加到文件顶部" {
  mkdir -p "$HOME/.codex"
  printf 'CODEX RULES\n' > "$HOME/.codex/AGENTS.md"
  run "$INSTALL" --codex-only --yes --no-hook --append
  [ "$status" -eq 0 ]
  [[ "$output" == *"appended SuperSpecFlow include to"* ]]
  first_line="$(head -n 1 "$HOME/.codex/AGENTS.md")"
  [ "$first_line" = "@${HOME}/.codex/superspecflow/AGENTS.global.md" ]
  grep -Fxq "CODEX RULES" "$HOME/.codex/AGENTS.md"
}

@test "已有指令文件经 --append 追加后，卸载脚本可准确移除非 SuperSpecFlow 行不受影响" {
  mkdir -p "$HOME/.claude"
  printf 'USER RULES\n' > "$HOME/.claude/CLAUDE.md"
  run "$INSTALL" --claude-only --yes --no-hook --append
  [ "$status" -eq 0 ]
  run "$UNINSTALL" --claude-only
  [ "$status" -eq 0 ]
  [ -f "$HOME/.claude/CLAUDE.md" ]
  [ "$(cat "$HOME/.claude/CLAUDE.md")" = "USER RULES" ]
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
  [ ! -e "$HOME/.codex/skills/ssf-qa" ]
}

@test "安装不会覆盖已有同名用户能力文件，卸载也不会删除它们" {
  mkdir -p "$HOME/.claude/commands" "$HOME/.claude/skills/ssf-qa" "$HOME/.codex/skills/ssf-qa"
  printf 'USER COMMAND\n' > "$HOME/.claude/commands/ssf-init.md"
  printf 'USER SKILL\n' > "$HOME/.claude/skills/ssf-qa/SKILL.md"
  printf 'USER PLAN COMMAND\n' > "$HOME/.claude/commands/ssf-plan.md"
  printf 'USER CODEX SKILL\n' > "$HOME/.codex/skills/ssf-qa/SKILL.md"

  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.claude/commands/ssf-init.md")" = "USER COMMAND" ]
  [ "$(cat "$HOME/.claude/skills/ssf-qa/SKILL.md")" = "USER SKILL" ]
  [ "$(cat "$HOME/.claude/commands/ssf-plan.md")" = "USER PLAN COMMAND" ]
  [ "$(cat "$HOME/.codex/skills/ssf-qa/SKILL.md")" = "USER CODEX SKILL" ]

  run "$UNINSTALL" --both
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.claude/commands/ssf-init.md")" = "USER COMMAND" ]
  [ "$(cat "$HOME/.claude/skills/ssf-qa/SKILL.md")" = "USER SKILL" ]
  [ "$(cat "$HOME/.claude/commands/ssf-plan.md")" = "USER PLAN COMMAND" ]
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

@test "安装成功结尾引导重启会话并运行 /ssf-init（SSF-ONBOARD-001）" {
  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]
  [[ "$output" == *"重启"* ]]
  [[ "$output" == *"补全"* ]]
  [[ "$output" == *"/ssf-init"* ]]
}

@test "安装结尾提示留意 skipped 警告（SSF-ONBOARD-006）" {
  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]
  [[ "$output" == *"skipped"* ]]
}

@test "--codex-only 安装结尾不把 /ssf-init 当作可用 Claude 命令（SSF-ONBOARD-005）" {
  run "$INSTALL" --codex-only --yes --no-hook
  [ "$status" -eq 0 ]
  [[ "$output" != *"运行 /ssf-init 完成项目 opt-in"* ]]
  [[ "$output" == *"_ssf_init_apply.sh"* ]]
}

@test "精简版安装包含自包含参考和授权，Codex-only 不写 Claude" {
  run "$INSTALL" --codex-only --no-hook
  [ "$status" -eq 0 ]
  for ref in tdd.md diagnosing-bugs.md mattpocock-LICENSE.txt; do
    [ -s "$HOME/.codex/skills/ssf-build/references/$ref" ]
  done
  [ -s "$HOME/.codex/skills/ssf-review/references/code-review.md" ]
  [ ! -e "$HOME/.claude" ]
}

@test "参考文件的用户修改受到重装和卸载保护" {
  "$INSTALL" --codex-only --no-hook
  printf 'LOCAL REFERENCE\n' >> "$HOME/.codex/skills/ssf-build/references/tdd.md"
  before="$(cat "$HOME/.codex/skills/ssf-build/references/tdd.md")"
  run "$INSTALL" --codex-only --no-hook
  [ "$status" -eq 0 ]
  [[ "$output" == *"skipped"* ]]
  [ "$(cat "$HOME/.codex/skills/ssf-build/references/tdd.md")" = "$before" ]
  run "$UNINSTALL" --codex-only
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.codex/skills/ssf-build/references/tdd.md")" = "$before" ]
}
