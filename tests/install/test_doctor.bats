#!/usr/bin/env bats
load '../lib/test_helper'

# 每项测试使用独立 HOME 并安装当前源码，诊断不会接触真实用户配置。
setup() {
  HOME_DIR="$BATS_TEST_TMPDIR/home with spaces"
  mkdir -p "$HOME_DIR"
  env HOME="$HOME_DIR" bash "$REPO_ROOT/scripts/install-global.sh" --codex-only --yes >/dev/null
  SKILL_DIR="$HOME_DIR/.codex/skills/ssf-build"
}

@test "只读诊断接受完整安装并且不修改安装内容" {
  source "$REPO_ROOT/scripts/install-state.sh"
  before="$(dir_checksum "$HOME_DIR")"
  run env HOME="$HOME_DIR" bash "$REPO_ROOT/scripts/doctor.sh" --codex-only
  [ "$status" -eq 0 ]
  [[ "$output" == *'待处理项：0'* ]]
  [[ "$output" == *'不证明当前会话使用了 skill'* ]]
  [ "$(dir_checksum "$HOME_DIR")" = "$before" ]
}

@test "诊断区分缺失能力与规则未接入而不自动修复" {
  rm -r "$SKILL_DIR"
  printf '# @%s\n' "$HOME_DIR/.codex/superspecflow/AGENTS.global.md" > "$HOME_DIR/.codex/AGENTS.md"
  run env HOME="$HOME_DIR" bash "$REPO_ROOT/scripts/doctor.sh" --codex-only
  [ "$status" -eq 1 ]
  [[ "$output" == *'MISSING'* ]]
  [[ "$output" == *'DISCONNECTED'* ]]
  [ ! -e "$SKILL_DIR" ]
}

@test "诊断区分用户修改与已安装但过期的副本" {
  printf '\nlocal change\n' >> "$SKILL_DIR/SKILL.md"
  run env HOME="$HOME_DIR" bash "$REPO_ROOT/scripts/doctor.sh" --codex-only
  [ "$status" -eq 1 ]
  [[ "$output" == *'MODIFIED'* ]]
  source "$REPO_ROOT/scripts/install-state.sh"
  record_manifest "$HOME_DIR/.codex/superspecflow/install-manifest.tsv" D "$(dir_checksum "$SKILL_DIR")" "$SKILL_DIR"
  run env HOME="$HOME_DIR" bash "$REPO_ROOT/scripts/doctor.sh" --codex-only
  [ "$status" -eq 1 ]
  [[ "$output" == *'STALE'* ]]
  [[ "$output" != *'MODIFIED'* ]]
}

@test "内容相同但缺清单或归属标记不能报告完整安装" {
  rm "$SKILL_DIR/.superspecflow-installed"
  rm "$HOME_DIR/.codex/superspecflow/install-manifest.tsv"
  run env HOME="$HOME_DIR" bash "$REPO_ROOT/scripts/doctor.sh" --codex-only
  [ "$status" -eq 1 ]
  [[ "$output" == *'UNOWNED'* ]]
}

@test "诊断拒绝能力目录软链和 FIFO 而不读取或替换" {
  mkfifo "$SKILL_DIR/pipe"
  mv "$HOME_DIR/.codex/skills/ssf-review" "$HOME_DIR/review"
  ln -s "$HOME_DIR/review" "$HOME_DIR/.codex/skills/ssf-review"
  run env HOME="$HOME_DIR" bash "$REPO_ROOT/scripts/doctor.sh" --codex-only
  [ "$status" -eq 1 ]
  [[ "$output" == *'UNVERIFIABLE'* ]]
  [ -p "$SKILL_DIR/pipe" ]
  [ -L "$HOME_DIR/.codex/skills/ssf-review" ]
}

@test "诊断发现规则漂移与其他源码来源" {
  printf 'other source\n' > "$HOME_DIR/.codex/superspecflow/pack-root"
  printf 'old rules\n' > "$HOME_DIR/.codex/superspecflow/AGENTS.global.md"
  run env HOME="$HOME_DIR" bash "$REPO_ROOT/scripts/doctor.sh" --codex-only
  [ "$status" -eq 1 ]
  [[ "$output" == *'SOURCE'* ]]
  [[ "$output" == *'STALE'* ]]
}

@test "所有宿主的实际安装产物都能被诊断并发现 Claude 命令漂移" {
  env HOME="$HOME_DIR" bash "$REPO_ROOT/scripts/install-global.sh" --all --yes >/dev/null
  run env HOME="$HOME_DIR" bash "$REPO_ROOT/scripts/doctor.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *'[antigravity]'* ]]
  printf 'local change\n' >> "$HOME_DIR/.claude/commands/ssf-build.md"
  run env HOME="$HOME_DIR" bash "$REPO_ROOT/scripts/doctor.sh" --claude-only
  [ "$status" -eq 1 ]
  [[ "$output" == *'MODIFIED'* ]]
}

@test "无安装时诊断不创建目录并拒绝冲突选项" {
  run env HOME="$HOME_DIR/absent" bash "$REPO_ROOT/scripts/doctor.sh" --codex-only
  [ "$status" -eq 1 ]
  [ ! -e "$HOME_DIR/absent" ]
  run bash "$REPO_ROOT/scripts/doctor.sh" --codex-only --all
  [ "$status" -eq 2 ]
}
