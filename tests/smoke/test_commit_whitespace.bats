#!/usr/bin/env bats
load '../lib/test_helper'

# 在隔离仓库中提交真实内容，证明检查针对提交而非工作区 diff。
setup() {
  REPOSITORY="$BATS_TEST_TMPDIR/repository"
  mkdir "$REPOSITORY"
  git -C "$REPOSITORY" init -q
  git -C "$REPOSITORY" config user.name Fixture
  git -C "$REPOSITORY" config user.email fixture@example.invalid
  printf 'clean\n' > "$REPOSITORY/file.md"
  git -C "$REPOSITORY" add .
  git -C "$REPOSITORY" commit -qm initial
  BASE="$(git -C "$REPOSITORY" rev-parse HEAD)"
  cd "$REPOSITORY"
}

@test "空白检查捕获已提交的尾随空格且覆盖整个提交范围" {
  printf 'bad   \n' >> file.md
  git add .
  git commit -qm whitespace
  printf 'another file\n' > another.md
  git add .
  git commit -qm next
  [ -z "$(git status --porcelain)" ]
  run bash "$REPO_ROOT/scripts/check-commit-whitespace.sh" "$BASE" HEAD
  [ "$status" -ne 0 ]
  [[ "$output" == *"file.md:2"* ]]
}

@test "空白检查接受干净提交且不依赖工作区修改" {
  printf 'clean addition\n' >> file.md
  git add .
  git commit -qm clean
  printf 'uncommitted   \n' >> file.md
  run bash "$REPO_ROOT/scripts/check-commit-whitespace.sh" "$BASE" HEAD
  [ "$status" -eq 0 ]
}

@test "首次 push 的零 SHA 检查整个树，未知基线不能静默通过" {
  printf 'bad   \n' >> file.md
  git add .
  git commit -qm whitespace
  run bash "$REPO_ROOT/scripts/check-commit-whitespace.sh" 0000000000000000000000000000000000000000 HEAD
  [ "$status" -ne 0 ]
  [[ "$output" == *"file.md:2"* ]]
  run bash "$REPO_ROOT/scripts/check-commit-whitespace.sh" missing-ref HEAD
  [ "$status" -ne 0 ]
}
