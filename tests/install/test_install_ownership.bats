#!/usr/bin/env bats
load '../lib/test_helper'

# 每个用例复制源码包，允许模拟多版本变化；HOME 与包副本均为临时目录。
setup() {
  PACK="$(ssf_make_tmp_repo_fixture)"
  HOME_DIR="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME_DIR"
}

# 只清理本用例创建的包副本，HOME 由 Bats 清理。
teardown() {
  ssf_cleanup_tmp "$PACK"
}

# 从同一路径重装以模拟原位升级，避免真实宿主配置受到影响。
install_claude() {
  run env HOME="$HOME_DIR" bash "$PACK/scripts/install-global.sh" --claude-only --yes
  [ "$status" -eq 0 ]
}

@test "用户新增软链和 FIFO 在重装及卸载时均受到保护" {
  install_claude
  skill="$HOME_DIR/.claude/skills/ssf-qa"
  printf 'USER\n' > "$HOME_DIR/user.md"
  ln -s "$HOME_DIR/user.md" "$skill/reference.md"
  mkfifo "$skill/events"
  install_claude
  [ -L "$skill/reference.md" ]
  [ -p "$skill/events" ]
  [[ "$output" == *"skipped"* ]]
  run env HOME="$HOME_DIR" bash "$PACK/scripts/uninstall-global.sh" --claude-only
  [ "$status" -eq 0 ]
  [ -L "$skill/reference.md" ]
  [ -p "$skill/events" ]
  [ "$(cat "$HOME_DIR/user.md")" = USER ]
}

@test "旧 manifest 多条历史记录只使用最后一条保护用户手动回退" {
  install_claude
  manifest="$HOME_DIR/.claude/superspecflow/install-manifest.tsv"
  cp "$manifest" "$HOME_DIR/manifest-a"
  cp "$PACK/commands/ssf-review.md" "$HOME_DIR/command-a"
  cp "$PACK/skills/ssf-qa/SKILL.md" "$HOME_DIR/skill-a"
  printf '\nVERSION B\n' >> "$PACK/commands/ssf-review.md"
  printf '\nVERSION B\n' >> "$PACK/skills/ssf-qa/SKILL.md"
  install_claude
  # 模拟旧安装器追加历史的 manifest；当前安装器必须兼容并按最近安装判断。
  cat "$HOME_DIR/manifest-a" "$manifest" > "$HOME_DIR/legacy-manifest"
  cp "$HOME_DIR/legacy-manifest" "$manifest"
  cp "$HOME_DIR/command-a" "$HOME_DIR/.claude/commands/ssf-review.md"
  cp "$HOME_DIR/skill-a" "$HOME_DIR/.claude/skills/ssf-qa/SKILL.md"
  printf '\nVERSION C\n' >> "$PACK/commands/ssf-review.md"
  printf '\nVERSION C\n' >> "$PACK/skills/ssf-qa/SKILL.md"
  install_claude
  cmp "$HOME_DIR/command-a" "$HOME_DIR/.claude/commands/ssf-review.md"
  cmp "$HOME_DIR/skill-a" "$HOME_DIR/.claude/skills/ssf-qa/SKILL.md"
  # 直接卸载旧版追加式清单也必须使用最新记录，不能依赖重装时的去重副作用。
  cp "$HOME_DIR/legacy-manifest" "$manifest"
  run env HOME="$HOME_DIR" bash "$PACK/scripts/uninstall-global.sh" --claude-only
  [ "$status" -eq 0 ]
  cmp "$HOME_DIR/command-a" "$HOME_DIR/.claude/commands/ssf-review.md"
  cmp "$HOME_DIR/skill-a" "$HOME_DIR/.claude/skills/ssf-qa/SKILL.md"
}

@test "重复安装后每个 manifest 路径只保留一条有效记录" {
  install_claude
  install_claude
  manifest="$HOME_DIR/.claude/superspecflow/install-manifest.tsv"
  [ "$(wc -l < "$manifest" | tr -d ' ')" -eq 14 ]
  [ "$(cut -f3 "$manifest" | sort -u | wc -l | tr -d ' ')" -eq 14 ]
}

@test "升级清理未修改的退役命令与 skill 并保留用户改过的退役能力" {
  printf 'bash <pack>/scripts/_ssf_init_apply.sh\n' > "$PACK/commands/ssf-init.md"
  printf 'old command\n' > "$PACK/commands/ssf-retired.md"
  mkdir "$PACK/skills/ssf-retired"
  printf 'old skill\n' > "$PACK/skills/ssf-retired/SKILL.md"
  install_claude
  printf 'USER\n' >> "$HOME_DIR/.claude/commands/ssf-retired.md"
  rm "$PACK/commands/ssf-init.md" "$PACK/commands/ssf-retired.md"
  rm -r "$PACK/skills/ssf-retired"
  install_claude
  [ ! -e "$HOME_DIR/.claude/commands/ssf-init.md" ]
  [ ! -e "$HOME_DIR/.claude/skills/ssf-retired" ]
  grep -Fxq USER "$HOME_DIR/.claude/commands/ssf-retired.md"
  [[ "$output" == *"retired"*"skipped"* ]]
  ! grep -Fq '/commands/ssf-init.md' "$HOME_DIR/.claude/superspecflow/install-manifest.tsv"
}

@test "同名用户退役命令没有安装记录时不会被清理" {
  mkdir -p "$HOME_DIR/.claude/commands"
  printf 'USER\n' > "$HOME_DIR/.claude/commands/ssf-init.md"
  install_claude
  [ "$(cat "$HOME_DIR/.claude/commands/ssf-init.md")" = USER ]
}

@test "用户将命令改为软链后重装不写入软链指向的文件" {
  install_claude
  target="$HOME_DIR/.claude/commands/ssf-review.md"
  mv "$target" "$HOME_DIR/user-command.md"
  ln -s "$HOME_DIR/user-command.md" "$target"
  cp "$HOME_DIR/user-command.md" "$HOME_DIR/before"
  printf '\nNEXT\n' >> "$PACK/commands/ssf-review.md"
  install_claude
  [ -L "$target" ]
  cmp "$HOME_DIR/before" "$HOME_DIR/user-command.md"
}
