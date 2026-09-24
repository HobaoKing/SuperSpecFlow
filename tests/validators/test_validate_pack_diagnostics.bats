#!/usr/bin/env bats
load '../lib/test_helper'

setup() {
  FIXTURE_REPO="$(ssf_make_tmp_repo_fixture)"
}
teardown() {
  ssf_cleanup_tmp "$FIXTURE_REPO"
}

@test "包校验汇总入口漂移和缺失参考错误" {
  printf '\nDRIFT\n' >> "$FIXTURE_REPO/routing/CLAUDE.routing.md"
  rm "$FIXTURE_REPO/skills/ssf-build/references/tdd.md"
  run "$FIXTURE_REPO/scripts/validate-pack.sh"
  [ "$status" -ne 0 ]
  [[ "$output" == *"routing/CLAUDE.routing.md drift"* ]]
  [[ "$output" == *"references/tdd.md"* ]]
}

@test "包校验拒绝命令引用不存在的 skill" {
  printf '使用 `ssf-missing` skill。\n' > "$FIXTURE_REPO/commands/ssf-build.md"
  run "$FIXTURE_REPO/scripts/validate-pack.sh"
  [ "$status" -ne 0 ]
  [[ "$output" == *"skills/ssf-missing/SKILL.md"* ]]
}

@test "包校验不依赖历史 OpenSpec 目录或台账" {
  [ ! -e "$FIXTURE_REPO/openspec" ]
  [ ! -e "$FIXTURE_REPO/engineering" ]
  run "$FIXTURE_REPO/scripts/validate-pack.sh"
  [ "$status" -eq 0 ]
}

@test "包校验拒绝跟踪运行时文件" {
  mkdir -p "$FIXTURE_REPO/.superspecflow"
  printf 'runtime\n' > "$FIXTURE_REPO/.superspecflow/keep"
  git -C "$FIXTURE_REPO" add -f .superspecflow/keep
  run "$FIXTURE_REPO/scripts/validate-pack.sh"
  [ "$status" -ne 0 ]
  [[ "$output" == *"tracked runtime artifacts"* ]]
}

@test "包校验拒绝路由声明的命令缺失" {
  for command in think plan build review qa git ship; do
    mv "$FIXTURE_REPO/commands/ssf-$command.md" "$FIXTURE_REPO/command-backup"
    run "$FIXTURE_REPO/scripts/validate-pack.sh"
    [ "$status" -ne 0 ]
    [[ "$output" == *"missing or empty: commands/ssf-$command.md"* ]]
    mv "$FIXTURE_REPO/command-backup" "$FIXTURE_REPO/commands/ssf-$command.md"
  done
}

@test "包校验要求每个 global wrapper 模板带有该宿主的 routing 占位符" {
  for host in CLAUDE AGENTS GEMINI; do
    printf '# 无占位符模板\n' > "$FIXTURE_REPO/routing/$host.global.md"
    run "$FIXTURE_REPO/scripts/validate-pack.sh"
    [ "$status" -ne 0 ]
    [[ "$output" == *"routing/$host.global.md missing routing placeholder"* ]]
    git -C "$FIXTURE_REPO" checkout -- "routing/$host.global.md"
  done
}

@test "包校验要求 AGENTS.md 与 CLAUDE.md 正文一致（仅 include 行可不同）" {
  printf '只有 Claude 才看得到的一行\n' >> "$FIXTURE_REPO/CLAUDE.md"
  run "$FIXTURE_REPO/scripts/validate-pack.sh"
  [ "$status" -ne 0 ]
  [[ "$output" == *"root instruction bodies drift"* ]]
}
