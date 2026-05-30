#!/usr/bin/env bats

load '../lib/test_helper'

# SSF-ONBOARD-003: README 命令可发现性 + 重启
@test "README 说明安装后需重启会话且命令进入补全（SSF-ONBOARD-003）" {
  grep -q '重启' "$REPO_ROOT/README.md"
  grep -q '补全' "$REPO_ROOT/README.md"
}

# SSF-ONBOARD-003: installation 项目 opt-in 段说明重启
@test "installation 项目 opt-in 段说明重启会话（SSF-ONBOARD-003）" {
  section="$(awk '/^### 3\.2/{f=1} /^### 3\.3/{f=0} f' "$REPO_ROOT/docs/installation.md")"
  printf '%s\n' "$section" | grep -q '重启'
}

# SSF-ONBOARD-003: 安装后烟测在调用命令前包含重启步骤
@test "installation 安装后烟测包含重启步骤（SSF-ONBOARD-003）" {
  section="$(awk '/^## 8\./{f=1} /^## 9\./{f=0} f' "$REPO_ROOT/docs/installation.md")"
  printf '%s\n' "$section" | grep -q '重启'
}

# SSF-ONBOARD-004: ssf-init 命令文件安装顺序
@test "ssf-init 命令文件呈现 install-global 先于 /ssf-init（SSF-ONBOARD-004）" {
  grep -qi 'restart' "$REPO_ROOT/commands/ssf-init.md"
  ! grep -qF 'prefer `/ssf-init` + `scripts/install-global.sh`' "$REPO_ROOT/commands/ssf-init.md"
}

# SSF-ONBOARD-005: Codex-only 段事实修正
@test "installation Codex-only 段说明 --codex-only 不安装 Claude commands（SSF-ONBOARD-005）" {
  section="$(awk '/^## 6\./{f=1} /^## 7\./{f=0} f' "$REPO_ROOT/docs/installation.md")"
  printf '%s\n' "$section" | grep -q 'Claude commands'
}
