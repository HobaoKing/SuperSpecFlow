# SuperSpecFlow Agent Routing

本项目使用一套 AI 软件研发流程：

- **OpenSpec 风格**：把需求沉淀为可追踪的 change contract。
- **Superpowers 风格**：执行时先理解、再计划、再测试、再实现、再验证。
- **gstack 风格**：通过产品、设计、工程、QA、安全、发布角色做门禁审查。
- **Karpathy 风格**：编码前暴露假设，简单优先，外科手术式修改，目标驱动验证。
- **GitOps 风格**：分支、暂存、中文 commit、PR、回滚与 change-id / Spec ID 对齐。

## 0. 全局原则

不要把用户的一句话功能请求直接当成写代码许可。

也不要把所有自然语言都直接升级成完整流程。任何自然语言请求进入隐式路由前，必须先做 Intake Gate。

### 0.1 Intake Gate

先判断用户请求属于哪一类，再选择流程：

| 类别 | 判定标准 | 处理方式 |
|---|---|---|
| 纯问答 / 解释 | 不要求修改文件、提交、发布或生成正式规格 | 直接回答，不启动完整 SuperSpecFlow |
| 轻量任务 | 拼写、格式、链接、低风险文档补充、只读检查、一次性命令 | 使用轻量模式：说明目标、影响范围、验证方式，不强制 Think → Retro 全链路 |
| 非平凡行为变更 | 新功能、用户路径变化、业务规则变化、API/数据/权限/状态变化 | 进入 `ssf-think` 或 `ssf-spec`，必须形成 change-id / Spec ID |
| 已有规格的实现 | 用户提供 change-id / Spec ID，且要求实现、测试或修复 | 进入 `ssf-build`，按 OpenSpec tasks 执行 |
| Review / QA / Ship / Git | 用户要求审查、验收、发布、提交、PR、回滚 | 进入对应 `ssf-review`、`ssf-qa`、`ssf-ship`、`ssf-git` |
| 高风险变更 | 支付、权限、认证、用户数据、数据库、迁移、删除、安全、生产发布 | 强制完整 Spec、QA、Ship、Git/PR 门禁 |

Intake Gate 必须检查：

1. 用户是否真的要求改变行为。
2. 是否已有 change-id / Spec ID。
3. 风险是否足以强制完整流程。
4. 是否可以用更小的轻量流程完成。
5. 是否存在歧义；若有，先问一个关键问题。

除非用户明确要求“快速改一个小问题”，且 Intake Gate 判断为轻量任务，否则所有非平凡变更应经过：

```text
Think → Spec → Build → Review → QA → Ship → Git/PR → Archive → Retro
```

任何代码编辑都必须遵守：

1. 编码前说明目标、假设、歧义和更简单方案。
2. 优先最小实现，不写投机式抽象。
3. 只改必须改的文件和行，不做无关重构。
4. 把任务转换为可验证目标。
5. 每个行为变更映射到 Spec ID。
6. 提交和 PR 使用中文内容。

## 1. 隐式路由规则

### 1.1 Product / Think

当用户说以下内容时，自动进入 `ssf-think` 或调用 `product-strategist`：

- 我想做一个……
- 帮我设计一个……
- 这个功能怎么做……
- MVP 怎么切……
- 用户流程怎么设计……
- 产品方向、需求、用户体验、商业价值、功能边界

输出：

- Product Change Brief
- 用户路径
- Non-goals
- Success Metrics
- Product Decision Record
- OpenSpec proposal 输入

### 1.2 Spec

当用户说以下内容时，自动进入 `ssf-spec` 或调用 `spec-architect`：

- 帮我写规格
- 生成 OpenSpec
- 写 acceptance criteria
- 拆 tasks
- 把需求整理成开发文档
- formalize requirements

输出：

- `openspec/changes/<change-id>/proposal.md`
- `openspec/changes/<change-id>/design.md`，必要时
- `openspec/changes/<change-id>/tasks.md`
- `openspec/changes/<change-id>/specs/*.md`
- Spec Readiness Review

### 1.3 Build / Engineering

当用户说以下内容时，自动进入 `ssf-build` 或调用 `implementation-engineer`：

- 实现这个
- 开始写代码
- 修 bug
- 加 API
- 重构
- 根据 spec 开发
- 补测试

强制规则：

1. 先读取 OpenSpec change。
2. 先运行 Karpathy 编码前判断：目标、假设、歧义、简单方案。
3. 先生成 implementation plan。
4. 维护 spec-to-code-map。
5. 优先 TDD。
6. 不实现 OpenSpec 之外的功能。
7. 每完成一个 task 更新 tasks.md。
8. 每个可验证任务完成后，建议进入 `ssf-git` 准备中文提交。

### 1.4 Karpathy / Diff Discipline

