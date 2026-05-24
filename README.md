# SuperSpecFlow

SuperSpecFlow 是一套面向 Claude Code / Codex CLI 的 AI 软件研发工作流包。它的目标不是让 AI 更快地堆代码，而是让 AI 在已有项目里像一个可审计的小型研发团队一样工作：先判断请求类型，再澄清目标，再形成可追踪规格，再小步实现、审查、验收、发布、归档和复盘。

项目初衷有三点：

1. **防止一句话需求直接变成失控改动**：自然语言请求先经过 Intake Gate，区分纯问答、轻量任务、非平凡行为变更、高风险变更和 Git/QA/发布动作。
2. **让每个行为变更都能追踪**：非平凡变更必须落到 OpenSpec change-id / Spec ID，并在实现、测试、commit、PR、回滚说明之间保持映射。
3. **把优秀研发纪律变成 agent 可执行规则**：融合 OpenSpec、Superpowers、gstack、Karpathy 风格的 diff discipline，以及 GitOps 的分支、暂存、提交和 PR 门禁。

最终效果是：用户可以用自然语言发起工作，也可以显式调用 `/ssf-*` 命令；agent 不会默认接管所有项目，而是在项目 opt-in 后按 SuperSpecFlow 的门禁执行。

## 适合谁

- 想在真实项目里使用 AI coding agent，但需要可控流程、可追踪提交和发布门禁的团队。
- 同时使用 Claude Code 和 Codex CLI，希望两端共享一套研发规则的人。
- 想把需求、实现、测试、评审、QA、发布和复盘串成一个闭环的个人或小团队。

不适合的场景：

- 只想要一次性代码补全，不关心规格、测试、提交和回滚。
- 希望 agent 自动覆盖宿主项目已有 `AGENTS.md` / `CLAUDE.md` 的项目。SuperSpecFlow 的原则是宿主项目规则优先，自己只提供流程门禁。

## 工作模型

完整流程是：

```text
Think → Spec → Build → Review → QA → Ship → Git/PR → Archive → Retro
```

对应五层约束：

| 风格 | 在本项目中的作用 |
|---|---|
| OpenSpec | 用 change-id、Spec ID、proposal、specs、tasks 和 archive 记录变更合同 |
| Superpowers | 强制先理解、再计划、TDD、小步实现、验证后再宣称完成 |
| gstack | 用产品、规格、工程、QA、发布、Git 等角色做门禁审查 |
| Karpathy | 编码前暴露假设，简单优先，外科手术式修改，目标驱动验证 |
| GitOps | 分支、暂存、commit、PR、rollback 与 change-id / Spec ID 对齐 |

这些来源不是作为外部运行时依赖被整体搬进项目，而是被拆成阶段能力：

- **OpenSpec** 提供变更合同：change-id、Spec ID、proposal、design、specs、tasks、scenarios、MUST NOT、archive。
- **Superpowers** 提供执行纪律：先理解、再计划、优先 TDD、小步实现、验证后再宣称完成、接收 review 前先核验事实。
- **gstack** 提供角色门禁：产品、设计、规格、工程、代码审查、QA、发布、Git 管理等角色视角。
- **Karpathy** 提供编码行为约束：暴露假设、寻找更简单方案、避免投机抽象、保持 surgical diff、把目标变成可验证结果。

各阶段使用的能力如下：

