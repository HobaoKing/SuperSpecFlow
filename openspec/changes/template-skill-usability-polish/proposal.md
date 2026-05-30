# Proposal: template-skill-usability-polish

## Summary

补强骨架模板和阶段 skills，让 agent 拿到局部文件时也能产出更完整的阶段产物。

## Problem

部分模板只有标题和表头，缺少最小填写提示。`ssf-build` 偏厚并重复 Karpathy/Git 细节，`ssf-retro` 偏薄，`ssf-archive` 缺少自动续接标题。

## Goals

- 给骨架模板加入轻量示例或注释。
- `ssf-build` 保留强规则，减少重复细节并交叉引用 `ssf-karpathy` / `ssf-git`。
- `ssf-retro` 增加探测性问题。
- `ssf-archive` 增加自动续接 heading/rule。

## Non-goals

- 不弱化 TDD、Spec ID、QA、Ship 或 Git gate。
- 不改 slash command 语义。
