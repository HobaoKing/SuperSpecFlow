#!/usr/bin/env bats

load '../lib/test_helper'

setup() {
  PROJECT="$(ssf_make_tmp_project)"
  APPLY="$REPO_ROOT/scripts/_ssf_init_apply.sh"
}

teardown() {
  ssf_cleanup_tmp "$PROJECT"
}

@test "_ssf_init_apply 在空项目里创建 .superspecflow/enabled" {
  cd "$PROJECT"
  run "$APPLY"
  [ "$status" -eq 0 ]
  [ -f "$PROJECT/.superspecflow/enabled" ]
}

@test "初始化只创建启用标记，不预建阶段产物" {
  cd "$PROJECT"
  run "$APPLY"
  [ "$status" -eq 0 ]
  [ "$(find .superspecflow -mindepth 1 -print)" = ".superspecflow/enabled" ]
  [ ! -e openspec ]
  [ ! -e docs ]
}

@test "不创建任何 routing 软链 / 覆盖文件" {
  cd "$PROJECT"
  "$APPLY"
  [ ! -e "$PROJECT/.superspecflow/CLAUDE.routing.md" ]
  [ ! -e "$PROJECT/.superspecflow/AGENTS.routing.md" ]
  [ ! -e "$PROJECT/.superspecflow/templates" ]
}

@test "不修改宿主 CLAUDE.md / AGENTS.md（即使存在）" {
  cd "$PROJECT"
  printf 'EXISTING-CLAUDE\n' > CLAUDE.md
  printf 'EXISTING-AGENTS\n' > AGENTS.md
  "$APPLY"
  [ "$(cat CLAUDE.md)" = "EXISTING-CLAUDE" ]
  [ "$(cat AGENTS.md)" = "EXISTING-AGENTS" ]
}

@test "幂等：重复执行不报错也不破坏既有子目录内容" {
  cd "$PROJECT"
  "$APPLY"
  mkdir -p "$PROJECT/.superspecflow/decisions"
  echo "user-data" > "$PROJECT/.superspecflow/decisions/keep.md"
  run "$APPLY"
  [ "$status" -eq 0 ]
  [ "$(cat "$PROJECT/.superspecflow/decisions/keep.md")" = "user-data" ]
}

@test "enabled 是目录而非常规文件时报错退出（不静默成功）" {
  cd "$PROJECT"
  mkdir -p "$PROJECT/.superspecflow/enabled"   # 故意制造损坏：enabled 是目录
  run "$APPLY"
  [ "$status" -ne 0 ]
  [[ "$output" == *"not a regular file"* ]] || [[ "$stderr" == *"not a regular file"* ]]
}

@test "指定不存在项目路径时报错且不创建目录" {
  missing="$PROJECT/missing-project"
  run env SSF_INIT_PROJECT_DIR="$missing" "$APPLY"
  [ "$status" -ne 0 ]
  [ ! -e "$missing" ]
  [[ "$output" == *"project directory does not exist"* ]] || [[ "$stderr" == *"project directory does not exist"* ]]
}