| 阶段 | OpenSpec 能力 | Superpowers 能力 | gstack 能力 | Karpathy 能力 |
|---|---|---|---|---|
| Intake | 判断请求是否需要 change-id / Spec ID | 先分类、再行动，轻量任务不强行升级完整流程 | 判断是否需要产品、工程、QA、发布或 Git 角色介入 | 选择最小流程，避免把小问题过度流程化 |
| Think | 产出可进入 proposal 的问题、目标、non-goals 和成功指标 | 先理解用户目的和约束，再提出方案 | CEO / Designer / Product 视角挑战价值、路径和范围 | 暴露假设，压缩 MVP，寻找更简单方案 |
| Spec | 生成 proposal、design、specs、tasks、scenarios、MUST NOT 和 Spec Readiness Review | 把需求转成可执行、可验证的任务顺序 | Spec Architect 视角检查需求是否完整、可测、可归档 | 防止范围膨胀，把每条要求收敛成可验证目标 |
| Build | 读取 OpenSpec change，只实现映射到 Spec ID 的任务，更新 tasks 和 spec-to-code map | implementation plan、优先 failing tests、小步实现、fresh verification、progress recovery | Implementation Engineer 视角执行实现和交接 | Karpathy preflight、surgical changes、不做无关重构、不写投机抽象 |
| Review | 检查 spec / code / test 是否同步，确认行为改动都有 Spec ID | 接收 review 反馈前先验证事实，支持 cross-agent verification | Engineering Manager / Code Reviewer / Security Reviewer 视角找阻塞问题 | Karpathy Diff Audit，检查错误假设、过度设计、无关改动和不可验证目标 |
| QA | 从 requirements、scenarios、MUST NOT 生成 acceptance、negative、risk 和 regression 矩阵 | 用证据驱动验收，不只看 happy path | QA Gatekeeper 视角给出 ship / monitoring / no-ship 建议 | 关注边界条件、残余风险和未验证假设 |
| Ship | 检查 OpenSpec tasks、QA signoff、rollback、monitoring 和 release blockers | 完成前必须有新鲜验证证据，不确定项必须标注 | Release Manager 视角做 go / no-go 判断 | 确认可发布范围足够小，阻止含混风险被包装成完成态 |
| Git / PR | commit 和 PR 关联 change-id、Spec ID、验证方式和回滚说明 | 小步、可验证、可恢复的提交纪律 | Git Steward 视角检查分支、暂存、PR、merge、rollback | 审查 staged diff 是否 surgical，拒绝无关文件和顺手重构 |
| Archive | 归档 change、决策、文档覆盖和最终产物索引 | 把上下文落盘，避免历史只留在聊天记录 | 文档和发布收尾视角检查可追踪性 | 记录实际范围，避免归档时扩大解释 |
| Retro | 对照 OpenSpec contract 回看流程缺口 | 把执行经验转成下一轮可操作改进 | 从产品、规格、工程、QA、发布各角色复盘质量 | 复盘是否存在错误假设、过度设计、非最小改动或验证不足 |

自然语言不会被简单关键词直接升级成完整流程。SuperSpecFlow 先做 Intake Gate：

| 请求类型 | 处理方式 |
|---|---|
| 纯问答 / 解释 | 直接回答，不启动完整流程 |
| 轻量任务 | 说明目标、影响范围、验证方式，小范围完成 |
| 非平凡行为变更 | 进入 Think / Spec，形成 change-id 和 Spec ID |
| 已有规格实现 | 进入 Build，按 OpenSpec tasks 执行 |
| Review / QA / Ship / Git | 进入对应阶段 |
| 高风险变更 | 强制 Spec、QA、Ship、Git/PR 门禁 |

## 快速接入

SuperSpecFlow 同时支持 Claude Code 和 Codex CLI。默认会把全局 routing include 同时写入两个宿主；只装其中一个用 `--claude-only` 或 `--codex-only` 收窄。

### 方式 1：让 AI 帮你装（推荐）

打开你的 Claude Code 或 Codex CLI，把下面整段中文粘贴进去，AI 会自己完成 clone、安装和校验：

```text
请把 SuperSpecFlow 安装到本机：

1. 如果 ~/.superspecflow/ 不存在，执行：
   git clone --depth=1 https://github.com/HobaoKing/SuperSpecFlow.git ~/.superspecflow
   如果已存在，执行：
   git -C ~/.superspecflow fetch --depth=1 origin master && git -C ~/.superspecflow reset --hard origin/master
2. 检测我在用哪个 CLI：
   - 只有 ~/.claude/ 存在 → 运行 ~/.superspecflow/scripts/install-global.sh --claude-only
   - 只有 ~/.codex/ 存在 → 运行 ~/.superspecflow/scripts/install-global.sh --codex-only
   - 两个都存在 → 运行 ~/.superspecflow/scripts/install-global.sh --both
   - 两个都不存在 → 停下来问我应该装哪一个，不要擅自创建目录
3. 校验：grep "SuperSpecFlow" 对应的 ~/.claude/CLAUDE.md 或 ~/.codex/AGENTS.md，确认 include 行已写入；如果脚本提示要我手动追加，把那一行原文展示给我。
4. 简要报告每一步结果。
```

### 方式 2：一句话命令

