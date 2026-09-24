#!/usr/bin/env bats

load '../lib/test_helper'

setup() {
  HOME_DIR="$(ssf_make_tmp_home)"
  INSTALL="$REPO_ROOT/scripts/install-global.sh"
  UNINSTALL="$REPO_ROOT/scripts/uninstall-global.sh"
  # 隔离用户环境
  export HOME="$HOME_DIR"
  rm -rf "$HOME_DIR/.claude" "$HOME_DIR/.codex" "$HOME_DIR/.gemini"
}

teardown() {
  ssf_cleanup_tmp "$HOME_DIR"
}

@test "首次运行：~/.gemini/GEMINI.md 不存在时直接创建并写入 include 行" {
  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]
  [ -f "$HOME/.gemini/GEMINI.md" ]
  grep -q ".gemini/superspecflow/GEMINI.global.md" "$HOME/.gemini/GEMINI.md"
}

@test "首次运行：Antigravity skills 安装到 IDE 与 CLI 两个全局目录，不安装 commands" {
  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]
  [ -f "$HOME/.gemini/config/skills/ssf-qa/SKILL.md" ]
  [ -f "$HOME/.gemini/antigravity-cli/skills/ssf-plan/SKILL.md" ]
  [ ! -e "$HOME/.gemini/commands" ]
}

@test "首次运行：生成自包含、不含 <repo> 占位符的 GEMINI global wrapper" {
  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]
  wrapper="${HOME}/.gemini/superspecflow/GEMINI.global.md"
  [ -f "$wrapper" ]
  ! grep -q '<repo>' "$wrapper"
  ! grep -q '<pack>' "$wrapper"
  grep -q 'SuperSpecFlow 轻量规则' "$wrapper"
  ! grep -q '^@' "$wrapper"
}

@test "--antigravity-only 只安装 Antigravity，不写 Claude 与 Codex" {
  run "$INSTALL" --antigravity-only --yes --no-hook
  [ "$status" -eq 0 ]
  [ -f "$HOME/.gemini/GEMINI.md" ]
  [ ! -e "$HOME/.claude" ]
  [ ! -e "$HOME/.codex" ]
}

@test "默认安装同时覆盖 Claude Code、Codex 与 Antigravity" {
  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]
  [ -f "$HOME/.claude/skills/ssf-qa/SKILL.md" ]
  [ -f "$HOME/.codex/skills/ssf-qa/SKILL.md" ]
  [ -f "$HOME/.gemini/config/skills/ssf-qa/SKILL.md" ]
}

@test "--all 安装三家" {
  run "$INSTALL" --all --yes --no-hook
  [ "$status" -eq 0 ]
  [ -f "$HOME/.gemini/config/skills/ssf-qa/SKILL.md" ]
  [ -f "$HOME/.claude/skills/ssf-qa/SKILL.md" ]
  [ -f "$HOME/.codex/skills/ssf-qa/SKILL.md" ]
}

@test "--both 保持仅安装 Claude Code 与 Codex" {
  run "$INSTALL" --both --yes --no-hook
  [ "$status" -eq 0 ]
  [ -f "$HOME/.codex/AGENTS.md" ]
  [ -f "$HOME/.claude/CLAUDE.md" ]
  [ ! -e "$HOME/.gemini" ]
}

@test "--codex-only 不安装 Antigravity" {
  run "$INSTALL" --codex-only --yes --no-hook
  [ "$status" -eq 0 ]
  [ -f "$HOME/.codex/AGENTS.md" ]
  [ ! -e "$HOME/.gemini" ]
}

@test "--claude-only 不安装 Antigravity" {
  run "$INSTALL" --claude-only --yes --no-hook
  [ "$status" -eq 0 ]
  [ -f "$HOME/.claude/CLAUDE.md" ]
  [ ! -e "$HOME/.gemini" ]
}

@test "卸载 --claude-only 不触碰 ~/.gemini 下的 include 与 skills" {
  run "$INSTALL" --all --yes --no-hook
  [ "$status" -eq 0 ]
  before="$(cat "$HOME/.gemini/GEMINI.md")"

  run "$UNINSTALL" --claude-only
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.gemini/GEMINI.md")" = "$before" ]
  [ -f "$HOME/.gemini/config/skills/ssf-qa/SKILL.md" ]
  [ -f "$HOME/.gemini/antigravity-cli/skills/ssf-qa/SKILL.md" ]
}

@test "卸载 --codex-only 不触碰 ~/.gemini 下的 include 与 skills" {
  run "$INSTALL" --all --yes --no-hook
  [ "$status" -eq 0 ]
  before="$(cat "$HOME/.gemini/GEMINI.md")"

  run "$UNINSTALL" --codex-only
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.gemini/GEMINI.md")" = "$before" ]
  [ -f "$HOME/.gemini/config/skills/ssf-qa/SKILL.md" ]
  [ -f "$HOME/.gemini/antigravity-cli/skills/ssf-qa/SKILL.md" ]
}

