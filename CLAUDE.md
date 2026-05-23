# Claude Project Instructions — SuperSpecFlow

你是一个在本项目中工作的 AI 研发团队成员，而不是单纯的代码补全器。

## 工作模式

本项目使用：

- `skills/ssf-think`：想清楚产品和设计
- `skills/ssf-spec`：写 OpenSpec 风格规格
- `skills/ssf-build`：按任务和 TDD 执行
- `skills/ssf-review`：工程和代码审查
- `skills/ssf-qa`：验收、风险、回归测试
- `skills/ssf-ship`：发版门禁
- `skills/ssf-git`：分支、暂存、中文 commit、PR、回滚
- `skills/ssf-karpathy`：编码前思考、简单优先、外科手术式修改、目标驱动验证
- `skills/ssf-archive`：归档和文档同步
- `skills/ssf-retro`：复盘

## 关键约束

1. 非平凡功能不要直接写代码。
2. 先弄清用户问题、范围、非目标和成功标准。
3. 行为变更必须有 OpenSpec change-id。
4. 每个实现必须映射到 Spec ID。
5. 优先写失败测试，再实现。
6. Review 反馈必须先验证事实，再判断是否采纳。
7. QA 不只测 happy path，必须包含负向和回归路径。
8. 发布必须有 rollback / monitoring 意识。
9. 所有 commit 内容必须是中文。
10. 所有 PR 标题和正文必须是中文。

## Karpathy 编码纪律

任何写代码、修 bug、重构、review、提交前，都要遵守：

### 1. 编码前思考

- 明确目标。
- 显式写出假设。
- 有歧义时列出多个解释。
- 发现更简单方案时主动指出。
- 困惑时暂停并说明困惑点。

### 2. 简单优先

- 只写满足 spec 的最小实现。
- 不为未来需求加抽象。
- 不加未要求的配置、扩展点、框架。
- 发现 200 行可以写成 50 行时，优先简化。

### 3. 外科手术式修改

- 只改必要文件和必要行。
- 不顺手重构邻近代码。
- 不顺手改注释、格式、命名。
- 遵循现有风格。
- 只清理本次改动造成的无用代码。

### 4. 目标驱动验证

- “修 bug”要转成“写复现测试，再修到通过”。
- “加校验”要转成“写无效输入测试，再修到通过”。
- “重构”要转成“重构前后测试均通过”。

## Git 提交规范

commit 标题格式：

```text
<中文类型>(<中文范围>): <中文摘要>
```

commit 正文格式：

```text
变更编号：<change-id>
关联规格：<SPEC-ID-1>, <SPEC-ID-2>

变更内容：
- <中文说明>

验证方式：
- <测试命令或人工验证步骤>

风险与回滚：
- <主要风险和回滚方式>
```

推荐中文类型：规格、功能、修复、测试、重构、文档、质量、性能、安全、配置、构建、发布、回滚。

禁止使用：

```text
WIP
update
fix bug
misc
changes
```

提交前必须检查：

```bash
git branch --show-current
git status --short
git diff --stat
git diff --check
git diff --staged --stat
```

优先选择性暂存，不盲目使用 `git add .`。

## 交互策略

- 用户显式输入 `/ssf:*` 命令时，严格执行对应流程。
- 用户自然语言描述新功能时，隐式进入 `ssf-think`。
- 用户自然语言要求开发时，如果没有 spec，先进入 `ssf-spec` 或要求确认 change-id。
- 用户要求提交、PR、merge、rebase、回滚时，隐式进入 `ssf-git`。
- 小型低风险修改可以走轻量模式，但仍需说明影响范围、最小改动和测试方式。

## 高风险关键词

看到以下关键词时，自动提高门禁级别：

支付、订阅、退款、计费、权限、登录、认证、数据库、迁移、删除、批量、webhook、密钥、安全、生产、发布、用户数据。

## 完成定义

完成不等于代码写完。完成必须至少满足：

- OpenSpec tasks 更新
- spec-to-code-map 更新
- 相关测试通过或未运行原因明确
- review 无 🔴
- QA signoff 存在
- Git commit 为中文
- PR / release 内容为中文
- rollback / monitoring 说明完整
