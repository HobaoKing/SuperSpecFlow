#!/usr/bin/env bats
load '../lib/test_helper'

@test "PR 空白检查以共同祖先为基线且不会漏掉 PR 自己引入的错误" {
  repository="$BATS_TEST_TMPDIR/pr-repository"
  mkdir "$repository"
  git -C "$repository" init -q
  git -C "$repository" config user.name Fixture
  git -C "$repository" config user.email fixture@example.invalid
  cd "$repository"
  printf 'inherited   \n' > inherited.md
  git add .
  git commit -qm common
  common="$(git rev-parse HEAD)"
  git checkout -qb feature
  printf 'feature\n' > feature.md
  git add .
  git commit -qm feature
  git checkout -qb target "$common"
  printf 'inherited\n' > inherited.md
  git add .
  git commit -qm target-fix
  # 目标分支已经修正的历史空白不属于 PR 变更，不能从两端树的差异反向归责给 PR。
  run bash "$REPO_ROOT/scripts/check-commit-whitespace.sh" target feature --merge-base
  [ "$status" -eq 0 ]
  git checkout -q feature
  printf 'bad   \n' >> feature.md
  git add .
  git commit -qm bad-feature
  run bash "$REPO_ROOT/scripts/check-commit-whitespace.sh" target feature --merge-base
  [ "$status" -ne 0 ]
  [[ "$output" == *"feature.md:2"* ]]
  [[ "$output" != *"inherited.md"* ]]
}
