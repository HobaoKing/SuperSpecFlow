# Proposal: routing-docs-drift-reduction

## Summary

降低 routing public 文件、README 安装说明、installation 兼容路径和 workflow-scale evidence 的漂移风险。

## Problem

`routing/AGENTS.routing.md` 与 `routing/CLAUDE.routing.md` 内容完全重复但需要保持两个 public path。README 安装/卸载段与 `docs/installation.md` 大量重复。`workflow-scale-architecture` 的 spec-to-code map 仍描述 child work 为后续草稿。

## Goals

- 防止 routing 两份 public 文件静默漂移，且不依赖 raw symlink。
- README 保留快速路径和链接，详细说明集中到 docs。
- 将 legacy project symlink path 压缩或移到附录。
- 刷新 workflow-scale evidence wording。

## Non-goals

- 不移除 `routing/AGENTS.routing.md` 或 `routing/CLAUDE.routing.md` public paths。
- 不改变 zero-touch global wrapper 语义。
