# Proposal: test-infra-portability-hardening

## Summary

修复测试 helper 在自定义 `TMPDIR` 下的假红，并把会写真实仓库 runtime 目录的 Bats 用例隔离到临时仓库副本。

## Problem

`ssf_make_tmp_home()` 和 `ssf_make_tmp_project()` 按 `TMPDIR` 创建目录，但 `ssf_cleanup_tmp()` 只允许硬编码路径，导致自定义 `TMPDIR` 下大量测试在 teardown 阶段失败。部分测试还直接在真实 `$REPO_ROOT` 创建 `qa/`、`progress/`、`verification/` 和 `.superspecflow/` fixture。

## Goals

- 让 helper cleanup 安全跟随 normalized `TMPDIR`。
- 保持只删除 helper-created `ssf-home.*` 和 `ssf-proj.*` 目录。
- 将 root-mutating tests 移到临时 repo copy。
- CI 覆盖非默认 `TMPDIR`。

## Non-goals

- 不改变 production install/runtime 行为。
- 不放宽 runtime artifact validation。

## Success Metrics

- `TMPDIR=/tmp/claude-501 bash scripts/test.sh` 通过。
- 相关测试不会在真实仓库留下 root runtime artifacts。
- CI 明确运行 non-default `TMPDIR` 验证。
