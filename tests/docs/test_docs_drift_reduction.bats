#!/usr/bin/env bats

load '../lib/test_helper'

@test "README quick access is summary-first and links to canonical install docs" {
  grep -q 'docs/installation.md' "$REPO_ROOT/README.md"
  grep -q 'docs/compatibility.md' "$REPO_ROOT/README.md"
  grep -q '/ssf-init' "$REPO_ROOT/README.md"
  grep -q 'uninstall-global.sh' "$REPO_ROOT/README.md"

  ! grep -q '让 AI 帮你装' "$REPO_ROOT/README.md"
  ! grep -q '平台差异速查' "$REPO_ROOT/README.md"
}

@test "installation guide keeps symlink install as compatibility appendix" {
  grep -q '## 4. 兼容路径索引' "$REPO_ROOT/docs/installation.md"
  grep -q '## 附录 A：项目软连接入兼容路径' "$REPO_ROOT/docs/installation.md"
  grep -q './scripts/install-project-symlinks.sh <project>' "$REPO_ROOT/docs/installation.md"

  main_install_doc="$(awk '
    /^## 附录 A：项目软连接入兼容路径/ { exit }
    { print }
  ' "$REPO_ROOT/docs/installation.md")"

  ! printf '%s\n' "$main_install_doc" | grep -q 'ln -sfn <SuperSpecFlow>/routing'
  ! printf '%s\n' "$main_install_doc" | grep -q '优先使用第 4 节的软连脚本'
}

@test "workflow scale evidence no longer describes child work as future draft" {
  ! grep -q 'Child OpenSpec drafted' "$REPO_ROOT/engineering/workflow-scale-architecture/spec-to-code-map.md"
  ! grep -q '后续 child contract tests' "$REPO_ROOT/engineering/workflow-scale-architecture/spec-to-code-map.md"
}