```bash
# 两个 CLI 都装（默认）
curl -fsSL https://raw.githubusercontent.com/HobaoKing/SuperSpecFlow/master/scripts/bootstrap.sh | bash

# 只装 Claude Code
curl -fsSL https://raw.githubusercontent.com/HobaoKing/SuperSpecFlow/master/scripts/bootstrap.sh | bash -s -- --claude-only

# 只装 Codex CLI
curl -fsSL https://raw.githubusercontent.com/HobaoKing/SuperSpecFlow/master/scripts/bootstrap.sh | bash -s -- --codex-only
```

bootstrap 会把仓库 clone 到 `~/.superspecflow/`（可用环境变量 `SUPERSPECFLOW_HOME` 覆盖），然后调用 `install-global.sh` 并透传参数。已存在 checkout 时会 `fetch + reset --hard origin/master` 更新到最新。一句话命令需要的 raw URL 始终指向 `master` 分支，开发分支上的改动合入 master 后才会被一句话安装拿到。

### 方式 3：手动 clone

```bash
git clone https://github.com/HobaoKing/SuperSpecFlow.git ~/.superspecflow
~/.superspecflow/scripts/install-global.sh --both     # 或 --claude-only / --codex-only
```

### 项目 opt-in

任意一种方式装完后，进入要启用的宿主项目，执行：

```text
/ssf-init
```

`/ssf-init` 只创建 `.superspecflow/enabled` sentinel 和标准运行产物目录，不修改宿主项目的 `AGENTS.md` 或 `CLAUDE.md`。

详细安装、兼容路径和卸载方式见 [docs/installation.md](docs/installation.md)。Claude Code / Codex 差异见 [docs/compatibility.md](docs/compatibility.md)。

## 卸载

与安装一对一对称，三种方式任选其一。卸载只移除 SuperSpecFlow 自己写入的 include 行，绝不改动用户在 `CLAUDE.md` / `AGENTS.md` 里的其他内容。

### 方式 1：让 AI 帮你卸（推荐）

打开你的 Claude Code 或 Codex CLI，把下面整段粘贴进去：

```text
请把 SuperSpecFlow 从本机卸载：

1. 如果 ~/.superspecflow/scripts/uninstall-global.sh 存在，执行：
   ~/.superspecflow/scripts/uninstall-global.sh --both --purge
   该脚本会精确移除 ~/.claude/CLAUDE.md 和 ~/.codex/AGENTS.md 里的 SuperSpecFlow include 行（其他内容保留），并删除 ~/.superspecflow/ 目录。
2. 如果 ~/.superspecflow/ 不存在，但 ~/.claude/CLAUDE.md 或 ~/.codex/AGENTS.md 里还有指向其他路径的 SuperSpecFlow include 行：
   找出形如 "@/path/to/SuperSpecFlow/routing/CLAUDE.global.md" 或 "@/path/to/SuperSpecFlow/routing/AGENTS.global.md" 的行，把那一行（且只有那一行）删除。如果文件因此变空，把文件本身也删除。
3. 如果之前在 ~/.claude/settings.json 中合并过 SuperSpecFlow 的 SessionStart hook（command 指向 .../scripts/hooks/session-start-detect.sh），手动移除该 hook 条目。
4. 简要报告每一步结果。
```

### 方式 2：本地脚本

```bash
# 同时移除两个宿主的 include，并删除 pack 目录
~/.superspecflow/scripts/uninstall-global.sh --both --purge

# 只清 Claude Code，保留 pack 目录
~/.superspecflow/scripts/uninstall-global.sh --claude-only

# 只清 Codex CLI，保留 pack 目录
~/.superspecflow/scripts/uninstall-global.sh --codex-only
```

`--purge` 会删除 pack 目录所在路径（`~/.superspecflow/` 或你手动 clone 的位置），如果当前工作目录在 pack 内部会拒绝执行，避免 `rm -rf` 掉运行中的脚本。`settings.json` 里的 SessionStart hook 由脚本提示你手动清理，不擅自改写。

### 方式 3：手动

```bash
# 1. 找出 include 行（形如 @<pack>/routing/CLAUDE.global.md）
grep SuperSpecFlow ~/.claude/CLAUDE.md ~/.codex/AGENTS.md 2>/dev/null

# 2. 用编辑器删除这些 include 行；如果文件因此变空，删除整个文件
# 3. 删除 pack 目录
rm -rf ~/.superspecflow

# 4. 如有 SessionStart hook，从 ~/.claude/settings.json 中移除指向 .../session-start-detect.sh 的条目
```

