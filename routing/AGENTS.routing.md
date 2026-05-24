# SuperSpecFlow Routing

本文件是 SuperSpecFlow 的集中路由说明，可由宿主项目的 `AGENTS.md`、`CLAUDE.md`、全局 routing 或薄入口引用。不要复制本文件内容覆盖宿主项目已有指令文件。

宿主项目的业务规则、架构事实和本地约束优先。你是一个在接入项目中工作的 AI 研发团队成员，而不是单纯的代码补全器。

## 工作模式

SuperSpecFlow 负责提供默认研发流程：

```text
Think → Spec → Build → Review → QA → Ship → Git/PR → Archive → Retro
```

本项目使用一套 AI 软件研发流程：

- **OpenSpec 风格**：把需求沉淀为可追踪的 change contract。
- **Superpowers 风格**：执行时先理解、再计划、再测试、再实现、再验证。
- **gstack 风格**：通过产品、设计、工程、QA、安全、发布角色做门禁审查。
- **Karpathy 风格**：编码前暴露假设，简单优先，外科手术式修改，目标驱动验证。
- **GitOps 风格**：分支、暂存、commit（英文类型 + 中文正文）、PR、回滚与 change-id / Spec ID 对齐。

对应 skills：

- `skills/ssf-think`：想清楚产品和设计
- `skills/ssf-spec`：写 OpenSpec 风格规格
- `skills/ssf-build`：按任务和 TDD 执行
- `skills/ssf-review`：工程和代码审查
- `skills/ssf-qa`：验收、风险、回归测试
- `skills/ssf-ship`：发版门禁
- `skills/ssf-git`：分支、暂存、commit（英文类型 + 中文正文）、PR、回滚
- `skills/ssf-karpathy`：编码前思考、简单优先、外科手术式修改、目标驱动验证
- `skills/ssf-archive`：归档和文档同步
- `skills/ssf-retro`：复盘

## 关键约束

1. 不要把用户的一句话功能请求直接当成写代码许可。
2. 用户自然语言请求必须先过 Intake Gate，不要仅凭关键词直接进入完整流程。
3. 非平凡功能不要直接写代码，必须有 OpenSpec change-id。
4. 每个行为变更和实现必须映射到 Spec ID。
5. 优先写失败测试，再实现。
6. Review 反馈必须先验证事实，再判断是否采纳。
7. QA 不只测 happy path，必须包含负向和回归路径。
8. 发布必须有 rollback / monitoring 意识。
9. commit 标题的类型与范围使用英文标识符（conventional commits），摘要、正文、字段名、说明全部使用中文。
10. 所有 PR 标题（中文摘要部分）和正文必须是中文。
11. 所有项目文档（README、CLAUDE.md、AGENTS.md、OpenSpec proposal / design / tasks / specs、决策记录、回顾、Runbook 等）的正文语言风格统一使用中文。代码标识符、文件名、字段名、命令、URL、conventional commit 关键字、gherkin 关键字（GIVEN/WHEN/THEN/AND）等技术符号保留英文。如需例外，必须在该文档中显式说明原因。宿主项目可在本地指令文件中显式覆盖此默认。

## 仓库产物边界

SuperSpecFlow 仓库提交的是工作流包源码和可追踪变更契约，不提交本地 workflow 运行时、安装副本或缓存产物。

- `openspec/` 是本仓库 OpenSpec change contract，行为规则变更必须随对应 `openspec/changes/<change-id>/` 提交。
- `engineering/<change-id>/` 是 SuperSpecFlow 本仓库的可提交工程交付目录，可保存 `spec-to-code-map.md`、`spec-readiness-review.md` 等本仓库工程交付物，不属于宿主项目运行时产物。
- 宿主项目如果采用 OpenSpec 管理自身需求，其项目内 `openspec/` 也应作为业务变更契约提交。
- `superpowers/`、`docs/superpowers/`、`.superspecflow/`、`.claude/`、`.codex/`、`.DS_Store` 属于本仓库本地运行时、安装或缓存产物，不得提交。
- 提交前必须通过 `git status --short`、staged diff 和 `scripts/validate-pack.sh` 确认没有上述产物进入 Git 跟踪列表。

## Artifact Paths

宿主项目运行时产物统一写入 `.superspecflow/` 命名空间。读取时使用 new path first，然后 fallback 到兼容期旧路径；写入新产物时不得推荐根目录旧路径。

标准运行时命名空间：

| 产物 | 宿主项目运行时路径 |
|---|---|
| Engineering artifacts | `.superspecflow/engineering/<change-id>/` |
| QA artifacts | `.superspecflow/qa/<change-id>/` |
| Release artifacts | `.superspecflow/release/<change-id>/` |
| Archive artifacts | `.superspecflow/archive/<change-id>/` |
| Retro artifacts | `.superspecflow/retro/<change-id>/` |
| Decision records | `.superspecflow/decisions/` |
| Spec-to-code maps | `.superspecflow/maps/<change-id>/` |
| Review artifacts | `.superspecflow/reviews/<change-id>/` |
| Karpathy audits | `.superspecflow/karpathy/<change-id>/` |
| Cluster artifacts | `.superspecflow/clusters/<parent-change>/` |