当用户说以下内容时，自动进入 `ssf-karpathy`：

- 检查是否过度设计
- 这个实现是不是太复杂
- 只做最小改动
- 不要乱改
- 检查 diff
- surgical change
- 目标驱动验证

输出：

- 编码前判断
- 简化检查
- Surgical Changes 检查
- Karpathy Diff Audit
- 可验证目标列表

### 1.5 Review

当用户说以下内容时，自动进入 `ssf-review` 或调用 `code-reviewer`：

- review 一下
- 检查代码
- 帮我看有没有问题
- 评审 PR
- 工程审查

输出：

- 🔴 必须修
- 🟡 建议改
- 🟢 记录即可
- spec 同步检查
- 测试缺口
- Karpathy Diff Audit

### 1.6 QA

当用户说以下内容时，自动进入 `ssf-qa` 或调用 `qa-gatekeeper`：

- 测试一下
- 做 QA
- 验收
- 生成测试用例
- 检查能不能发
- e2e
- regression

输出：

- acceptance-matrix.md
- negative-test-matrix.md
- risk-matrix.md
- regression-checklist.md
- exploratory-test-notes.md
- qa-signoff.md

### 1.7 Ship / Release

当用户说以下内容时，自动进入 `ssf-ship` 或调用 `release-manager`：

- ship
- deploy
- release
- merge
- 准备发布
- 能不能上线
- release notes

输出：

- release checklist
- rollback plan
- monitoring plan
- PR description
- ship / no-ship recommendation

### 1.8 Git / Commit / PR

当用户说以下内容时，自动进入 `ssf-git` 或调用 `git-steward`：

- 提交
- commit
- 建分支
- branch
- 生成 PR
- pull request
- merge
- rebase
- cherry-pick
- revert
- rollback
- 帮我写 commit message

强制规则：

1. commit 标题和正文必须是中文。
2. 允许保留必要代码标识符、文件路径、命令、Spec ID、change-id。
3. 不允许 `WIP`、`update`、`fix bug`、`misc` 等模糊英文提交。
4. 提交前必须检查 `git status --short`、`git diff --stat`、`git diff --check`、`git diff --staged`。
5. 不盲目 `git add .`，优先选择性暂存。
6. 无 change-id / Spec ID 的行为变更不提交。
7. 无验证证据不提交完成态 commit。

## 2. 显式命令优先级

如果用户显式输入以下命令，直接执行对应流程，不再重新判断：

```text
/ssf-think <idea>
/ssf-spec <change-id>
/ssf-build [all|N]
/ssf-review
/ssf-qa <change-id>
/ssf-ship <change-id>
/ssf-archive <change-id>
/ssf-retro <change-id>
/ssf-decision <topic>
/ssf-map <change-id>
/ssf-karpathy <target>
/ssf-git
/ssf-branch <change-id> <topic>
/ssf-commit <change-id>
/ssf-pr <change-id>
```

## 3. 高风险变更强制门禁

以下类型不能跳过 Spec、QA、Ship、Git/PR：

- 支付、订阅、计费、退款
- 登录、权限、认证、用户数据
- 数据库迁移、数据删除、批量任务
- 安全、密钥、外部 webhook
- AI 自动执行真实世界动作
- 会影响生产稳定性的基础设施变更

必须额外产出：

- risk-matrix.md
- migration-plan.md，若涉及数据结构
- rollback-plan.md
- monitoring-plan.md
- negative tests
- 中文 commit 与中文 PR

## 4. Spec-to-Code Rule

任何行为变更都必须映射到 Spec ID。

如果无法映射：

1. 先更新 OpenSpec；或
2. 不做该变更。

## 5. Test Rule

- 每个 requirement 至少一个测试。
- 每个 MUST NOT 至少一个负向测试。
- 每个 P0 risk 必须自动化测试或明确人工 gate。

## 6. Git Rule

提交格式：

```text
<中文类型>(<中文范围>): <中文摘要>

变更编号：<change-id>
关联规格：<SPEC-ID-1>, <SPEC-ID-2>

变更内容：
- <中文说明>

验证方式：
- <测试或人工验证>

风险与回滚：
- <风险和回滚方式>
```

推荐中文类型：规格、功能、修复、测试、重构、文档、质量、性能、安全、配置、构建、发布、回滚。

## 7. Completion Criteria

一个功能只有满足以下条件才算完成：

- OpenSpec tasks 全部完成或明确跳过
- spec-to-code-map 已更新
- tests 通过或未运行原因明确
- Karpathy Diff Audit 无严重问题
- review 无 🔴
- QA signoff 存在
- release blockers 已解决或显式豁免
- Git 分支清晰，commit 内容为中文
- PR 描述为中文，包含测试、风险、回滚、QA
- archive / decision ledger 已更新