### 项目级卸载

宿主项目内的 SuperSpecFlow 运行时仅一个目录：

```bash
rm -rf <project>/.superspecflow
```

不会影响全局安装。`~/.superspecflow/`（家目录的装包路径）与 `<project>/.superspecflow/`（项目运行时）是两个互不依赖的目录。

## 使用方式

### 自然语言

项目 opt-in 后，可以直接说：

```text
我要做一个会员续费提醒功能
```

SuperSpecFlow 应先判断这是非平凡行为变更，然后进入产品思考和规格阶段，而不是直接改代码。

也可以说：

```text
帮我提交这次改动
```

这会进入 Git 工作流审计，检查分支、diff、Spec ID、验证证据和中文提交规范。

### 显式命令

显式命令可用于直接进入某个阶段：

```text
/ssf-think 会员续费提醒
/ssf-spec add-membership-renewal-reminder
/ssf-build all
/ssf-review
/ssf-qa add-membership-renewal-reminder
/ssf-ship add-membership-renewal-reminder
/ssf-git
/ssf-branch add-membership-renewal-reminder 会员续费提醒
/ssf-commit add-membership-renewal-reminder
/ssf-pr add-membership-renewal-reminder
/ssf-archive add-membership-renewal-reminder
/ssf-retro add-membership-renewal-reminder
/ssf-decision 会员续费提醒入口位置
/ssf-map add-membership-renewal-reminder
/ssf-karpathy 检查当前实现是否过度设计
/ssf-init
```

## 命令文件速查

`commands/` 是显式 slash command 的入口文件。每个文件只负责把用户输入路由到对应 skill 或产物格式。

| 文件 | 命令 | 作用 |
|---|---|---|
| `commands/ssf-think.md` | `/ssf-think` | 产品思考阶段，澄清价值、用户路径、MVP、non-goals 和决策记录 |
| `commands/ssf-spec.md` | `/ssf-spec` | 生成 OpenSpec change contract，包括 proposal、specs、design、tasks 和 readiness review |
| `commands/ssf-build.md` | `/ssf-build` | 读取 OpenSpec 后实现，生成 implementation plan、spec-to-code map、测试和 dev handoff |
| `commands/ssf-review.md` | `/ssf-review` | 做工程审查，输出阻塞项、建议项、记录项以及 spec/code/test 同步检查 |
| `commands/ssf-qa.md` | `/ssf-qa` | 生成 QA gate，包括 acceptance、negative、risk、regression、exploratory notes 和 signoff |
| `commands/ssf-ship.md` | `/ssf-ship` | 做发布门禁，检查 QA、rollback、monitoring、PR 描述和 ship decision |
| `commands/ssf-git.md` | `/ssf-git` | 审计分支、工作区、暂存、runtime 产物和下一步 Git 建议 |
| `commands/ssf-branch.md` | `/ssf-branch` | 基于 change-id 和主题创建或建议 `ssf/<change-id>-<slug>` 分支 |
| `commands/ssf-commit.md` | `/ssf-commit` | 准备中文 commit，检查 staged diff、Spec ID、验证方式和无关文件 |
| `commands/ssf-pr.md` | `/ssf-pr` | 准备中文 PR 标题和正文，包含测试、风险、回滚、QA 和发布信息 |
| `commands/ssf-archive.md` | `/ssf-archive` | 归档 change、同步文档、更新 decision ledger 和文档覆盖检查 |
| `commands/ssf-retro.md` | `/ssf-retro` | 复盘产品、规格、开发、QA、发布质量，并输出流程改进 |
| `commands/ssf-decision.md` | `/ssf-decision` | 记录产品或工程决策，写入 `.superspecflow/decisions/` |
| `commands/ssf-map.md` | `/ssf-map` | 创建或更新 Spec-to-Code Map |
| `commands/ssf-karpathy.md` | `/ssf-karpathy` | 检查假设、歧义、简单方案、过度设计、无关改动和可验证目标 |
| `commands/ssf-init.md` | `/ssf-init` | 为宿主项目创建 `.superspecflow/enabled` 和标准运行产物目录 |

## 能力与角色文件