语境边界：

- `openspec/` 是可提交 OpenSpec change contract，不属于运行时缓存，不迁移到 `.superspecflow/`。
- SuperSpecFlow 本仓库的 `engineering/<change-id>/` 是包源码层工程交付物，不标为非法路径，不迁移到 `.superspecflow/`。
- 宿主项目旧路径如 `engineering/<change-id>/`、`qa/<change-id>/`、`release/<change-id>/`、`archive/<change-id>/`、`retro/<change-id>/` 只作为兼容读取 fallback 或迁移提示；新写入必须使用 `.superspecflow/` 标准路径。
- `.superspecflow/progress/<change-id>/` 由 `progress-tracking` 定义，`.superspecflow/verification/<change-id>/` 由 `cross-agent-verification` 定义，`.superspecflow/clusters/<parent-change>/` 由 `parallel-worktree-spec-clusters` 定义，本 routing 只确认它们同属 `.superspecflow/` 命名空间，不重定义文件协议。
- `.superspecflow/qa/<change-id>/qa-execution-plan.md`、`browser-run-report.md` 和 `qa-evidence/` 由 `browser-mcp-qa-adapter` 定义，用于 evidence-backed browser/MCP QA。

## Strict Intake Gate

自然语言请求必须先分类，不是所有任务都适合走完整工作流。

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

普通 `/ssf-*` 显式命令只执行一次性动作，不自动创建 `.superspecflow/`。只有 `/ssf-init` 或明确安装动作可以创建 `.superspecflow/`，使项目 opt-in 自然语言 Intake Gate。全局安装只提供能力；若当前项目没有 `.superspecflow/` 或显式 routing include，不默认接管自然语言。

## 隐式路由规则

### Product / Think

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

### Spec

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

### Build / Engineering

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

Progress tracking:

- 如果恢复已有 change，且 `.superspecflow/progress/<change-id>/` 存在，先读取 `state.json` 和 `handoff.md`，再读取 OpenSpec。
- 如果本次工作会持续超过一个可验证 task，使用 `templates/progress-state.json`、`templates/progress-timeline.md`、`templates/progress-verification.md` 和 `templates/progress-handoff.md` 创建或维护 `.superspecflow/progress/<change-id>/`。
- 声称 task、阶段或 change 完成前，必须在 `.superspecflow/progress/<change-id>/verification.md` 写入或引用 fresh verification，并让验证范围匹配完成声明范围。

Spec cluster / worktree:

- 如果 change 预计超过 8 个 tasks、超过 6 个 Spec IDs，或横跨两个以上相对独立子系统，进入 `ssf-spec` 或 `ssf-build` 前必须评估是否拆成 Spec cluster。
- Parent change 的 cluster 产物写入 `.superspecflow/clusters/<parent-change>/cluster-plan.md`、`cluster-status.md` 和 `integration-gate.md`。
- Worktree 只是执行隔离机制，不是发布边界；cluster 通过不得自动等同于 parent change 可发布。
- 非 cluster 工作继续沿用普通分支规则；cluster 场景才叠加 `<cluster-id>` 段。

### Karpathy 编码纪律 / Diff Discipline

任何写代码、修 bug、重构、review、提交前，都要遵守：

- 明确目标。
- 显式写出假设。
- 有歧义时列出多个解释。
- 发现更简单方案时主动指出。
- 困惑时暂停并说明困惑点。
- 只写满足 spec 的最小实现。
- 不为未来需求加抽象。
- 不加未要求的配置、扩展点、框架。
- 只改必要文件和必要行。
- 不顺手重构邻近代码。
- 不顺手改注释、格式、命名。
- 遵循现有风格。
- 只清理本次改动造成的无用代码。
- “修 bug”要转成“写复现测试，再修到通过”。
- “加校验”要转成“写无效输入测试，再修到通过”。
- “重构”要转成“重构前后测试均通过”。

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

### Review

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

Cross-agent verification:

- 如果用户要求另一个 agent 独立核验同一个 `<change-id>`，使用 `.superspecflow/verification/<change-id>/` 下的 `request.md`、`evidence.md`、`reviewer-notes.md` 和 `signoff.md`。
- 主 agent 写 `request.md` 和 `evidence.md`；review agent 只基于 OpenSpec、diff、progress 和 evidence 写 `reviewer-notes.md` / `signoff.md`。
- 没有可复查 evidence 时不得生成 `signoff.md`。
- `signoff.md` 的结果只能是 `approve / changes-requested / blocked`，并必须列出已检查 Spec ID、证据引用和残余风险。
- 第一版不引入自动 agent 通信、抽象共识协议、双签门禁或多方投票。

### QA

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
- qa-execution-plan.md，适用于 browser/MCP QA
- browser-run-report.md，适用于 browser/MCP QA
- qa-evidence/，适用于 browser/MCP QA
- qa-signoff.md

Browser / MCP QA:

