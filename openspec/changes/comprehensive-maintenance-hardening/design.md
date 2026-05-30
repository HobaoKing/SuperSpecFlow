# Design: comprehensive-maintenance-hardening

## Architecture Summary

本 change 是 parent program，不直接承载所有实现细节。四个 child changes 分别拥有自己的 spec、tasks、测试和 spec-to-code map。Parent 只定义顺序、三方 review gate、跨 child 风险和 completion audit。

## Scope Split Rationale

三方 reviewer 对原始单 change 方案给出不同结论：一个允许单 change 但要求批次化，两个要求拆分或 parent cluster。采用更严格交集：创建 parent change，并用四个 child changes 隔离写入范围。

## Child Boundaries

- `test-infra-portability-hardening`: 测试 helper、root-mutating Bats、CI `TMPDIR` 验证。
- `routing-docs-drift-reduction`: routing canonicalization、README / installation 精简、workflow-scale evidence 刷新。
- `validator-developer-tooling`: `validate-pack.sh` 诊断、`scripts/test.sh` 筛选、`scripts/new-change.sh`。
- `template-skill-usability-polish`: 骨架模板提示、`ssf-build` / `ssf-retro` / `ssf-archive` 可用性。

## Review Gate

每个 child change 在编辑前必须同时 dispatch 3 个子 agent review。主 agent 汇总三方结论，只采纳无实质冲突的交集；若存在冲突，先调整设计或测试策略，再进入文件修改。

Review evidence 写入 `engineering/<change-id>/review-consensus.md`，包含：

- Reviewers
- Proposed patch scope
- Consensus
- Required tests
- Rejected options

## Data Flow

OpenSpec specs 定义要求，implementation batches 写入对应文件和 tests。`scripts/validate-pack.sh`、Bats、CI 和 shellcheck 是最终证据来源。

## Failure Modes

- 单个 child 引入 unrelated diff：暂停并拆分。
- Reviewer 未达成一致：不编辑文件，先缩小方案。
- 验证只覆盖局部：不得声明 parent complete。
- 非默认 `TMPDIR` 下失败：test infra child 未完成。

## Migration Plan

不迁移用户 runtime 产物。Routing public file strategy 保持安装和 include 入口兼容。

## Rollback Plan

每个 child 可通过 revert 对应文件恢复。Parent 没有 runtime migration；失败时保留原有重复 routing、README 文案和脚本行为。
