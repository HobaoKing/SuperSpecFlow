#!/usr/bin/env bats
load '../lib/test_helper'

setup() {
  PROJECT="$(ssf_make_tmp_project)"
}
teardown() {
  ssf_cleanup_tmp "$PROJECT"
}

@test "计划生成器在当前项目仅创建一份计划" {
  cd "$PROJECT"
  run "$REPO_ROOT/scripts/new-plan.sh" sample-change
  [ "$status" -eq 0 ]
  [ -f docs/plans/sample-change.md ]
  [ "$(find . -type f | wc -l | tr -d ' ')" = 1 ]
  [ ! -e openspec ]
  [ ! -e engineering ]
  [ ! -e .superspecflow ]
}

@test "指定含空格的目标目录且保留已有合同" {
  mkdir -p "$PROJECT/host project/openspec"
  printf 'history\n' > "$PROJECT/host project/openspec/keep.md"
  run "$REPO_ROOT/scripts/new-plan.sh" sample-change "$PROJECT/host project"
  [ "$status" -eq 0 ]
  [ -f "$PROJECT/host project/docs/plans/sample-change.md" ]
  [ "$(cat "$PROJECT/host project/openspec/keep.md")" = history ]
}

@test "计划生成器拒绝目录穿越和非法主题" {
  for topic in '../x' 'foo/bar' '.hidden' 'Foo' 'foo_bar' '-leading' 'trailing-' 'bad--dash'; do
    run "$REPO_ROOT/scripts/new-plan.sh" "$topic" "$PROJECT"
    [ "$status" -ne 0 ]
  done
  [ ! -e "$PROJECT/docs" ]
}

@test "计划生成器参数数量非法时报错退出并提示用法" {
  run "$REPO_ROOT/scripts/new-plan.sh"
  [ "$status" -eq 2 ]
  [[ "$output" == *"用法："* ]]

  run "$REPO_ROOT/scripts/new-plan.sh" a b c
  [ "$status" -eq 2 ]
  [[ "$output" == *"用法："* ]]
}

@test "重复创建不能覆盖计划" {
  "$REPO_ROOT/scripts/new-plan.sh" sample-change "$PROJECT"
  printf 'user work\n' >> "$PROJECT/docs/plans/sample-change.md"
  before="$(cat "$PROJECT/docs/plans/sample-change.md")"
  run "$REPO_ROOT/scripts/new-plan.sh" sample-change "$PROJECT"
  [ "$status" -ne 0 ]
  [ "$(cat "$PROJECT/docs/plans/sample-change.md")" = "$before" ]
}

@test "拒绝不存在的目标以及已有悬空符号链接" {
  run "$REPO_ROOT/scripts/new-plan.sh" sample-change "$PROJECT/missing"
  [ "$status" -ne 0 ]
  [ ! -e "$PROJECT/missing" ]
  mkdir -p "$PROJECT/docs/plans"
  ln -s "$PROJECT/missing.md" "$PROJECT/docs/plans/sample-change.md"
  run "$REPO_ROOT/scripts/new-plan.sh" sample-change "$PROJECT"
  [ "$status" -ne 0 ]
  [ ! -e "$PROJECT/missing.md" ]
}
