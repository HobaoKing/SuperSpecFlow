# 分支策略（Git Flow）

本项目采用 **Git Flow** 工作流。所有协作者在开始任务前，请先阅读本文档。

## 分支总览

| 分支             | 类型     | 来源       | 合并去向            | 说明                                   |
| ---------------- | -------- | ---------- | ------------------- | -------------------------------------- |
| `master`         | 长期分支 | —          | —                   | 生产环境代码，始终可发布。仅接受合并。 |
| `develop`        | 长期分支 | `master`   | —                   | 集成分支，下一个版本的最新开发状态。   |
| `feature/<name>` | 短期分支 | `develop`  | `develop`           | 单个功能开发。                         |
| `release/<x.y.z>`| 短期分支 | `develop`  | `master` + `develop`| 发布准备，仅做 bug 修复与版本号调整。  |
| `hotfix/<x.y.z>` | 短期分支 | `master`   | `master` + `develop`| 紧急修复生产 bug。                     |

## 命名规范

- `feature/<issue-id>-<short-desc>`，例如 `feature/123-user-auth`
- `release/<x.y.z>`，例如 `release/1.2.0`
- `hotfix/<x.y.z>`，例如 `hotfix/1.2.1`
- 分支名一律小写，单词以 `-` 连接。

## 标准流程

### 1. 开发新功能

```bash
git checkout develop
git pull origin develop
git checkout -b feature/123-user-auth

# ... 开发、提交 ...

git push -u origin feature/123-user-auth
# 在 GitHub 上发起 PR：feature/123-user-auth → develop
```

合并要求：

- 至少 1 位 reviewer 通过；
- CI 全部通过；
- 优先使用 **Squash merge**，保持 develop 历史整洁。

### 2. 发布版本

```bash
git checkout develop
git pull origin develop
git checkout -b release/1.2.0

# 调整版本号、生成 CHANGELOG、修复回归 bug
git push -u origin release/1.2.0
```

发布完成后：

```bash
# 合并到 master 并打 tag
git checkout master
git merge --no-ff release/1.2.0
git tag -a v1.2.0 -m "Release 1.2.0"
git push origin master --tags

# 同步回 develop
git checkout develop
git merge --no-ff release/1.2.0
git push origin develop

# 删除 release 分支
git branch -d release/1.2.0
git push origin --delete release/1.2.0
```

### 3. 紧急修复

```bash
git checkout master
git pull origin master
git checkout -b hotfix/1.2.1

# 修复并提交
git push -u origin hotfix/1.2.1
```

完成后同样合并到 `master`（打 tag）与 `develop`。

## 提交信息规范

使用 [Conventional Commits](https://www.conventionalcommits.org/zh-hans/v1.0.0/)：

```
<type>(<scope>): <subject>

<body>

<footer>
```

常用 `type`：

- `feat` 新功能
- `fix` 修复 bug
- `docs` 文档变更
- `style` 代码格式（不影响逻辑）
- `refactor` 重构
- `perf` 性能优化
- `test` 测试
- `chore` 构建过程或辅助工具变更

示例：

```
feat(auth): 支持 GitHub OAuth 登录

新增 GitHub OAuth provider，并在登录页增加入口按钮。

Closes #123
```

## 保护规则建议

在 GitHub 仓库设置中建议开启：

- `master`：禁止直接 push，必须通过 PR；要求 CI 通过；要求至少 1 位 reviewer 通过；
- `develop`：禁止直接 push，必须通过 PR；要求 CI 通过。

## 速查图

```
master   ──●─────────●──────────●─── (生产, tag)
            \       / \        /
release      \     /   \      /
              \   /     \    /
develop  ──●───●───●─────●──●─── (集成)
            \     /       \
feature      ●───●         ●─── (开发)
```
