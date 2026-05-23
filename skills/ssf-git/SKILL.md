---
name: ssf-git
description: Git 工作流与中文提交规范。用户输入 /ssf-git、/ssf-branch、/ssf-commit、/ssf-pr，或要求建分支、提交、生成 PR、合并、rebase 时触发。强制分支、暂存、提交、PR 与 OpenSpec change-id/Spec ID 对齐；commit 内容必须使用中文。
---

# ssf-git — Git 工作流与中文提交门禁

## 目标

把“代码改完了”变成可审计、可回滚、可追踪的 Git 记录。

本阶段把 OpenSpec 的 change-id / Spec ID、Superpowers 的小步验证、Karpathy 的 surgical changes，以及 gstack 的发布门禁连接到 Git：

```text
Spec ID → 任务 → 测试 → 最小实现 → 中文 commit → PR → Release Gate
```

## 触发

- 显式：`/ssf-git`、`/ssf-branch <change-id>`、`/ssf-commit <change-id>`、`/ssf-pr <change-id>`
- 隐式：用户说提交、commit、建分支、branch、PR、merge、rebase、cherry-pick、回滚、revert
- 自动：`ssf-build` 完成一个可验证任务后建议提交；`ssf-ship` 前必须检查 Git 状态和 PR 内容

## 核心硬规则

1. **commit 内容必须是中文。**
   - 标题、正文、项目符号、风险说明、验证方式都必须使用中文。
   - 允许出现不可避免的代码标识符、路径、命令、Spec ID、change-id，例如 `AUTH-001`、`src/api/user.ts`、`pnpm test`。
   - 禁止 `WIP`、`update`、`fix bug`、`changes`、`misc` 这类模糊或英文提交信息。
2. **没有 change-id，不提交行为变更。**
3. **没有 Spec ID，不提交行为变更。**
4. **没有验证证据，不提交完成态 commit。**
5. **不得提交无关改动。**
6. **不得把多个无关目标混在一个 commit。**
7. **提交前必须检查 staged diff。**
8. **merge / ship 前必须保证工作区干净，或明确列出未提交内容。**

## 分支命名规范

优先使用：

```text
ssf/<change-id>-<中文或拼音短描述>
```

示例：

```text
ssf/add-membership-renewal-reminder-xufei-tixing
ssf/fix-payment-retry-state-zhifu-chongshi
```

高风险紧急修复：

```text
hotfix/<change-id>-<短描述>
```

规格或流程类变更：

```text
spec/<change-id>-<短描述>
process/<change-id>-<短描述>
```

## Step 1 — Git 状态审计

提交或 PR 前先运行并总结：

```bash
git branch --show-current
git status --short
git diff --stat
git diff --check
```

如果已经暂存，还要运行：

```bash
git diff --staged --stat
git diff --staged --check
```

输出：

```markdown
# Git 状态审计

## 当前分支

## 工作区状态

## 改动统计

## 可能无关改动

## 建议下一步
```

## Step 2 — 分支创建

```bash
git checkout -b ssf/<change-id>-<short-slug>
```

创建分支前检查：

- 当前是否已有未提交改动
- 是否在正确 base 分支
- 是否需要先 pull/rebase
- 当前工作是否属于同一个 change-id

## Step 3 — 暂存策略

默认使用选择性暂存：

```bash
git add <path1> <path2>
git diff --staged --stat
git diff --staged
```

禁止盲目使用：

```bash
git add .
```

除非已经明确确认所有改动都属于同一 change-id，并且没有生成物、缓存、日志、临时文件。

## Step 4 — 中文 commit 格式

提交标题格式：

```text
<中文类型>(<中文范围>): <中文摘要>
```

推荐中文类型：

