#!/usr/bin/env bats
# 安装/卸载脚本健壮性回归测试。
# 覆盖 include 精确匹配、wrapper 渲染转义、目标文件权限与软链保护、
# skills 目录非目录项、--purge 防护与 bootstrap 脏工作区保护。

load '../lib/test_helper'

setup() {
  HOME_DIR="$(ssf_make_tmp_home)"
  INSTALL="$REPO_ROOT/scripts/install-global.sh"
  UNINSTALL="$REPO_ROOT/scripts/uninstall-global.sh"
  BOOTSTRAP="$REPO_ROOT/scripts/bootstrap.sh"
  export HOME="$HOME_DIR"
  rm -rf "$HOME_DIR/.claude" "$HOME_DIR/.codex" "$HOME_DIR/.gemini"
  # 记录本次创建的路径，teardown 手工清理（路径含特殊字符时不能走 ssf_cleanup_tmp）
  HARDENING_DIRS=()
}

teardown() {
  local dir
  for dir in ${HARDENING_DIRS[@]+"${HARDENING_DIRS[@]}"}; do
    rm -rf "$dir"
  done
  ssf_cleanup_tmp "$HOME_DIR"
}

# 生成一个位于含特殊字符路径下的包副本，用于验证渲染与参数处理。
make_pack_at_special_path() {
  local marker="$1"
  local base fixture target
  base="$(mktemp -d "$(ssf__tmpdir)/ssf-hard.XXXXXX")"
  fixture="$(ssf_make_tmp_repo_fixture)"
  target="$base/${marker}/pack"
  mkdir -p "$target"
  cp -R "$fixture/." "$target/"
  rm -rf "$fixture"
  HARDENING_DIRS+=("$base")
  printf '%s' "$target"
}

# —— A5：include 判定必须整行精确匹配，注释行不算已接入 ——

@test "include 行被注释时不算已接入，--append 会写入真实 include 行" {
  mkdir -p "$HOME/.claude"
  inc="@$HOME/.claude/superspecflow/CLAUDE.global.md"
  printf '# %s\n' "$inc" > "$HOME/.claude/CLAUDE.md"

  run "$INSTALL" --claude-only --yes --no-hook --append
  [ "$status" -eq 0 ]
  grep -Fxq "$inc" "$HOME/.claude/CLAUDE.md"
  grep -Fxq "# $inc" "$HOME/.claude/CLAUDE.md"
}

@test "include 行带尾随空白不算已接入" {
  mkdir -p "$HOME/.claude"
  inc="@$HOME/.claude/superspecflow/CLAUDE.global.md"
  printf '%s   \n' "$inc" > "$HOME/.claude/CLAUDE.md"

  run "$INSTALL" --claude-only --yes --no-hook --append
  [ "$status" -eq 0 ]
  # 尾随空白导致该行失效，必须补一行精确 include
  [ "$(grep -Fcx "$inc" "$HOME/.claude/CLAUDE.md")" -eq 1 ]
}

@test "精确 include 行存在时幂等跳过，不重复追加" {
  mkdir -p "$HOME/.claude"
  inc="@$HOME/.claude/superspecflow/CLAUDE.global.md"
  printf '%s\n' "$inc" > "$HOME/.claude/CLAUDE.md"

  run "$INSTALL" --claude-only --yes --no-hook
  [ "$status" -eq 0 ]
  [ "$(grep -Fcx "$inc" "$HOME/.claude/CLAUDE.md")" -eq 1 ]
}

# —— A4：特殊包路径下 wrapper 渲染必须成功且自包含 ——

@test "包路径含 & 时安装成功且 wrapper 内联规则全文" {
  pack="$(make_pack_at_special_path 'a&b')"
  run bash "$pack/scripts/install-global.sh" --antigravity-only --yes --no-hook
  [ "$status" -eq 0 ]

  wrapper="$HOME/.gemini/superspecflow/GEMINI.global.md"
  [ -f "$wrapper" ]
  grep -q 'SuperSpecFlow 轻量规则' "$wrapper"
  ! grep -q '<repo>' "$wrapper"
  ! grep -q '<pack>' "$wrapper"
  # & 在正则/g Sub 替换串里会被展开，内联渲染用 index 定位不受影响
  grep -Fq "$pack/scripts/new-plan.sh" "$wrapper"
}

