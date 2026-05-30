# Review Notes — SuperSpecFlow Pack

## 已发现并补强的问题

### 1. 缺 Git 工作流

原版本有 Think / Spec / Build / Review / QA / Ship / Archive / Retro，但没有把代码变更落到 Git 记录中。

已补充：

- `skills/ssf-git/SKILL.md`
- `agents/git-steward.md`
- `commands/ssf-git.md`
- `commands/ssf-branch.md`
- `commands/ssf-commit.md`
- `commands/ssf-pr.md`
- `templates/commit-message.md`
- `templates/git-checklist.md`
- `templates/pr-description.md`
- `templates/git-hooks/commit-msg`

### 2. commit 规范不够严格

原版本没有提交格式、提交语言、staged diff 审查、commit-to-spec 映射要求。

已补充硬规则：

- commit 内容必须中文。
- PR 标题和正文必须中文。
- commit 必须包含 change-id、Spec ID、验证方式、风险与回滚。
- 不允许 `WIP`、`update`、`fix bug`、`misc` 等模糊英文提交。
- 提交前必须检查 staged diff。
- 不盲目使用 `git add .`。

### 3. 缺 Karpathy 式编码行为约束

原版本强调 Superpowers 式流程，但对 LLM 常见问题约束还不够强：错误假设、过度设计、无关改动、目标不可验证。

已补充：

- `skills/ssf-karpathy/SKILL.md`
- `commands/ssf-karpathy.md`
- 在 `ssf-build` 中增加 Karpathy Preflight
- 在 `ssf-review` 中增加 Karpathy Diff Audit
- 在 `CLAUDE.md` 和 `AGENTS.md` 中加入隐式触发规则

### 4. Build 和 Git 没有闭环

原版本完成 task 后只更新 tasks.md，没有引导形成小步 commit。

已补充：

- 每完成一个可验证 task，建议进入 `/ssf-commit <change-id>`。
- 提交前必须展示 staged diff 摘要。
- 每个 commit 对应一个清晰目标、Spec ID 和测试证据。

### 5. Ship 缺少 Git / PR gate

原版本 Ship gate 有 QA / rollback / monitoring，但没有检查 commit 和 PR 的审计质量。

已补充：

- `ssf-ship` 的 Git / PR Gate。
- 如果 commit / PR 不合格，不能直接 Ship。
- PR 内容必须包含测试、风险、回滚和 QA 结果。

### 6. Archive 缺少 Git 历史沉淀

原版本 Archive 归档规格和决策，但没有归档 Git/PR 记录。

已补充：

- Git / PR Archive。
- commit 与 Spec ID 的归档矩阵。
- commit 语言或追踪缺陷进入 retro。

## 建议继续增强的方向

1. 为不同技术栈增加测试命令探测，例如 Next.js、Rails、Django、Go、Rust。
2. 增加 MCP / 浏览器 QA 适配，让 `ssf-qa` 能自动跑真实用户路径。已由 `workflow-scale-architecture` 拆出 `browser-mcp-qa-adapter` child OpenSpec。
3. 增加安全专用 agent，用于 auth、payment、webhook、secret、PII 等高风险场景。
4. 增加多 worktree 并行开发规则，让大 change 拆成多个 Spec cluster。已由 `workflow-scale-architecture` 拆出 `parallel-worktree-spec-clusters` child OpenSpec。

## 已接入的自动化门禁

- GitHub Actions workflow：`.github/workflows/validate.yml`
- CI 运行 `bash scripts/validate-pack.sh`
- CI 运行 `bash scripts/test.sh`
- CI 运行 `shellcheck` 覆盖核心脚本、hook 和测试 helper

## Workflow scale 已形成的路线

- `workflow-scale-architecture`：父级架构 contract，规定先建立 QA evidence，再扩展多 worktree Spec cluster。
- `browser-mcp-qa-adapter`：第一阶段 child change，定义 `qa-execution-plan.md`、`browser-run-report.md`、`qa-evidence/` 和 blocked signoff。
- `parallel-worktree-spec-clusters`：第二阶段 child change，定义 `cluster-plan.md`、`cluster-status.md`、`integration-gate.md` 和 parent integration gate。
