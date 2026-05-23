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

@test "创建七个产物子目录" {
  cd "$PROJECT"
  "$APPLY"
  for sub in decisions retro qa reviews karpathy maps ship; do
    [ -d "$PROJECT/.superspecflow/$sub" ] || { echo "missing $sub"; return 1; }
  done
}

@test "创建 progress/ 占位目录" {
  cd "$PROJECT"
  "$APPLY"
  [ -d "$PROJECT/.superspecflow/progress" ]
}

@test "progress/ 内不写任何占位文件" {
  cd "$PROJECT"
  "$APPLY"
  # 期待为空目录；ls -A 应无输出
  [ -z "$(ls -A "$PROJECT/.superspecflow/progress")" ]
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
  echo "user-data" > "$PROJECT/.superspecflow/decisions/keep.md"
  run "$APPLY"
  [ "$status" -eq 0 ]
  [ "$(cat "$PROJECT/.superspecflow/decisions/keep.md")" = "user-data" ]
}
