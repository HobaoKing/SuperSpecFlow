#!/usr/bin/env bats

load '../lib/test_helper'

setup() {
  PROJECT_DIR="$(ssf_make_tmp_project)"
  APPLY="$REPO_ROOT/scripts/_ssf_init_apply.sh"
}

teardown() {
  ssf_cleanup_tmp "$PROJECT_DIR"
}

@test "opt-in 输出提示已生效且需新会话启用 Intake Gate（SSF-ONBOARD-002）" {
  run env SSF_INIT_PROJECT_DIR="$PROJECT_DIR" bash "$APPLY"
  [ "$status" -eq 0 ]
  [ -f "$PROJECT_DIR/.superspecflow/enabled" ]
  [[ "$output" == *"已生效"* ]]
  [[ "$output" == *"会话"* ]]
  [[ "$output" == *"Intake Gate"* ]]
}

@test "opt-in 输出不把手动 include 与 slash 命令注册混同（SSF-ONBOARD-002-N1）" {
  run env SSF_INIT_PROJECT_DIR="$PROJECT_DIR" bash "$APPLY"
  [ "$status" -eq 0 ]
  [[ "$output" != *"不加也不影响"* ]]
}

@test "opt-in 输出不把全局安装当作运行本脚本的鸡生蛋前置（SSF-ONBOARD-002）" {
  run env SSF_INIT_PROJECT_DIR="$PROJECT_DIR" bash "$APPLY"
  [ "$status" -eq 0 ]
  [[ "$output" != *"仅在尚未做过全局安装时"* ]]
}
