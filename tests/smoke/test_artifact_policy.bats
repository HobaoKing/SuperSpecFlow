#!/usr/bin/env bats

load '../lib/test_helper'

@test "Git tracked files exclude runtime and install artifacts" {
  run git -C "$REPO_ROOT" ls-files
  [ "$status" -eq 0 ]

  if printf '%s\n' "$output" | grep -Eq '^(superpowers|docs/superpowers|\.superspecflow|\.claude|\.codex)/|(^|/)\.DS_Store$'; then
    printf '%s\n' "$output" | grep -E '^(superpowers|docs/superpowers|\.superspecflow|\.claude|\.codex)/|(^|/)\.DS_Store$' >&2
    return 1
  fi
}

@test "可复用技能和路由不携带源码仓库的提交忽略策略" {
  run grep -REn 'docs/superpowers|本仓库不提交|运行时产物|gitignore' \
    "$REPO_ROOT/skills" "$REPO_ROOT/commands" "$REPO_ROOT/routing"
  [ "$status" -eq 1 ]
}

@test "分发的提交 hook 不限制宿主可跟踪的目录" {
  project="$(ssf_make_tmp_project)"
  git -C "$project" init -q
  # 隔离机器上的全局忽略规则，验证宿主自行决定跟踪目录时 hook 的行为。
  git -C "$project" config core.excludesFile /dev/null
  mkdir -p "$project/.claude"
  printf 'project config\n' > "$project/.claude/project.md"
  git -C "$project" add .claude/project.md
  printf 'chore(meta): 添加项目配置\n' > "$project/msg.txt"
  cd "$project"
  run bash "$REPO_ROOT/templates/git-hooks/commit-msg" msg.txt
  [ "$status" -eq 0 ]
  ssf_cleanup_tmp "$project"
}
