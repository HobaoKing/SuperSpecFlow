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

## 提交
- [ ] commit 标题为中文
- [ ] commit 正文为中文
- [ ] 包含 change-id
- [ ] 包含 Spec ID
- [ ] 包含验证方式
- [ ] 包含风险与回滚

## PR
- [ ] PR 标题为中文
- [ ] PR 正文包含变更、测试、风险、回滚、QA
- [ ] Review 无 🔴
- [ ] QA signoff 存在
- [ ] Release gate 通过
