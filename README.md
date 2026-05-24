# SuperSpecFlow

SuperSpecFlow 是一套面向 Claude Code / Codex CLI 的 AI 软件研发工作流，把 `想 → 规 → 建 → 审 → 测 → 发 → 档 → 复盘` 做成可以隐式和显式调用的研发体系。

新版重点补强：

- **OpenSpec 风格的 SpecOps**：需求、变更、验收、归档可追踪。
- **Superpowers 风格的 AgentOps**：先理解、再计划、TDD、小步实现、处理 review 先验证。
- **gstack 风格的 ReviewOps**：产品、设计、工程、QA、安全、发布多角色门禁。
- **Karpathy 风格的 DiffOps**：编码前显式假设、简单优先、外科手术式修改、目标驱动验证。
- **GitOps**：分支、暂存、commit（英文类型 + 中文正文）、PR、merge、rollback 与 change-id / Spec ID 对齐。

目标不是让 AI 更会“写代码”，而是让 AI 像小型研发组织一样工作，并且每个决策、实现、测试、提交都能追踪。

## 仓库提交边界

SuperSpecFlow 仓库提交工作流包源码和 OpenSpec 变更契约：`routing/`、`skills/`、`commands/`、`agents/`、`templates/`、`scripts/`、用户文档和 `openspec/`。其中 `openspec/` 是本仓库行为规则变更的 change contract，不能被当作运行时产物忽略。

不要提交本地 workflow 运行时、安装副本或缓存产物，例如 `superpowers/`、`.superspecflow/`、`.claude/`、`.codex/` 和 `.DS_Store`。宿主业务项目如果采用 OpenSpec 管理需求，其项目内 `openspec/` 应正常提交；`.superspecflow/` 是否提交由宿主项目接入策略决定。

## 接入

推荐方案：方案 C 零侵入接入，宿主项目 `CLAUDE.md` / `AGENTS.md` 零改动。

```bash
# 一次性全局安装
./scripts/install-global.sh

# 进入要 opt-in 的项目，执行
/ssf-init
```

详见 [docs/installation.md §3](docs/installation.md)。

兼容方案：[docs/installation.md §4](docs/installation.md)（项目软连接入，老用户路径）。

可选：安装 commit message hook（校验 `<英文类型>(<英文范围>): <中文摘要>` 标题与中文正文底线）：

```bash
cp templates/git-hooks/commit-msg .git/hooks/commit-msg
chmod +x .git/hooks/commit-msg
```

## 使用方式

### 隐式调用

你可以直接说：

```text
我要做一个会员续费提醒功能
```

系统应自动进入产品思考阶段：

```text
ssf-think → ssf-spec → ssf-build → ssf-review → ssf-qa → ssf-ship → ssf-archive → ssf-retro
```

如果你说：

```text
帮我提交这次改动
```

系统应自动进入 `ssf-git`，检查分支、diff、Spec ID、测试证据，并生成符合规范的 commit（英文类型 + 英文范围 + 中文摘要，中文正文）。

### 显式调用

```text
/ssf-think 会员续费提醒
/ssf-spec add-membership-renewal-reminder
/ssf-build all
/ssf-review
/ssf-qa add-membership-renewal-reminder
/ssf-ship add-membership-renewal-reminder
/ssf-archive add-membership-renewal-reminder
/ssf-retro add-membership-renewal-reminder
/ssf-decision 会员续费提醒入口放置位置
/ssf-map add-membership-renewal-reminder
/ssf-init
```

`/ssf-init` 是项目初始化动作，用于创建 `.superspecflow/` 软链并提示加入 `@./.superspecflow/*.routing.md`。其他 `/ssf-*` 命令只执行对应的一次性流程，不会自动启用项目级自然语言路由。

Git 和 Karpathy 相关命令：

```text
/ssf-karpathy 检查当前实现是否过度设计
/ssf-git
/ssf-branch add-membership-renewal-reminder 会员续费提醒
/ssf-commit add-membership-renewal-reminder
/ssf-pr add-membership-renewal-reminder
```

## 核心原则

1. 非平凡功能先想清楚，不直接写代码。
2. 行为变更必须有 OpenSpec change-id。
3. 没有 Spec ID 的行为变更不实现。
4. 每条 requirement 至少映射一个测试。
5. 每条 MUST NOT 至少映射一个负向测试。
6. 高风险变更必须走 QA gate 和 release gate。
7. 写代码前要显式说明假设、歧义和更简单方案。
8. 修改必须外科手术式，只改必要内容，不做顺手重构。
9. 每个可发布变更必须有 Git 分支、符合规范的 commit（英文类型 + 英文范围 + 中文摘要 + 中文正文）、PR、回滚与监控说明。

