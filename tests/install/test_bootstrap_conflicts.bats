#!/usr/bin/env bats
load '../lib/test_helper'

# 建立离线源仓库和独立检出，安装器仅写测试标记，所有副作用限定在 Bats 临时目录。
setup() {
  SOURCE="$BATS_TEST_TMPDIR/source"
  CHECKOUT="$BATS_TEST_TMPDIR/checkout"
  HOME_DIR="$BATS_TEST_TMPDIR/home"
  mkdir -p "$SOURCE/scripts" "$HOME_DIR"
  git -C "$SOURCE" init -q
  git -C "$SOURCE" checkout -qb fixture
  git -C "$SOURCE" config user.name Fixture
  git -C "$SOURCE" config user.email fixture@example.invalid
  printf '#!/usr/bin/env bash\nprintf installed > "$HOME/installed"\n' > "$SOURCE/scripts/install-global.sh"
  chmod +x "$SOURCE/scripts/install-global.sh"
  printf 'ignored*\n' > "$SOURCE/.gitignore"
  git -C "$SOURCE" add .
  git -C "$SOURCE" commit -qm initial
  git clone -q "$SOURCE" "$CHECKOUT"
  BEFORE="$(git -C "$CHECKOUT" rev-parse HEAD)"
}

# 使用本地源运行公开 bootstrap，记录状态供每个测试断言文件保护和安装是否发生。
bootstrap() {
  run env HOME="$HOME_DIR" SUPERSPECFLOW_HOME="$CHECKOUT" SUPERSPECFLOW_REPO="$SOURCE" \
    SUPERSPECFLOW_BRANCH=fixture bash "$REPO_ROOT/scripts/bootstrap.sh" --yes
}

@test "bootstrap 拒绝远端新增文件覆盖本地未跟踪文件" {
  printf 'LOCAL\n' > "$CHECKOUT/user data.md"
  printf 'REMOTE\n' > "$SOURCE/user data.md"
  git -C "$SOURCE" add .
  git -C "$SOURCE" commit -qm collision
  bootstrap
  [ "$status" -ne 0 ]
  [[ "$output" == *"user data.md"* ]]
  [ "$(cat "$CHECKOUT/user data.md")" = LOCAL ]
  [ "$(git -C "$CHECKOUT" rev-parse HEAD)" = "$BEFORE" ]
  [ ! -e "$HOME_DIR/installed" ]
}

@test "bootstrap 拒绝被忽略文件与远端新增文件冲突" {
  printf 'LOCAL\n' > "$CHECKOUT/ignored.md"
  printf 'REMOTE\n' > "$SOURCE/ignored.md"
  git -C "$SOURCE" add -f ignored.md
  git -C "$SOURCE" commit -qm collision
  bootstrap
  [ "$status" -ne 0 ]
  [ "$(cat "$CHECKOUT/ignored.md")" = LOCAL ]
  [ "$(git -C "$CHECKOUT" rev-parse HEAD)" = "$BEFORE" ]
}

@test "bootstrap 拒绝本地目录被远端文件替换和本地文件阻挡远端目录" {
  mkdir "$CHECKOUT/tree"
  printf 'LOCAL\n' > "$CHECKOUT/tree/data"
  printf 'LOCAL\n' > "$CHECKOUT/parent"
  printf 'REMOTE\n' > "$SOURCE/tree"
  mkdir "$SOURCE/parent"
  printf 'REMOTE\n' > "$SOURCE/parent/child"
  git -C "$SOURCE" add .
  git -C "$SOURCE" commit -qm collision
  bootstrap
  [ "$status" -ne 0 ]
  [ "$(cat "$CHECKOUT/tree/data")" = LOCAL ]
  [ "$(cat "$CHECKOUT/parent")" = LOCAL ]
}

@test "bootstrap 保留不冲突的未跟踪和被忽略文件并完成更新" {
  printf 'LOCAL\n' > "$CHECKOUT/.DS_Store"
  printf 'LOCAL\n' > "$CHECKOUT/ignored.md"
  printf 'REMOTE\n' > "$SOURCE/new.md"
  git -C "$SOURCE" add .
  git -C "$SOURCE" commit -qm update
  bootstrap
  [ "$status" -eq 0 ]
  [ "$(cat "$CHECKOUT/.DS_Store")" = LOCAL ]
  [ "$(cat "$CHECKOUT/ignored.md")" = LOCAL ]
  [ "$(cat "$CHECKOUT/new.md")" = REMOTE ]
  [ -f "$HOME_DIR/installed" ]
}

@test "bootstrap 保护与目标目录冲突的本地嵌套仓库" {
  mkdir "$CHECKOUT/nested" "$SOURCE/nested"
  git -C "$CHECKOUT/nested" init -q
  printf 'LOCAL\n' > "$CHECKOUT/nested/user.md"
  printf 'REMOTE\n' > "$SOURCE/nested/new.md"
  git -C "$SOURCE" add .
  git -C "$SOURCE" commit -qm nested
  bootstrap
  [ "$status" -ne 0 ]
  [[ "$output" == *"nested"* ]]
  [ "$(cat "$CHECKOUT/nested/user.md")" = LOCAL ]
  [ ! -e "$HOME_DIR/installed" ]
}