@test "包路径含 # 时安装不中断且 wrapper 内联规则全文" {
  pack="$(make_pack_at_special_path 'a#b')"
  run bash "$pack/scripts/install-global.sh" --antigravity-only --yes --no-hook
  [ "$status" -eq 0 ]

  wrapper="$HOME/.gemini/superspecflow/GEMINI.global.md"
  [ -f "$wrapper" ]
  grep -q 'SuperSpecFlow 轻量规则' "$wrapper"
  ! grep -q '<repo>' "$wrapper"
  ! grep -q '<pack>' "$wrapper"
  grep -Fq "$pack/scripts/new-plan.sh" "$wrapper"
}

# —— A6：追加与移除 include 必须保留权限，且不把软链替换成普通文件 ——

@test "--append 后目标指令文件权限保持不变" {
  mkdir -p "$HOME/.claude"
  printf 'USER\n' > "$HOME/.claude/CLAUDE.md"
  chmod 644 "$HOME/.claude/CLAUDE.md"

  run "$INSTALL" --claude-only --yes --no-hook --append
  [ "$status" -eq 0 ]
  [ "$(ssf_file_mode "$HOME/.claude/CLAUDE.md")" = "644" ]
}

@test "卸载移除 include 后目标指令文件权限保持不变" {
  mkdir -p "$HOME/.claude"
  printf 'USER\n' > "$HOME/.claude/CLAUDE.md"
  chmod 640 "$HOME/.claude/CLAUDE.md"
  run "$INSTALL" --claude-only --yes --no-hook --append
  [ "$status" -eq 0 ]

  run "$UNINSTALL" --claude-only
  [ "$status" -eq 0 ]
  [ "$(ssf_file_mode "$HOME/.claude/CLAUDE.md")" = "640" ]
  [ "$(cat "$HOME/.claude/CLAUDE.md")" = "USER" ]
}

@test "软链目标删空 include 后不删除用户真实文件，只提示" {
  mkdir -p "$HOME/.claude" "$HOME/dotfiles"
  printf '%s\n' "@$HOME/.claude/superspecflow/CLAUDE.global.md" > "$HOME/dotfiles/CLAUDE.md"
  ln -s "$HOME/dotfiles/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
  # 先手工制造“只含 include 行”的真实文件，直接走卸载路径
  run "$INSTALL" --claude-only --yes --no-hook --append
  [ "$status" -eq 0 ]
  run "$UNINSTALL" --claude-only
  [ "$status" -eq 0 ]
  [ -e "$HOME/dotfiles/CLAUDE.md" ]
  [ -L "$HOME/.claude/CLAUDE.md" ]
  [[ "$output" == *"已为空"* ]]
}

@test "软链目标仍有其他内容时卸载后真实文件与软链都在且权限不变" {
  mkdir -p "$HOME/.claude" "$HOME/dotfiles"
  printf 'USER\n' > "$HOME/dotfiles/CLAUDE.md"
  chmod 644 "$HOME/dotfiles/CLAUDE.md"
  ln -s "$HOME/dotfiles/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

  run "$INSTALL" --claude-only --yes --no-hook --append
  [ "$status" -eq 0 ]
  run "$UNINSTALL" --claude-only
  [ "$status" -eq 0 ]
  [ -L "$HOME/.claude/CLAUDE.md" ]
  [ "$(cat "$HOME/dotfiles/CLAUDE.md")" = "USER" ]
  [ "$(ssf_file_mode "$HOME/dotfiles/CLAUDE.md")" = "644" ]
}

