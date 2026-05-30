# Proposal: validator-developer-tooling

## Summary

提升 pack validation 失败可定位性，并增加维护者常用脚本：局部测试筛选和 OpenSpec change 脚手架。

## Problem

`scripts/validate-pack.sh` 多处长 `if/elif` 链在失败时定位成本高。`scripts/test.sh` 只能跑全量测试。创建新 change 需要手工建多个目录和文件。

## Goals

- 将关键长链拆为独立失败项，保留 aggregate failure behavior。
- `scripts/test.sh` 支持文件参数或 `--filter`。
- 新增 `scripts/new-change.sh` 生成 OpenSpec + engineering skeleton。

## Non-goals

- 不并行化 validate-pack。
- 不自动 git add 或 commit。
