# Git Checklist: [change-id]

## 分支
- [ ] 分支名符合 `ssf/<change-id>-<short-slug>`
- [ ] base 分支正确
- [ ] 当前工作区没有无关改动

## 暂存
- [ ] 已检查 `git status --short`
- [ ] 已检查 `git diff --stat`
- [ ] 已检查 `git diff --check`
- [ ] staged diff 只包含本次变更
- [ ] staged diff 不包含 `superpowers/`、`docs/superpowers/`、`.superspecflow/`、`.claude/`、`.codex/`、`.DS_Store` 等运行时、安装或缓存产物

## 提交
- [ ] commit 标题符合 `<英文类型>(<英文范围>): <中文摘要>` 规范
- [ ] commit 标题的类型在允许列表中（feat/fix/docs/style/refactor/perf/test/build/ci/chore/revert/spec）
- [ ] commit 标题的范围符合 `<根模块>` 或 `<根模块>:<业务子模块>` 形式
- [ ] commit 摘要为中文
- [ ] commit 正文为中文
- [ ] 包含 change-id
- [ ] 包含 Spec ID
- [ ] 包含验证方式
- [ ] 包含风险与回滚

## PR
- [ ] PR 标题符合 commit 标题规范（英文类型 + 英文范围 + 中文摘要）
- [ ] PR 正文包含变更、测试、风险、回滚、QA
- [ ] Review 无 🔴
- [ ] QA signoff 存在
- [ ] Release gate 通过
