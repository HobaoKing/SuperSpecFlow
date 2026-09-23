#!/usr/bin/env bats
# update.sh 主路径回归测试：参数透传、按已安装范围探测、--version 不安装。

load '../lib/test_helper'

setup() {
  HOME_DIR="$(ssf_make_tmp_home)"
  UPDATE="$REPO_ROOT/update.sh"
  export HOME="$HOME_DIR"
  rm -rf "$HOME_DIR/.claude" "$HOME_DIR/.codex" "$HOME_DIR/.gemini"
}

teardown() {
  ssf_cleanup_tmp "$HOME_DIR"
}

@test "透传：--claude-only 被接受且只更新 Claude，不新增其他宿主" {
  bash "$REPO_ROOT/scripts/install-global.sh" --claude-only --yes --no-hook >/dev/null 2>&1

  run "$UPDATE" --claude-only --yes --no-hook
  [ "$status" -eq 0 ]
  [ -f "$HOME/.claude/skills/ssf-qa/SKILL.md" ]
  [ ! -e "$HOME/.codex" ]
  [ ! -e "$HOME/.gemini" ]
}

@test "透传：--antigravity-only 与 --append 组合可用" {
  mkdir -p "$HOME/.gemini"
  printf 'RULES\n' > "$HOME/.gemini/GEMINI.md"

  run "$UPDATE" --antigravity-only --yes --no-hook --append
  [ "$status" -eq 0 ]
  grep -Fq "GEMINI.global.md" "$HOME/.gemini/GEMINI.md"
  grep -Fxq "RULES" "$HOME/.gemini/GEMINI.md"
  [ ! -e "$HOME/.claude" ]
  [ ! -e "$HOME/.codex" ]
}

@test "探测：仅有 Claude 安装记录时不扩散到 Codex 与 Antigravity" {
  bash "$REPO_ROOT/scripts/install-global.sh" --claude-only --yes --no-hook >/dev/null 2>&1

  run "$UPDATE" --yes --no-hook
  [ "$status" -eq 0 ]
  [[ "$output" == *"--claude-only"* ]]
  [ -f "$HOME/.claude/skills/ssf-qa/SKILL.md" ]
  [ ! -e "$HOME/.codex" ]
  [ ! -e "$HOME/.gemini" ]
}

@test "探测：三家都有安装记录时回落 --all 全部更新" {
  bash "$REPO_ROOT/scripts/install-global.sh" --all --yes --no-hook >/dev/null 2>&1

  run "$UPDATE" --yes --no-hook
  [ "$status" -eq 0 ]
  [[ "$output" == *"--all"* ]]
  [ -f "$HOME/.claude/skills/ssf-qa/SKILL.md" ]
  [ -f "$HOME/.codex/skills/ssf-qa/SKILL.md" ]
  [ -f "$HOME/.gemini/config/skills/ssf-qa/SKILL.md" ]
}

@test "探测：Claude+Codex 两家都有安装记录时收敛为 --both" {
  bash "$REPO_ROOT/scripts/install-global.sh" --both --yes --no-hook >/dev/null 2>&1

  run "$UPDATE" --yes --no-hook
  [ "$status" -eq 0 ]
  [[ "$output" == *"--both"* ]]
  [ -f "$HOME/.claude/skills/ssf-qa/SKILL.md" ]
  [ -f "$HOME/.codex/skills/ssf-qa/SKILL.md" ]
  [ ! -e "$HOME/.gemini" ]
}

@test "探测：没有任何安装记录时默认安装全部宿主" {
  run "$UPDATE" --yes --no-hook
  [ "$status" -eq 0 ]
  [[ "$output" == *"--all"* ]]
  [ -f "$HOME/.claude/skills/ssf-qa/SKILL.md" ]
  [ -f "$HOME/.gemini/config/skills/ssf-qa/SKILL.md" ]
}

@test "显式目标优先于探测结果" {
  bash "$REPO_ROOT/scripts/install-global.sh" --claude-only --yes --no-hook >/dev/null 2>&1

  run "$UPDATE" --codex-only --yes --no-hook
  [ "$status" -eq 0 ]
  [[ "$output" != *"按已安装范围更新"* ]]
  [ -f "$HOME/.codex/skills/ssf-qa/SKILL.md" ]
}

@test "--version 只打印版本，不安装" {
  run "$UPDATE" --version
  [ "$status" -eq 0 ]
  [ "$output" = "SuperSpecFlow $(cat "$REPO_ROOT/VERSION")" ]
  [ ! -e "$HOME/.claude" ]
  [ ! -e "$HOME/.codex" ]
  [ ! -e "$HOME/.gemini" ]
}

@test "--enable-natural-language 在安装后创建 enabled 标记" {
  PROJECT="$(ssf_make_tmp_project)"

  run "$UPDATE" --enable-natural-language "$PROJECT" --yes --no-hook
  [ "$status" -eq 0 ]
  [ -f "$PROJECT/.superspecflow/enabled" ]

  ssf_cleanup_tmp "$PROJECT"
}
