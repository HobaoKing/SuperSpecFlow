# Design: validator-developer-tooling

## Architecture Summary

`validate-pack.sh` 保持单脚本入口和 `FAILED` aggregate 模式。新增小 helper 只负责独立 `fail`，不改变检查语义。`scripts/test.sh` 继续用 `find` 列出 Bats 文件，再按参数筛选。`scripts/new-change.sh` 创建 OpenSpec / engineering skeleton，同时追加一条 active ledger row；ledger row 必须包含非 placeholder evidence 与 gaps，让新 change 创建后立即满足 ledger validator。

## Test Runner Semantics

- 无参数：递归运行全部 `tests/**/*.bats`，保持现有排序行为。
- `--list`：只打印将要运行的测试。
- `--filter <pattern>`：固定子串匹配 repo-relative test path。
- 文件参数：必须是存在的 `tests/*.bats` 路径，按调用顺序保留。
- 文件参数和 filter 取并集并去重；filter 命中按发现排序追加。
- 坏路径、非 `.bats` 路径、无匹配均退出 1。

## Bash Compatibility

所有脚本保持 Bash 3.2+：不使用 `mapfile`、`readarray`、关联数组、nameref 或 Bash 4-only expansion。

## Failure Modes

- Filter 无匹配：清晰报错。
- 文件参数不存在或不是 `.bats`：清晰报错。
- New change ID 非 slug：拒绝。
- Change 已存在：拒绝。

## Review Gate

本 child 的实现前必须写入 `engineering/validator-developer-tooling/review-consensus.md`。
