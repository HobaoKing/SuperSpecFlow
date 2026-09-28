#!/usr/bin/env bats
load '../lib/test_helper'

# 将 skills 安装到隔离 HOME，宿主故意不接入全局 wrapper，验证单独调用所需资源。
setup() {
  HOME_DIR="$BATS_TEST_TMPDIR/home"
  PROJECT="$BATS_TEST_TMPDIR/host project"
  mkdir -p "$HOME_DIR/.codex" "$PROJECT"
  printf 'Host rules\n' > "$HOME_DIR/.codex/AGENTS.md"
  env HOME="$HOME_DIR" bash "$REPO_ROOT/scripts/install-global.sh" --codex-only --yes >/dev/null
}

@test "安装后的 plan skill 不依赖包目录即可生成计划并保护已有文件" {
  skill="$HOME_DIR/.codex/skills/ssf-plan"
  [ -f "$skill/assets/implementation-plan.md" ]
  run bash "$skill/scripts/new-plan.sh" independent-plan "$PROJECT"
  [ "$status" -eq 0 ]
  grep -Fq 'independent-plan' "$PROJECT/docs/plans/independent-plan.md"
  printf 'USER\n' >> "$PROJECT/docs/plans/independent-plan.md"
  run bash "$skill/scripts/new-plan.sh" independent-plan "$PROJECT"
  [ "$status" -ne 0 ]
  grep -Fxq USER "$PROJECT/docs/plans/independent-plan.md"
  [ "$(cat "$HOME_DIR/.codex/AGENTS.md")" = 'Host rules' ]
}

@test "QA 和发布模板随独立 skill 安装且本地引用均可解析" {
  [ -s "$HOME_DIR/.codex/skills/ssf-qa/assets/qa-signoff.md" ]
  [ -s "$HOME_DIR/.codex/skills/ssf-ship/assets/release-checklist.md" ]
  for name in plan qa ship; do
    skill="$HOME_DIR/.codex/skills/ssf-$name"
    while IFS= read -r ref; do
      [ -s "$skill/$ref" ]
    done < <(grep -Eo '\]\((assets|scripts|references)/[^)]+\)' "$skill/SKILL.md" | sed 's/^](//; s/)$//')
  done
}

@test "公共计划入口和 skill 自带入口输出相同骨架" {
  skill="$HOME_DIR/.codex/skills/ssf-plan"
  mkdir "$PROJECT/other"
  run bash "$REPO_ROOT/scripts/new-plan.sh" same-plan "$PROJECT"
  [ "$status" -eq 0 ]
  run bash "$skill/scripts/new-plan.sh" same-plan "$PROJECT/other"
  [ "$status" -eq 0 ]
  cmp "$PROJECT/docs/plans/same-plan.md" "$PROJECT/other/docs/plans/same-plan.md"
}
