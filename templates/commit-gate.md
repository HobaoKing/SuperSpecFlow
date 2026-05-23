# Commit Gate: [change-id]

- [ ] 当前分支符合命名规范
- [ ] staged diff 只包含本次任务相关文件
- [ ] 每个行为变更都有 Spec ID
- [ ] 每个 Spec ID 有测试或明确人工验证
- [ ] 已运行相关测试或说明无法运行原因
- [ ] commit 标题符合 `<英文类型>(<英文范围>): <中文摘要>` 规范
- [ ] commit 标题的类型在允许列表中，范围符合 `<根模块>` 或 `<根模块>:<业务子模块>` 形式
- [ ] commit 摘要为中文
- [ ] commit 正文为中文
- [ ] commit 正文包含 change-id、Spec ID、验证方式、风险与回滚
- [ ] 没有 `superpowers/`、`.superspecflow/`、`.claude/`、`.codex/`、`.DS_Store` 等运行时、安装或缓存产物
- [ ] 没有 secret、日志、缓存、临时文件、无关格式化