@test "目标是指令文件是软链时把 include 写入其指向的真实文件并保留软链" {
  mkdir -p "$HOME/.claude" "$HOME/real"
  printf 'USER\n' > "$HOME/real/CLAUDE.md"
  ln -s "$HOME/real/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
  inc="@$HOME/.claude/superspecflow/CLAUDE.global.md"

  run "$INSTALL" --claude-only --yes --no-hook --append
  [ "$status" -eq 0 ]
  [ -L "$HOME/.claude/CLAUDE.md" ]
  [ "$(head -n 1 "$HOME/real/CLAUDE.md")" = "$inc" ]
  grep -Fxq "USER" "$HOME/real/CLAUDE.md"
}

# —— C2：skills 目录混入非目录文件不应中断安装 ——

@test "skills 目录下混入非目录文件时安装仍可完成" {
  pack="$(make_pack_at_special_path 'stray')"
  printf 'not a skill\n' > "$pack/skills/ssf-stray"

  run bash "$pack/scripts/install-global.sh" --codex-only --yes --no-hook
  [ "$status" -eq 0 ]
  [ -f "$HOME/.codex/skills/ssf-qa/SKILL.md" ]
  [ ! -e "$HOME/.codex/skills/ssf-stray/SKILL.md" ]
}

# —— C3：--purge 必须基于物理路径判断，且删除真实目录 ——

@test "--purge 在 pack 目录内执行被拒绝（含经软链进入）" {
  pack="$(make_pack_at_special_path 'purge-in')"
  link_base="$(mktemp -d "$(ssf__tmpdir)/ssf-purge.XXXXXX")"
  HARDENING_DIRS+=("$link_base")
  ln -s "$pack" "$link_base/packlink"

  run bash -c "cd '$link_base/packlink' && bash '$pack/scripts/uninstall-global.sh' --all --purge"
  [ "$status" -ne 0 ]
  [ -d "$pack" ]
}

@test "--purge 经软链路径调用时删除真实 pack 目录而非只删软链" {
  pack="$(make_pack_at_special_path 'purge-link')"
  link_base="$(mktemp -d "$(ssf__tmpdir)/ssf-purge2.XXXXXX")"
  HARDENING_DIRS+=("$link_base")
  ln -s "$pack" "$link_base/packlink"

  run bash "$link_base/packlink/scripts/uninstall-global.sh" --all --purge
  [ "$status" -eq 0 ]
  [ ! -d "$pack" ]
  [ -L "$link_base/packlink" ]
}

# —— A2：bootstrap 遇到脏工作区必须中止，绝不静默 reset --hard ——

@test "bootstrap 在已跟踪文件有未提交改动时中止且不触动工作区" {
  install_dir="$(mktemp -d "$(ssf__tmpdir)/ssf-bs.XXXXXX")"
  HARDENING_DIRS+=("$install_dir")
  git -C "$install_dir" init -q
  # origin 必须与脚本期望一致，才能走到脏工作区检查；检查在 fetch 之前，因此不触网
  git -C "$install_dir" remote add origin "https://github.com/HobaoKing/SuperSpecFlow.git"
  printf 'local edit\n' > "$install_dir/VERSION"
  git -C "$install_dir" add -A >/dev/null
  git -C "$install_dir" -c user.email=t@t -c user.name=t commit -qm init

  printf 'MODIFIED\n' > "$install_dir/VERSION"

  run env HOME="$HOME_DIR" SUPERSPECFLOW_HOME="$install_dir" bash "$BOOTSTRAP"
  [ "$status" -ne 0 ]
  [ "$(cat "$install_dir/VERSION")" = "MODIFIED" ]
  [[ "$output" == *"未提交改动"* ]]
}