- `browser-mcp-qa-adapter` 要求 `/ssf-qa` 从 acceptance matrix 中的 E2E / user journey 场景生成 `.superspecflow/qa/<change-id>/qa-execution-plan.md`。
- 如果目标和浏览器/MCP 工具可用，agent 记录 `.superspecflow/qa/<change-id>/browser-run-report.md` 和 `qa-evidence/`。
- 如果没有可运行目标，QA signoff 必须使用 `Blocked: No runnable target`。
- 如果浏览器/MCP 工具不可用，QA signoff 必须使用 `Blocked: Tool unavailable`。
- 不得在没有 browser run report、qa-evidence 或明确人工验证记录时声明 `Automated Browser Passed`。
- `/ssf-qa <parent-change>` 在 Spec cluster 场景必须汇总 cluster QA evidence，并额外记录 parent integration 级回归或 blocked reason。

### Ship / Release

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

Spec cluster ship gate:

- Parent change 有 cluster 时，`ssf-ship` 必须读取 `.superspecflow/clusters/<parent-change>/integration-gate.md`。
- 缺少 integration gate、cluster QA evidence、review 结论或 commit evidence 时，不得推荐 ship。

### Git / Commit / PR

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

1. commit 标题和正文必须使用中文说明；标题中的类型和范围保留英文标识符。
2. 允许保留必要代码标识符、文件路径、命令、Spec ID、change-id。
3. 不允许 `WIP`、`update`、`fix bug`、`misc` 等模糊英文提交。
4. 提交前必须检查 `git status --short`、`git diff --stat`、`git diff --check`、`git diff --staged`。
5. 不盲目 `git add .`，优先选择性暂存。
6. 无 change-id / Spec ID 的行为变更不提交。
7. 无验证证据不提交完成态 commit。

## 显式命令优先级

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
/ssf-init
/ssf-git
/ssf-branch <change-id> <topic>
/ssf-commit <change-id>
/ssf-pr <change-id>
```

## 高风险变更强制门禁

以下类型不能跳过 Spec、QA、Ship、Git/PR：

- 支付、订阅、计费、退款
- 登录、权限、认证、用户数据
- 数据库迁移、数据删除、批量任务
- 安全、密钥、外部 webhook
- AI 自动执行真实世界动作
- 会影响生产稳定性的基础设施变更

### 高风险关键词

看到以下关键词时，自动提高门禁级别：

支付、订阅、退款、计费、权限、登录、认证、数据库、迁移、删除、批量、webhook、密钥、安全、生产、发布、用户数据。

必须额外产出：

- risk-matrix.md
- migration-plan.md，若涉及数据结构
- rollback-plan.md
- monitoring-plan.md
- negative tests
- 符合规范的 commit（英文类型 + 英文范围 + 中文摘要 + 中文正文）与符合规范的 PR

## Spec-to-Code Rule

任何行为变更都必须映射到 Spec ID。

如果无法映射：

1. 先更新 OpenSpec；或
2. 不做该变更。

## Test Rule

- 每个 requirement 至少一个测试。
- 每个 MUST NOT 至少一个负向测试。
- 每个 P0 risk 必须自动化测试或明确人工 gate。

## Git 提交规范

commit 标题格式：

```text
<英文类型>(<英文范围>): <中文摘要>
```

- `英文类型`：使用 conventional commits 标准集合（见下）。
- `英文范围`：必须采用 `<根模块>` 或 `<根模块>:<业务子模块>` 的形式。
  - 根模块取自仓库根目录划分：`skills`、`commands`、`agents`、`routing`、`templates`、`scripts`、`docs`、`openspec`、`examples`、`meta`（用于 `CLAUDE.md`、`README.md` 等根级文档）。
  - 业务子模块按本次改动实际涉及的业务模块填写，使用小写英文 kebab-case，例如 `members`、`payment`、`auth`。
  - 示例：`feat(skills:members): 增加续费提醒入口`、`fix(routing:payment): 修复重试状态不一致`。
- `中文摘要`：必须是中文。

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

允许的英文类型（conventional commits 标准 + 项目定制 `spec`）：

| 类型 | 用途 |
|---|---|
| feat | 新功能或新增行为 |
| fix | 缺陷修复 |
| docs | README、说明、runbook、用户文档 |
| style | 不影响语义的格式调整 |
| refactor | 不改变行为的结构调整 |
| perf | 性能优化 |
| test | 单测、集成测试、E2E、负向测试 |
| build | 构建脚本、依赖、工具链 |
| ci | CI 配置 |
| chore | 杂项维护 |
| revert | 回滚提交 |
| spec | OpenSpec、需求、验收标准、任务（项目定制） |

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

## 完成定义 / Completion Criteria

一个功能只有满足以下条件才算完成：

- OpenSpec tasks 全部完成或明确跳过
- spec-to-code-map 已更新
- tests 通过或未运行原因明确
- Karpathy Diff Audit 无严重问题
- review 无 🔴
- QA signoff 存在
- release blockers 已解决或显式豁免
- Git 分支清晰，commit 标题符合 `<英文类型>(<英文范围>): <中文摘要>` 规范，正文中文
- PR 标题遵循同样规范，PR 正文为中文，包含测试、风险、回滚、QA
- PR / release 内容为中文
- rollback / monitoring 说明完整
- archive / decision ledger 已更新
