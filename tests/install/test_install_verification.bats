#!/usr/bin/env bats
load '../lib/test_helper'

# 每个用例使用隔离源码包与 HOME，故障注入只替换该次安装的系统命令。
setup() {
  PACK="$(ssf_make_tmp_repo_fixture)"
  HOME_DIR="$BATS_TEST_TMPDIR/home"
  BIN="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$HOME_DIR" "$BIN"
  export REAL_CP="$(command -v cp)" REAL_MV="$(command -v mv)" REAL_RM="$(command -v rm)"
}

# 只回收本用例创建的源码副本，其余临时文件由 Bats 回收。
teardown() {
  ssf_cleanup_tmp "$PACK"
}

# 先安装一个后续版本将退役的能力，以确认故障时不会提前清理旧安装。
prepare_upgrade() {
  mkdir "$PACK/skills/ssf-retired"
  printf 'previous capability\n' > "$PACK/skills/ssf-retired/SKILL.md"
  env HOME="$HOME_DIR" bash "$PACK/scripts/install-global.sh" --codex-only --yes
  cp "$HOME_DIR/.codex/skills/ssf-build/SKILL.md" "$HOME_DIR/before"
  rm -r "$PACK/skills/ssf-retired"
  printf '\nNEXT\n' >> "$PACK/skills/ssf-build/SKILL.md"
}

@test "全部宿主安装完成自动读回且资源和脚本保持可用" {
  run env HOME="$HOME_DIR" bash "$PACK/scripts/install-global.sh" --all --yes
  [ "$status" -eq 0 ]
  [[ "$output" == *"Installation verified"* ]]
  for root in .codex/skills .claude/skills .gemini/config/skills .gemini/antigravity-cli/skills; do
    cmp "$PACK/skills/ssf-plan/assets/implementation-plan.md" "$HOME_DIR/$root/ssf-plan/assets/implementation-plan.md"
    [ -x "$HOME_DIR/$root/ssf-plan/scripts/new-plan.sh" ]
  done
}

@test "复制命令误报成功但内容损坏时保留旧版且不清理退役能力" {
  prepare_upgrade
  cat > "$BIN/cp" <<'SH'
#!/usr/bin/env bash
"$REAL_CP" "$@" || exit
if [[ "$2" == */skills/ssf-build && "$3" == */content ]]; then
  printf 'CORRUPT\n' >> "$3/SKILL.md"
fi
SH
  chmod +x "$BIN/cp"
  run env HOME="$HOME_DIR" PATH="$BIN:$PATH" bash "$PACK/scripts/install-global.sh" --codex-only --yes
  [ "$status" -ne 0 ]
  [[ "$output" == *"staged content mismatch"* ]]
  cmp "$HOME_DIR/before" "$HOME_DIR/.codex/skills/ssf-build/SKILL.md"
  [ -f "$HOME_DIR/.codex/skills/ssf-retired/SKILL.md" ]
  [ -z "$(find "$HOME_DIR" -name '.ssf-install.*' -print)" ]
}

@test "安装末尾检测到能力被改动时返回失败且不清理退役能力" {
  prepare_upgrade
  cat > "$BIN/mv" <<'SH'
#!/usr/bin/env bash
"$REAL_MV" "$@" || exit
if [[ "$2" == */superspecflow/AGENTS.global.md ]]; then
  printf 'CHANGED\n' >> "$HOME/.codex/skills/ssf-build/SKILL.md"
fi
SH
  chmod +x "$BIN/mv"
  run env HOME="$HOME_DIR" PATH="$BIN:$PATH" bash "$PACK/scripts/install-global.sh" --codex-only --yes
  [ "$status" -ne 0 ]
  [[ "$output" == *"verification failed; retired cleanup not run"* ]]
  [ -f "$HOME_DIR/.codex/skills/ssf-retired/SKILL.md" ]
  grep -Fq '/skills/ssf-retired' "$HOME_DIR/.codex/superspecflow/install-manifest.tsv"
}

@test "目标替换失败时恢复旧版且不遗留本次暂存目录" {
  prepare_upgrade
  cat > "$BIN/mv" <<'SH'
#!/usr/bin/env bash
if [[ "$1" == */content && "$2" == */skills/ssf-build ]]; then exit 1; fi
exec "$REAL_MV" "$@"
SH
  chmod +x "$BIN/mv"
  run env HOME="$HOME_DIR" PATH="$BIN:$PATH" bash "$PACK/scripts/install-global.sh" --codex-only --yes
  [ "$status" -ne 0 ]
  cmp "$HOME_DIR/before" "$HOME_DIR/.codex/skills/ssf-build/SKILL.md"
  [ -f "$HOME_DIR/.codex/skills/ssf-retired/SKILL.md" ]
  [ -z "$(find "$HOME_DIR" -name '.ssf-install.*' -print)" ]
}

