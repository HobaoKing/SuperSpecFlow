---
name: ssf-git
description: 按用户请求管理分支、提交、PR 或回滚，保护无关工作并检查实际 staged diff。
---

# ssf-git

只执行当前请求已授权的 Git 操作。代码完成不自动提交；提交授权不自动扩大到 push、PR、合并或发布。

- 操作前查看分支、`git status --short`、`git diff --stat`、`git diff --check` 和 `git diff --staged`。核查暂存区已有改动的归属，不把他人或无关内容混入提交。
- 按明确文件路径暂存，不用 `git add .`、reset、clean 或强推处理脏工作区。普通任务不自动新建 worktree；建分支时采用宿主规范，Codex 默认 `codex/<topic>`。
- 标题使用 `<英文类型>(<英文范围>): <中文摘要>`。正文按需中文说明变更、验证和风险。
- 提交前核查最终 staged diff 和验证结果；完成声明应与证据一致。不得因测试受限伪造通过。
- PR 基于实际 diff 描述问题、行为变化、验证和风险；评审或发布准备不代表远端写入授权。
