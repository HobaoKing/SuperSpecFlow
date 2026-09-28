#!/usr/bin/env bats
load '../lib/test_helper'

# 隔离包和 HOME，允许验证 purge 的实际删除行为而不触碰当前仓库。
setup() {
  PACK="$(ssf_make_tmp_repo_fixture)"
  HOME_DIR="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME_DIR"
}

# purge 成功时包已不存在，其余情况只清理测试创建的目录。
teardown() {
  if [ -d "$PACK" ]; then ssf_cleanup_tmp "$PACK"; fi
}

@test "更新 Codex 与 Antigravity 组合不增加 Claude" {
  env HOME="$HOME_DIR" bash "$PACK/scripts/install-global.sh" --codex-only --yes
  env HOME="$HOME_DIR" bash "$PACK/scripts/install-global.sh" --antigravity-only --yes
  run env HOME="$HOME_DIR" bash "$PACK/update.sh" --yes
  [ "$status" -eq 0 ]
  [ ! -e "$HOME_DIR/.claude" ]
  [ -f "$HOME_DIR/.codex/skills/ssf-qa/SKILL.md" ]
  [ -f "$HOME_DIR/.gemini/config/skills/ssf-qa/SKILL.md" ]
}

@test "更新 Claude 与 Antigravity 组合不增加 Codex 且透传 append" {
  env HOME="$HOME_DIR" bash "$PACK/scripts/install-global.sh" --claude-only --yes
  env HOME="$HOME_DIR" bash "$PACK/scripts/install-global.sh" --antigravity-only --yes
  printf 'USER\n' > "$HOME_DIR/.claude/CLAUDE.md"
  printf 'USER\n' > "$HOME_DIR/.gemini/GEMINI.md"
  run env HOME="$HOME_DIR" bash "$PACK/update.sh" --yes --append
  [ "$status" -eq 0 ]
  [ ! -e "$HOME_DIR/.codex" ]
  grep -Fxq "@$HOME_DIR/.claude/superspecflow/CLAUDE.global.md" "$HOME_DIR/.claude/CLAUDE.md"
  grep -Fxq "@$HOME_DIR/.gemini/superspecflow/GEMINI.global.md" "$HOME_DIR/.gemini/GEMINI.md"
}

@test "软链目标仅含 include 时卸载真正清空且保留权限" {
  mkdir -p "$HOME_DIR/.claude"
  printf '%s\n' "@$HOME_DIR/.claude/superspecflow/CLAUDE.global.md" > "$HOME_DIR/rules.md"
  chmod 640 "$HOME_DIR/rules.md"
  ln -s "$HOME_DIR/rules.md" "$HOME_DIR/.claude/CLAUDE.md"
  run env HOME="$HOME_DIR" bash "$PACK/scripts/uninstall-global.sh" --claude-only
  [ "$status" -eq 0 ]
  [ -L "$HOME_DIR/.claude/CLAUDE.md" ]
  [ -f "$HOME_DIR/rules.md" ]
  [ ! -s "$HOME_DIR/rules.md" ]
  [ "$(ssf_file_mode "$HOME_DIR/rules.md")" = 640 ]
}

@test "共享包仍被其他宿主引用时 purge 在卸载前拒绝" {
  env HOME="$HOME_DIR" bash "$PACK/scripts/install-global.sh" --both --yes
  ln -s "$PACK" "$HOME_DIR/pack-alias"
  printf '%s\n' "$HOME_DIR/pack-alias" > "$HOME_DIR/.codex/superspecflow/pack-root"
  run env HOME="$HOME_DIR" bash "$PACK/scripts/uninstall-global.sh" --claude-only --purge
  [ "$status" -ne 0 ]
  [[ "$output" == *"codex"* ]]
  [ -f "$PACK/scripts/new-plan.sh" ]
  [ -f "$HOME_DIR/.claude/CLAUDE.md" ]
  [ -f "$HOME_DIR/.claude/superspecflow/install-manifest.tsv" ]
  [ -f "$HOME_DIR/.codex/superspecflow/pack-root" ]
}

@test "包内执行 purge 在移除 include 之前拒绝" {
  env HOME="$HOME_DIR" bash "$PACK/scripts/install-global.sh" --claude-only --yes
  cd "$PACK"
  run env HOME="$HOME_DIR" bash "$PACK/scripts/uninstall-global.sh" --all --purge
  [ "$status" -ne 0 ]
  [ -f "$HOME_DIR/.claude/CLAUDE.md" ]
  [ -f "$HOME_DIR/.claude/skills/ssf-qa/SKILL.md" ]
}

@test "其他宿主引用不同包不阻断本包 purge" {
  env HOME="$HOME_DIR" bash "$PACK/scripts/install-global.sh" --claude-only --yes
  mkdir -p "$HOME_DIR/.codex/superspecflow" "$HOME_DIR/other-pack"
  printf '%s\n' "$HOME_DIR/other-pack" > "$HOME_DIR/.codex/superspecflow/pack-root"
  run env HOME="$HOME_DIR" bash "$PACK/scripts/uninstall-global.sh" --claude-only --purge
  [ "$status" -eq 0 ]
  [ ! -d "$PACK" ]
  [ -f "$HOME_DIR/.codex/superspecflow/pack-root" ]
}

@test "未追加 include 时安装汇总不声称 rules 已接入" {
  mkdir -p "$HOME_DIR/.codex"
  printf 'USER\n' > "$HOME_DIR/.codex/AGENTS.md"
  run env HOME="$HOME_DIR" bash "$PACK/scripts/install-global.sh" --codex-only --yes
  [ "$status" -eq 0 ]
  [[ "$output" == *"尚未接入"* ]]
  [[ "$output" != *"rules 已接入"* ]]
  [ "$(cat "$HOME_DIR/.codex/AGENTS.md")" = USER ]
  run env HOME="$HOME_DIR" bash "$PACK/scripts/install-global.sh" --codex-only --yes --append
  [ "$status" -eq 0 ]
  [[ "$output" == *"rules 已接入"* ]]
  [[ "$output" != *"尚未接入"* ]]
}