@test "bootstrap 不因未跟踪文件（如 .DS_Store）中止更新" {
  install_dir="$(mktemp -d "$(ssf__tmpdir)/ssf-bs.XXXXXX")"
  HARDENING_DIRS+=("$install_dir")
  git -C "$install_dir" init -q
  # origin 指向不可达地址，使脚本在脏工作区检查之后止步于 remote 校验：
  # 若未跟踪文件被判脏，这里会输出“已中止更新”而不是 remote 不匹配。
  git -C "$install_dir" remote add origin "https://invalid.invalid/SuperSpecFlow.git"
  printf 'v0\n' > "$install_dir/VERSION"
  printf 'finder\n' > "$install_dir/.DS_Store"
  git -C "$install_dir" add -A >/dev/null
  git -C "$install_dir" -c user.email=t@t -c user.name=t commit -qm init
  rm "$install_dir/VERSION"      # 变为已删除（跟踪项改动），下面只留未跟踪文件
  git -C "$install_dir" checkout -- VERSION
  printf 'finder again\n' > "$install_dir/.DS_Store"

  run env HOME="$HOME_DIR" SUPERSPECFLOW_HOME="$install_dir" bash "$BOOTSTRAP"
  [ "$status" -ne 0 ]
  [[ "$output" != *"已中止更新"* ]]
  [ -f "$install_dir/.DS_Store" ]
}

# —— C5/A1：bootstrap 的源与环境变量可注入，主路径可离线 e2e ——

@test "bootstrap --help 打印用法且不安装" {
  run env HOME="$HOME_DIR" bash "$BOOTSTRAP" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"SUPERSPECFLOW_BRANCH"* ]]
  [ ! -e "$HOME_DIR/.superspecflow" ]
}

@test "bootstrap 用本地 bare 仓库做 remote 可完整走完 clone 与安装" {
  # 用本地 bare 仓库 mock origin，使主路径（clone → exec install-global.sh）可离线验证
  bare="$(mktemp -d "$(ssf__tmpdir)/ssf-bare.XXXXXX")"
  HARDENING_DIRS+=("$bare")
  git clone -q --bare "$REPO_ROOT" "$bare/repo.git"
  git -C "$bare/repo.git" update-ref refs/heads/mocked HEAD

  install_dir="$(mktemp -d "$(ssf__tmpdir)/ssf-inst.XXXXXX")"
  rmdir "$install_dir"   # bootstrap 需要目标不存在以走 clone 分支

  run env HOME="$HOME_DIR" \
    SUPERSPECFLOW_HOME="$install_dir" \
    SUPERSPECFLOW_REPO="$bare/repo.git" \
    SUPERSPECFLOW_BRANCH=mocked \
    bash "$BOOTSTRAP" --codex-only --yes --no-hook
  [ "$status" -eq 0 ]
  [ -f "$install_dir/scripts/install-global.sh" ]
  [ -f "$HOME/.codex/skills/ssf-qa/SKILL.md" ]
}

@test "bootstrap 对已有检出走 update：fetch + checkout + reset，参数透传" {
  bare="$(mktemp -d "$(ssf__tmpdir)/ssf-bare2.XXXXXX")"
  HARDENING_DIRS+=("$bare")
  git clone -q --bare "$REPO_ROOT" "$bare/repo.git"
  git -C "$bare/repo.git" update-ref refs/heads/mocked HEAD

  install_dir="$(mktemp -d "$(ssf__tmpdir)/ssf-inst2.XXXXXX")"
  rm -rf "$install_dir"
  git clone -q --branch mocked "$bare/repo.git" "$install_dir"
  git -C "$install_dir" remote set-url origin "$bare/repo.git"

  run env HOME="$HOME_DIR" \
    SUPERSPECFLOW_HOME="$install_dir" \
    SUPERSPECFLOW_REPO="$bare/repo.git" \
    SUPERSPECFLOW_BRANCH=mocked \
    bash "$BOOTSTRAP" --claude-only --yes --no-hook
  [ "$status" -eq 0 ]
  [ -f "$HOME/.claude/skills/ssf-qa/SKILL.md" ]
  [ ! -e "$HOME/.codex" ]
  [ -n "$(git -C "$install_dir" rev-parse HEAD)" ]
}
