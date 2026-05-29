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

@test "创建九个标准运行产物子目录" {
  cd "$PROJECT"
  "$APPLY"
  for sub in engineering qa release archive retro decisions maps reviews karpathy; do
    [ -d "$PROJECT/.superspecflow/$sub" ] || { echo "missing $sub"; return 1; }
  done
}

@test "创建 progress/ 占位目录" {
  cd "$PROJECT"
  "$APPLY"
  [ -d "$PROJECT/.superspecflow/progress" ]
}

@test "创建 verification/ 占位目录" {
  cd "$PROJECT"
  "$APPLY"
  [ -d "$PROJECT/.superspecflow/verification" ]
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

@test "init-project-routing spec describes zero-touch sentinel rather than routing symlinks" {
  SPEC="$REPO_ROOT/openspec/changes/init-project-routing/specs/routing.md"
  grep -q '.superspecflow/enabled' "$SPEC"
  ! grep -q '创建 `.superspecflow/AGENTS.routing.md`' "$SPEC"
  ! grep -q '创建项目软链' "$SPEC"
}

@test "init-project-routing spec-to-code map covers all current requirements and MUST NOTs" {
  MAP="$REPO_ROOT/engineering/init-project-routing/spec-to-code-map.md"
  for id in SSF-INIT-001 SSF-INIT-002 SSF-INIT-003 SSF-INIT-004 SSF-INIT-005 SSF-INIT-006 SSF-INIT-007 SSF-INIT-N1 SSF-INIT-N2 SSF-INIT-N3 SSF-INIT-N4 SSF-INIT-N5 SSF-INIT-N6; do
    grep -q "$id" "$MAP" || { echo "missing $id"; return 1; }
  done
}
