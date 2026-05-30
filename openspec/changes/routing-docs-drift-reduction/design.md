# Design: routing-docs-drift-reduction

## Architecture Summary

Routing 仍暴露两个 regular public files。使用 canonical source + sync/check script，或等价 materialized-file validation，确保两个 public files 由同一内容维护。Raw symlink 不是可接受方案。

## Documentation Shape

README 保留 quickstart、`/ssf-init`、卸载摘要和 docs 链接。`docs/installation.md` 成为 canonical installation reference，legacy symlink 内容移动到 appendix 或压缩为兼容路径说明。

## Status Refresh

`engineering/workflow-scale-architecture/spec-to-code-map.md` 将 child 状态从 “drafted/future tests” 更新为 implemented/covered by child contract tests。

## Review Gate

本 child 的实现前必须写入 `engineering/routing-docs-drift-reduction/review-consensus.md`。