`skills/` 定义阶段能力，`agents/` 定义角色视角。命令通常先进入 skill，复杂审查或产物生成再由角色规则约束。

### Skills

| 文件 | 作用 |
|---|---|
| `skills/ssf-think/SKILL.md` | 阶段一，产品和设计思考，输出 Product Change Brief、Decision Record 和 design 输入 |
| `skills/ssf-spec/SKILL.md` | 阶段二，生成 OpenSpec 风格 proposal、specs、design、tasks 和 readiness review |
| `skills/ssf-build/SKILL.md` | 阶段三，按 OpenSpec tasks、TDD 和最小实现纪律完成开发 |
| `skills/ssf-review/SKILL.md` | 阶段四，工程审查与 review 接收纪律，检查阻塞项和同步关系 |
| `skills/ssf-qa/SKILL.md` | 阶段四点五，生成验收、负向、风险、回归和 QA signoff |
| `skills/ssf-ship/SKILL.md` | 阶段五，发布门禁、rollback、monitoring、PR 描述和 ship/no-ship |
| `skills/ssf-git/SKILL.md` | Git 工作流门禁，约束分支、暂存、中文 commit、中文 PR 和回滚 |
| `skills/ssf-karpathy/SKILL.md` | 编码行为约束，防止错误假设、过度设计、无关改动和不可验证目标 |
| `skills/ssf-archive/SKILL.md` | 阶段六，归档 OpenSpec change、同步文档、更新 decision ledger |
| `skills/ssf-retro/SKILL.md` | 复盘阶段，总结流程质量和可执行改进 |

### Agents

| 文件 | 作用 |
|---|---|
| `agents/product-strategist.md` | 产品策略角色，挑战价值、压缩范围、定义用户路径、non-goals 和成功指标 |
| `agents/spec-architect.md` | 规格架构角色，把产品意图转成可实现、可测试、可归档的 OpenSpec contract |
| `agents/implementation-engineer.md` | 工程实现角色，按 Spec ID、TDD、小步实现和 spec-to-code map 执行 |
| `agents/code-reviewer.md` | 代码审查角色，检查正确性、安全、数据、性能、测试缺口和过度抽象 |
| `agents/qa-gatekeeper.md` | QA 角色，把规格转成验收矩阵、负向测试、风险矩阵和 signoff |
| `agents/release-manager.md` | 发布角色，检查 release blockers、rollback、monitoring 和 go/no-go |
| `agents/git-steward.md` | Git 管理角色，保证分支、提交、PR、回滚与 change-id、Spec ID、验证证据一致 |

## 路由与入口文件

| 文件 | 作用 |
|---|---|
| `AGENTS.md` | Codex / generic agents 的项目入口，引用本仓库规则并声明 SuperSpecFlow routing |
| `CLAUDE.md` | Claude Code 的项目入口，语义与 `AGENTS.md` 对齐 |
| `routing/AGENTS.routing.md` | Codex / generic agents 的完整默认路由规则 |
| `routing/CLAUDE.routing.md` | Claude Code 的完整默认路由规则 |
| `routing/AGENTS.global.md` | Codex 全局薄壳，检测宿主项目是否 opt-in，再决定是否读取默认路由 |
| `routing/CLAUDE.global.md` | Claude Code 全局薄壳，结合 SessionStart hook 或 sentinel 检测 opt-in |
| `templates/integration/AGENTS.snippet.md` | 不支持 `@` include 时，给宿主 `AGENTS.md` 使用的极薄入口文本 |
| `templates/integration/CLAUDE.snippet.md` | 不支持 `@` include 时，给宿主 `CLAUDE.md` 使用的极薄入口文本 |

## 模板文件速查

`templates/` 是各阶段产物的骨架，不是运行时缓存。常用模板按用途分组如下：