@test "用户改动保留时报告部分安装不冒充全部更新" {
  prepare_upgrade
  printf 'USER\n' >> "$HOME_DIR/.codex/skills/ssf-build/SKILL.md"
  run env HOME="$HOME_DIR" bash "$PACK/scripts/install-global.sh" --codex-only --yes
  [ "$status" -eq 0 ]
  [[ "$output" == *"partial installation: 1 protected targets retained"* ]]
  [[ "$output" != *"Done. Installation verified."* ]]
  grep -Fxq USER "$HOME_DIR/.codex/skills/ssf-build/SKILL.md"
}

@test "安装验证通过后才删除退役项且不越过所选宿主" {
  prepare_upgrade
  mkdir -p "$HOME_DIR/.claude/skills/ssf-retired" "$HOME_DIR/.codex/skills/ssf-unknown"
  printf 'OTHER HOST\n' > "$HOME_DIR/.claude/skills/ssf-retired/SKILL.md"
  printf 'UNKNOWN\n' > "$HOME_DIR/.codex/skills/ssf-unknown/SKILL.md"
  run env HOME="$HOME_DIR" bash "$PACK/scripts/install-global.sh" --codex-only --yes
  [ "$status" -eq 0 ]
  [[ "$output" == *"readback passed"*"removed retired capability"* ]]
  [ ! -e "$HOME_DIR/.codex/skills/ssf-retired" ]
  [ -f "$HOME_DIR/.claude/skills/ssf-retired/SKILL.md" ]
  [ -f "$HOME_DIR/.codex/skills/ssf-unknown/SKILL.md" ]
  ! grep -Fq '/skills/ssf-retired' "$HOME_DIR/.codex/superspecflow/install-manifest.tsv"
}

@test "清理命令误报成功但退役项仍存在时保留清单并失败" {
  prepare_upgrade
  cat > "$BIN/rm" <<'SH'
#!/usr/bin/env bash
if [[ "$2" == */skills/ssf-retired ]]; then exit 0; fi
exec "$REAL_RM" "$@"
SH
  chmod +x "$BIN/rm"
  run env HOME="$HOME_DIR" PATH="$BIN:$PATH" bash "$PACK/scripts/install-global.sh" --codex-only --yes
  [ "$status" -ne 0 ]
  [[ "$output" == *"retired target remains"* ]]
  [ -f "$HOME_DIR/.codex/skills/ssf-retired/SKILL.md" ]
  grep -Fq '/skills/ssf-retired' "$HOME_DIR/.codex/superspecflow/install-manifest.tsv"
}

@test "wrapper 软链保留且不会覆盖其指向的用户文件" {
  prepare_upgrade
  wrapper="$HOME_DIR/.codex/superspecflow/AGENTS.global.md"
  mv "$wrapper" "$HOME_DIR/user-rules.md"
  cp "$HOME_DIR/user-rules.md" "$HOME_DIR/rules-before"
  ln -s "$HOME_DIR/user-rules.md" "$wrapper"
  run env HOME="$HOME_DIR" bash "$PACK/scripts/install-global.sh" --codex-only --yes
  [ "$status" -ne 0 ]
  [ -L "$wrapper" ]
  cmp "$HOME_DIR/rules-before" "$HOME_DIR/user-rules.md"
  [ -f "$HOME_DIR/.codex/skills/ssf-retired/SKILL.md" ]
}

@test "暂存 executable 位丢失时保留旧版可执行脚本" {
  prepare_upgrade
  cat > "$BIN/cp" <<'SH'
#!/usr/bin/env bash
"$REAL_CP" "$@" || exit
if [[ "$2" == */skills/ssf-plan && "$3" == */content ]]; then
  chmod -x "$3/scripts/new-plan.sh"
fi
SH
  chmod +x "$BIN/cp"
  run env HOME="$HOME_DIR" PATH="$BIN:$PATH" bash "$PACK/scripts/install-global.sh" --codex-only --yes
  [ "$status" -ne 0 ]
  [[ "$output" == *"executable missing"* ]]
  [ -x "$HOME_DIR/.codex/skills/ssf-plan/scripts/new-plan.sh" ]
  [ -f "$HOME_DIR/.codex/skills/ssf-retired/SKILL.md" ]
}