| 类型 | 用途 |
|---|---|
| 规格 | OpenSpec、需求、验收标准、任务 |
| 功能 | 新功能或新增行为 |
| 修复 | 缺陷修复 |
| 测试 | 单测、集成测试、E2E、负向测试 |
| 重构 | 不改变行为的结构调整 |
| 文档 | README、说明、runbook、用户文档 |
| 质量 | 代码质量、边界处理、可维护性 |
| 性能 | 性能优化 |
| 安全 | 权限、认证、密钥、注入、防护 |
| 配置 | 配置、环境、工具链 |
| 构建 | 构建脚本、依赖、CI |
| 发布 | release notes、回滚、监控 |
| 回滚 | revert / rollback |

提交正文格式：

```text
<中文类型>(<中文范围>): <中文摘要>

变更编号：<change-id>
关联规格：<SPEC-ID-1>, <SPEC-ID-2>

变更内容：
- <中文说明 1>
- <中文说明 2>

验证方式：
- <命令或人工验证步骤>
- <测试结果>

风险与回滚：
- <主要风险>
- <回滚方式>
```

示例：

```text
功能(会员): 增加续费提醒入口

变更编号：add-membership-renewal-reminder
关联规格：MEMBERSHIP-001, MEMBERSHIP-002

变更内容：
- 在会员中心增加续费提醒入口。
- 增加到期前提醒状态的展示逻辑。

验证方式：
- 已运行 pnpm test membership。
- 已通过续费提醒入口的 E2E 验证。

风险与回滚：
- 主要风险是提醒状态展示不一致。
- 可通过移除入口组件并回滚该提交恢复。
```

## Step 5 — 提交前检查清单

```markdown
# Commit Gate: [change-id]

- [ ] 当前分支符合命名规范
- [ ] staged diff 只包含本次任务相关文件
- [ ] 每个行为变更都有 Spec ID
- [ ] 每个 Spec ID 有测试或明确人工验证
- [ ] 已运行相关测试或说明无法运行原因
- [ ] commit 标题为中文
- [ ] commit 正文为中文
- [ ] commit 正文包含 change-id、Spec ID、验证方式、风险与回滚
- [ ] 没有 secret、日志、缓存、临时文件、无关格式化
```

## Step 6 — 提交命令

优先使用文件方式，避免多行消息转义错误：

```bash
cat > /tmp/ssf-commit-msg.txt <<'COMMIT'
功能(会员): 增加续费提醒入口

变更编号：add-membership-renewal-reminder
关联规格：MEMBERSHIP-001

变更内容：
- 在会员中心增加续费提醒入口。

验证方式：
- 已运行 pnpm test membership。

风险与回滚：
- 可回滚该提交移除入口。
COMMIT

git commit -F /tmp/ssf-commit-msg.txt
```

## Step 7 — PR 工作流

PR 标题必须中文：

```text
功能(会员): 增加续费提醒入口
```

PR 正文：

```markdown
# PR：<中文标题>

## 变更编号

## 关联规格

## 变更摘要

## 用户影响

## 主要改动

## 验证方式

## 风险

## 回滚方案

## QA 结果

## 截图 / 录屏

## 发布备注
```

PR 前必须检查：

```bash
git status --short
git log --oneline --decorate -n 5
git diff --stat origin/main...HEAD
```

如果目标分支不是 `main`，将 `origin/main` 替换为实际 base。

## Step 8 — 合并 / 回滚

合并前：

- `ssf-review` 无 🔴
- `ssf-qa` 推荐 Ship 或 Ship with monitoring
- `ssf-ship` 无阻塞
- PR commits 均为中文提交

回滚提交也必须中文：

```text
回滚(会员): 回滚续费提醒入口

变更编号：add-membership-renewal-reminder
关联规格：MEMBERSHIP-001

回滚原因：
- 上线后发现提醒状态在部分用户下展示不一致。

回滚方式：
- 回滚提交 <commit-sha>。

验证方式：
- 已确认会员中心入口恢复到发布前状态。
```

## 暂停条件

以下情况暂停并报告，不要提交：

- staged diff 包含无关文件
- commit message 无法满足中文规范
- 找不到 change-id 或 Spec ID
- 测试失败且用户没有明确要求保存失败状态
- 发现 secret、生产配置、隐私数据
- 当前分支和目标变更不匹配