@test "已有 GEMINI.md 但缺 include 行：脚本不擅自改写，打印应追加的行" {
  mkdir -p "$HOME/.gemini"
  printf 'GEMINI RULES\n' > "$HOME/.gemini/GEMINI.md"
  before="$(cat "$HOME/.gemini/GEMINI.md")"
  run "$INSTALL" --antigravity-only --yes --no-hook
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.gemini/GEMINI.md")" = "$before" ]
  [[ "$output" == *"@${HOME}/.gemini/superspecflow/GEMINI.global.md"* ]]
}

@test "已有 GEMINI.md 缺 include 行：--append 自动追加到文件顶部并保留原内容" {
  mkdir -p "$HOME/.gemini"
  printf 'GEMINI RULES\n' > "$HOME/.gemini/GEMINI.md"
  run "$INSTALL" --antigravity-only --yes --no-hook --append
  [ "$status" -eq 0 ]
  [[ "$output" == *"appended SuperSpecFlow include to"* ]]
  [ "$(head -n 1 "$HOME/.gemini/GEMINI.md")" = "@${HOME}/.gemini/superspecflow/GEMINI.global.md" ]
  grep -Fxq "GEMINI RULES" "$HOME/.gemini/GEMINI.md"
}

@test "卸载 --antigravity-only 精确移除 include 并清理已安装能力，用户内容保留" {
  mkdir -p "$HOME/.gemini"
  printf 'GEMINI RULES\n' > "$HOME/.gemini/GEMINI.md"
  run "$INSTALL" --antigravity-only --yes --no-hook --append
  [ "$status" -eq 0 ]
  run "$UNINSTALL" --antigravity-only
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.gemini/GEMINI.md")" = "GEMINI RULES" ]
  [ ! -e "$HOME/.gemini/config/skills/ssf-qa" ]
  [ ! -e "$HOME/.gemini/antigravity-cli/skills/ssf-qa" ]
  [ ! -e "$HOME/.gemini/superspecflow" ]
}

@test "默认安装后 --all 卸载三家，include 与能力目录清空" {
  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]
  run "$UNINSTALL" --all
  [ "$status" -eq 0 ]
  [ ! -e "$HOME/.gemini/config/skills/ssf-qa" ]
  [ ! -e "$HOME/.gemini/antigravity-cli/skills/ssf-plan" ]
  [ ! -e "$HOME/.gemini/superspecflow" ]
}

@test "Antigravity 用户已存在的 skills 不被覆盖，卸载也不删除" {
  mkdir -p "$HOME/.gemini/config/skills/ssf-qa" "$HOME/.gemini/antigravity-cli/skills/ssf-qa"
  printf 'USER IDE SKILL\n' > "$HOME/.gemini/config/skills/ssf-qa/SKILL.md"
  printf 'USER CLI SKILL\n' > "$HOME/.gemini/antigravity-cli/skills/ssf-qa/SKILL.md"

  run "$INSTALL" --antigravity-only --yes --no-hook
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.gemini/config/skills/ssf-qa/SKILL.md")" = "USER IDE SKILL" ]
  [ "$(cat "$HOME/.gemini/antigravity-cli/skills/ssf-qa/SKILL.md")" = "USER CLI SKILL" ]

  run "$UNINSTALL" --all
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.gemini/config/skills/ssf-qa/SKILL.md")" = "USER IDE SKILL" ]
  [ "$(cat "$HOME/.gemini/antigravity-cli/skills/ssf-qa/SKILL.md")" = "USER CLI SKILL" ]
}

@test "Antigravity skills 的本地修改受重装与卸载保护" {
  run "$INSTALL" --antigravity-only --yes --no-hook
  [ "$status" -eq 0 ]

  printf 'LOCAL SKILL EDIT\n' > "$HOME/.gemini/config/skills/ssf-qa/SKILL.md"
  run "$INSTALL" --antigravity-only --yes --no-hook
  [ "$status" -eq 0 ]
  [[ "$output" == *"skipped"* ]]
  [ "$(cat "$HOME/.gemini/config/skills/ssf-qa/SKILL.md")" = "LOCAL SKILL EDIT" ]

  run "$UNINSTALL" --antigravity-only
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.gemini/config/skills/ssf-qa/SKILL.md")" = "LOCAL SKILL EDIT" ]
}

@test "安装结尾给出 Antigravity 生效说明" {
  run "$INSTALL" --antigravity-only --yes --no-hook
  [ "$status" -eq 0 ]
  [[ "$output" == *"Antigravity"* ]]
  [[ "$output" == *"GEMINI.md"* ]]
}

@test "批量目标选项互斥：--antigravity-only 与 --both 同传时报错退出" {
  run "$INSTALL" --antigravity-only --both --yes --no-hook
  [ "$status" -eq 2 ]
}