## Git 提交规范

commit 标题的类型与范围使用英文标识符（conventional commits），摘要、正文必须使用中文。

推荐格式：

```text
<英文类型>(<英文范围>): <中文摘要>

变更编号：<change-id>
关联规格：<SPEC-ID-1>, <SPEC-ID-2>

变更内容：
- <中文说明>

验证方式：
- <测试命令或人工验证步骤>

风险与回滚：
- <风险和回滚方式>
```

字段约束：

- `英文类型`：`feat / fix / docs / style / refactor / perf / test / build / ci / chore / revert / spec`。
- `英文范围`：`<根模块>` 或 `<根模块>:<业务子模块>`。根模块取自仓库根目录划分（`skills`、`commands`、`agents`、`routing`、`templates`、`scripts`、`docs`、`openspec`、`examples`、`meta`），业务子模块使用小写英文 kebab-case。

示例：

```text
feat(skills:members): 增加续费提醒入口

变更编号：add-membership-renewal-reminder
关联规格：MEMBERSHIP-001

变更内容：
- 在会员中心增加续费提醒入口。

验证方式：
- 已运行 pnpm test membership。

风险与回滚：
- 可回滚该提交移除入口。
```

禁止：

```text
WIP
update
fix bug
misc
changes
```

## 包结构

```text
AGENTS.md
CLAUDE.md
NOTICE.md
routing/
  AGENTS.routing.md
  CLAUDE.routing.md
agents/
  product-strategist.md
  spec-architect.md
  implementation-engineer.md
  code-reviewer.md
  qa-gatekeeper.md
  release-manager.md
  git-steward.md
commands/
  ssf-think.md
  ssf-spec.md
  ssf-build.md
  ssf-review.md
  ssf-qa.md
  ssf-ship.md
  ssf-archive.md
  ssf-retro.md
  ssf-decision.md
  ssf-map.md
  ssf-karpathy.md
  ssf-init.md
  ssf-git.md
  ssf-branch.md
  ssf-commit.md
  ssf-pr.md
skills/
  ssf-think/
  ssf-spec/
  ssf-build/
  ssf-review/
  ssf-qa/
  ssf-ship/
  ssf-archive/
  ssf-retro/
  ssf-karpathy/
  ssf-git/
templates/
  product-change-brief.md
  user-journey.md
  intake-gate.md
  proposal.md
  spec.md
  technical-design.md
  tasks.md
  spec-readiness-review.md
  implementation-plan.md
  spec-to-code-map.md
  karpathy-preflight.md
  karpathy-diff-audit.md
  review-report.md
  sync-check.md
  git-hygiene-review.md
  acceptance-matrix.md
  negative-test-matrix.md
  risk-matrix.md
  regression-checklist.md
  exploratory-test-notes.md
  qa-signoff.md
  release-checklist.md
  rollback-plan.md
  monitoring-plan.md
  ship-decision.md
  migration-plan.md
  dev-handoff.md
  git-pr-gate.md
  archive-summary.md
  decision-record.md
  documentation-coverage.md
  git-pr-archive.md
  retro.md
  commit-message.md
  commit-gate.md
  git-status-audit.md
  git-checklist.md
  pr-description.md
  progress-state.json
  progress-timeline.md
  progress-verification.md
  progress-handoff.md
  verification-request.md
  verification-evidence.md
  verification-reviewer-notes.md
  verification-signoff.md
  git-hooks/commit-msg
  integration/
    AGENTS.snippet.md
    CLAUDE.snippet.md
docs/
  installation.md
  compatibility.md
examples/
  add-membership-renewal-reminder/
scripts/
  install-project-symlinks.sh
  validate-pack.sh
```

## 设计来源

SuperSpecFlow 融合并适配了：

- OpenSpec：规格驱动变更。
- Superpowers：agentic engineering discipline。
- gstack：多角色评审与发布门禁。
- multica-ai/andrej-karpathy-skills：Think Before Coding、Simplicity First、Surgical Changes、Goal-Driven Execution。

`ssf-karpathy` 是适配到本工作流的行为层，不是原仓库逐字复制。
