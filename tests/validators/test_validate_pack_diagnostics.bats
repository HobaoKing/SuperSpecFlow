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
  [[ "$output" == *"routing/CLAUDE.routing.md drift"* ]] &&
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

@test "包校验拒绝独立 skill 资源缺失、未链接孤儿参考和公共模板漂移" {
  rm "$FIXTURE_REPO/skills/ssf-plan/scripts/new-plan.sh"
  printf '# 孤儿参考\n' > "$FIXTURE_REPO/skills/ssf-build/references/orphan.md"
  printf '\nDRIFT\n' >> "$FIXTURE_REPO/skills/ssf-qa/assets/qa-signoff.md"
  run "$FIXTURE_REPO/scripts/validate-pack.sh"
  [ "$status" -ne 0 ]
  [[ "$output" == *"skills/ssf-plan/scripts/new-plan.sh"* ]] &&
    [[ "$output" == *"unlinked skill resource: skills/ssf-build/references/orphan.md; fix: "* ]] &&
    [[ "$output" == *"skill template drift: skills/ssf-qa/assets/qa-signoff.md"* ]]
}

@test "包校验拒绝超出体积预算的 skill 入口与参考，并给出实际值和修复方式" {
  head -c 5000 /dev/zero | tr '\0' 'x' >> "$FIXTURE_REPO/skills/ssf-think/SKILL.md"
  head -c 9000 /dev/zero | tr '\0' 'y' >> "$FIXTURE_REPO/skills/ssf-build/references/tdd.md"
  run "$FIXTURE_REPO/scripts/validate-pack.sh"
  [ "$status" -ne 0 ]
  [[ "$output" == *"skill entry over budget: skills/ssf-think/SKILL.md is "*" bytes (max 4096); fix: "* ]] &&
    [[ "$output" == *"skill reference over budget: skills/ssf-build/references/tdd.md is "*" bytes (max 8192); fix: "* ]]
}

@test "包校验按字段值统计 description 字节并拒绝超长和入口总量超预算" {
  exact="$(head -c 1024 /dev/zero | tr '\0' 'd')"
  sed -i.bak "s/^description: .*/description: $exact/" "$FIXTURE_REPO/skills/ssf-think/SKILL.md"
  rm "$FIXTURE_REPO/skills/ssf-think/SKILL.md.bak"
  long="$(head -c 1025 /dev/zero | tr '\0' 'd')"
  sed -i.bak "s/^description: .*/description: $long/" "$FIXTURE_REPO/skills/ssf-plan/SKILL.md"
  rm "$FIXTURE_REPO/skills/ssf-plan/SKILL.md.bak"
  for skill in git qa review ship; do
    head -c 2500 /dev/zero | tr '\0' 'z' >> "$FIXTURE_REPO/skills/ssf-$skill/SKILL.md"
  done
  run "$FIXTURE_REPO/scripts/validate-pack.sh"
  [ "$status" -ne 0 ]
  [[ "$output" != *"skills/ssf-think/SKILL.md description is"* ]] &&
    [[ "$output" == *"skill description over budget: skills/ssf-plan/SKILL.md description is 1025 bytes (max 1024)"* ]] &&
    [[ "$output" == *"skill entries total over budget: "*" bytes (max 16384)"* ]]
}

@test "包校验拒绝多行 description 绕过字段预算" {
  local marker
  for marker in '>-' '|-' 'summary'; do
    {
      printf '%s\n' '---' 'name: ssf-think' "description: $marker"
      printf '  '
      head -c 1025 /dev/zero | tr '\0' 'd'
      printf '\n%s\n' '---' '# ssf-think' '[方案判断](references/decision-design.md)'
    } > "$FIXTURE_REPO/skills/ssf-think/SKILL.md"
    run "$FIXTURE_REPO/scripts/validate-pack.sh"
    [ "$status" -ne 0 ]
    [[ "$output" == *"description must be single-line plain text"* ]] || return 1
  done
}

# 仅删除结束分隔符，确认加载结构损坏会被门禁拒绝，而非依赖缺字段或体积超限触发失败。
@test "包校验拒绝缺少结束分隔符的 skill frontmatter" {
  local skill="$FIXTURE_REPO/skills/ssf-think/SKILL.md"
  awk '$0 == "---" && ++separators == 2 { next } { print }' "$skill" > "$skill.tmp"
  mv "$skill.tmp" "$skill"
  run "$FIXTURE_REPO/scripts/validate-pack.sh"
  [ "$status" -ne 0 ]
  [[ "$output" == *"frontmatter"*"fix: "* ]]
}