| 类别 | 文件 |
|---|---|
| Intake / 产品 | `intake-gate.md`、`product-change-brief.md`、`user-journey.md`、`decision-record.md` |
| OpenSpec | `proposal.md`、`spec.md`、`technical-design.md`、`tasks.md`、`spec-readiness-review.md` |
| 工程执行 | `implementation-plan.md`、`spec-to-code-map.md`、`dev-handoff.md`、`sync-check.md` |
| Karpathy 纪律 | `karpathy-preflight.md`、`karpathy-diff-audit.md` |
| Review | `review-report.md`、`git-hygiene-review.md` |
| QA | `acceptance-matrix.md`、`negative-test-matrix.md`、`risk-matrix.md`、`regression-checklist.md`、`exploratory-test-notes.md`、`qa-signoff.md` |
| Release | `release-checklist.md`、`rollback-plan.md`、`monitoring-plan.md`、`ship-decision.md`、`migration-plan.md`、`pr-description.md` |
| Git / PR | `git-checklist.md`、`git-status-audit.md`、`commit-message.md`、`commit-gate.md`、`git-pr-gate.md`、`git-pr-archive.md`、`git-hooks/commit-msg` |
| Archive / Retro | `archive-summary.md`、`documentation-coverage.md`、`retro.md` |
| Progress / Verification | `progress-state.json`、`progress-timeline.md`、`progress-verification.md`、`progress-handoff.md`、`verification-request.md`、`verification-evidence.md`、`verification-reviewer-notes.md`、`verification-signoff.md` |

## 目录结构

| 路径 | 说明 |
|---|---|
| `commands/` | 显式命令入口，一条命令一个 Markdown 文件 |
| `skills/` | 阶段能力定义，供 Claude Code / Codex 读取执行 |
| `agents/` | 角色规则，用于产品、规格、工程、审查、QA、发布和 Git 门禁 |
| `routing/` | 全局薄壳和默认完整路由 |
| `templates/` | 各阶段产物模板和集成入口片段 |
| `scripts/` | 安装、初始化、验证和 hook 脚本 |
| `docs/` | 安装、兼容性、分支策略等用户文档 |
| `openspec/changes/` | 本仓库自身行为规则变更的 OpenSpec contract |
| `engineering/<change-id>/` | 本仓库包源码层工程交付物，例如 spec-to-code map |
| `tests/` | bats 测试，覆盖安装、初始化、artifact path、progress、verification 等契约 |
| `examples/` | 示例变更流程，展示从 OpenSpec 到 QA、release、archive、retro 的产物 |

## 版本控制边界

SuperSpecFlow 仓库提交工作流包源码和 OpenSpec 变更契约：`routing/`、`skills/`、`commands/`、`agents/`、`templates/`、`scripts/`、用户文档、测试、示例和 `openspec/`。其中 `openspec/` 是本仓库行为规则变更的 change contract，不能被当作运行时产物忽略。

不要提交本地 workflow 运行时、安装副本或缓存产物，例如 `superpowers/`、`.superspecflow/`、`.claude/`、`.codex/` 和 `.DS_Store`。

宿主项目运行时产物统一写入 `.superspecflow/`：

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

读取历史产物时采用新路径优先、旧路径 fallback；新写入不再推荐根目录旧路径。`.superspecflow/progress/` 和 `.superspecflow/verification/` 分别由 `progress-tracking` 与 `cross-agent-verification` 定义文件协议。

## Git 提交规范

commit 标题的类型与范围使用英文标识符，摘要和正文使用中文。

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

允许的英文类型：`feat / fix / docs / style / refactor / perf / test / build / ci / chore / revert / spec`。

英文范围使用 `<根模块>` 或 `<根模块>:<业务子模块>` 形式。根模块取自仓库根目录划分，例如 `skills`、`commands`、`agents`、`routing`、`templates`、`scripts`、`docs`、`openspec`、`examples`、`meta`。

禁止模糊提交标题，例如：

```text
WIP
update
fix bug
misc
changes
```

## 维护与验证

发布或同步前运行：

```bash
./scripts/validate-pack.sh
```

该脚本会检查命令集合、skill frontmatter、旧前缀残留、冒号文件名、已跟踪运行时产物、artifact path contract，以及 README / routing 与 `commands/` 的命令集合一致性。

测试目录使用 bats：

```bash
bats tests
```

如果本机没有 bats，可以至少运行 `./scripts/validate-pack.sh` 做包结构和文档契约验证。

## 设计来源

SuperSpecFlow 融合并适配了：

- OpenSpec：规格驱动变更。
- Superpowers：agentic engineering discipline。
- gstack：多角色评审与发布门禁。
- multica-ai/andrej-karpathy-skills：Think Before Coding、Simplicity First、Surgical Changes、Goal-Driven Execution。

`ssf-karpathy` 是适配到本工作流的行为层，不是原仓库逐字复制。
