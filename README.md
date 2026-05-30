# SuperSpecFlow

SuperSpecFlow 是一套面向 Claude Code / Codex CLI 的 AI 软件研发工作流包。它的目标不是让 AI 更快地堆代码，而是把一句自然语言需求变成一条可审计的 **SDD + TDD 交付链**：先判断请求类型，再形成 OpenSpec 变更合同，再按 Superpowers 执行纪律小步实现、审查、验收、发布、归档和复盘。

一句话概括：

> **OpenSpec 管“要交付什么”，Superpowers 管“怎么可靠执行”，SuperSpecFlow 管“什么时候进入哪个阶段，并把证据串起来”。**

最终效果是：用户可以用自然语言发起工作，也可以显式调用 `/ssf-*` 命令；agent 不会默认接管所有项目，而是在项目 opt-in 后按 SuperSpecFlow 的路由与阶段检查执行。

## 为什么值得用

- **SDD：Spec-Driven Development**。非平凡行为变更必须落到 OpenSpec change-id / Spec ID，需求、任务、实现、测试、commit、PR、回滚都能追踪到同一个 contract。
- **TDD：先失败测试，再最小实现**。`/ssf-build` 要把 OpenSpec tasks 转成 implementation plan，每个可测试任务优先写失败测试、记录 `Expected: FAIL`，再写最小实现并记录 `Expected: PASS`。
- **OpenSpec + Superpowers 不是简单拼接**。OpenSpec 合同层负责 proposal、specs、tasks、MUST NOT 和 archive；Superpowers 执行纪律层负责 brainstorming、writing-plans、TDD、review handling 和 verification-before-completion；SuperSpecFlow 路由与适配层把自然语言请求路由到正确阶段，并把每个阶段的证据连接起来。
- **Evidence-backed QA**。QA 不是凭感觉点页面，而是从 requirements、scenarios 和 MUST NOT 派生 acceptance、negative、risk、regression、Browser/MCP QA、Visual UI QA 和 blocked signoff。
- **可执行门禁**。关键门禁不只写在模板里：pack validation 会检查根入口薄化、change ledger、安装可移植性、runtime validators 和高风险发布字段；提交与 QA signoff 也有可复用 validator。
- **GitOps 可追踪交付**。分支、选择性暂存、中文 commit 正文、PR、rollback 和 release decision 都要关联 change-id、Spec ID 和验证证据，避免“代码改完了但没人说得清为什么能发”。

## 一条完整链路

```text
一句话需求
  → Intake Gate 判断请求类型和风险
  → /ssf-think 澄清目标、用户路径、non-goals 和成功指标
  → /ssf-spec 生成 OpenSpec proposal / specs / tasks / readiness review
  → /ssf-build 按 Spec ID 做 TDD、小步实现和 spec-to-code map
  → /ssf-review 检查 spec / code / test 同步和 Karpathy Diff Audit
  → /ssf-qa 生成验收矩阵、负向测试、风险矩阵和 QA evidence
  → /ssf-ship 汇总 rollback、monitoring、release blockers 和 ship decision
  → /ssf-git / /ssf-commit / /ssf-pr 写入可追踪 Git 记录
  → /ssf-archive / /ssf-retro 归档证据并复盘流程缺口
```

## 项目初衷

1. **防止一句话需求直接变成失控改动**：自然语言请求先经过 Intake Gate，区分纯问答、轻量任务、非平凡行为变更、高风险变更和 Git/QA/发布动作。
2. **让每个行为变更都能追踪**：非平凡变更必须落到 OpenSpec change-id / Spec ID，并在实现、测试、commit、PR、回滚说明之间保持映射。
3. **把优秀研发纪律变成 agent 可执行规则**：融合 OpenSpec 合同层、Superpowers 执行纪律层、SuperSpecFlow 路由与适配层、Karpathy 风格的 diff discipline，以及 GitOps 的分支、暂存、提交和 PR 门禁。

## 适合谁

- 想在真实项目里使用 AI coding agent，但需要可控流程、可追踪提交和发布门禁的团队。
- 同时使用 Claude Code 和 Codex CLI，希望两端共享一套研发规则的人。
- 想把需求、实现、测试、评审、QA、发布和复盘串成一个闭环的个人或小团队。

不适合的场景：

- 只想要一次性代码补全，不关心规格、测试、提交和回滚。
- 希望 agent 自动覆盖宿主项目已有 `AGENTS.md` / `CLAUDE.md` 的项目。SuperSpecFlow 的原则是宿主项目规则优先，自己只提供流程路由与阶段检查。

## 工作模型

完整流程是：

```text
Think → Spec → Build → Review → QA → Ship → Git/PR → Archive → Retro
```

对应五层约束：

| 风格 | 在本项目中的作用 |
|---|---|
| OpenSpec 合同层 | 用 change-id、Spec ID、proposal、specs、tasks 和 archive 记录变更合同 |
| Superpowers 执行纪律层 | 强制先理解、再计划、TDD、小步实现、验证后再宣称完成 |
| SuperSpecFlow 路由与适配层 | 把自然语言请求路由到合适的 OpenSpec contract 与 Superpowers 执行纪律组合，并连接阶段产物 |
| Karpathy | 编码前暴露假设，简单优先，外科手术式修改，目标驱动验证 |
| GitOps | 分支、暂存、commit、PR、rollback 与 change-id / Spec ID 对齐 |

这些来源不是作为外部运行时依赖被整体搬进项目，而是被拆成阶段能力：

- **OpenSpec 合同层** 提供变更合同：change-id、Spec ID、proposal、design、specs、tasks、scenarios、MUST NOT、archive。
- **Superpowers 执行纪律层** 提供执行纪律：先理解、再计划、优先 TDD、小步实现、验证后再宣称完成、接收 review 前先核验事实。
- **SuperSpecFlow 路由与适配层** 负责 glue / routing / adapter：把自然语言请求路由到合适的 OpenSpec contract 与 Superpowers 执行纪律组合，并连接 Think、Spec、Build、Review、QA、Ship、Git、Archive 和 Retro 的阶段产物。
- **Karpathy** 提供编码行为约束：暴露假设、寻找更简单方案、避免投机抽象、保持 surgical diff、把目标变成可验证结果。

各阶段使用的能力如下：

| 阶段 | OpenSpec 能力 | Superpowers 能力 | SuperSpecFlow 路由与适配职责 | Karpathy 能力 |
|---|---|---|---|---|
| Intake | 判断请求是否需要 change-id / Spec ID | 先分类、再行动，轻量任务不强行升级完整流程 | 路由到问答、轻量任务、OpenSpec、QA、Ship 或 Git 流程 | 选择最小流程，避免把小问题过度流程化 |
| Think | 产出可进入 proposal 的问题、目标、non-goals 和成功指标 | 先理解用户目的和约束，再提出方案 | 把产品判断适配成 OpenSpec proposal 输入 | 暴露假设，压缩 MVP，寻找更简单方案 |
| Spec | 生成 proposal、design、specs、tasks、scenarios、MUST NOT 和 Spec Readiness Review | Superpowers spec review：保留 Brainstorming Context、Assumption Audit、Alternatives Considered、Open Questions Disposition 和 reviewer evidence | 连接 brainstorm、assumptions、OpenSpec artifacts 和 readiness evidence | 防止范围膨胀，把每条要求收敛成可验证目标 |
| Build | 读取 OpenSpec change，只实现映射到 Spec ID 的任务，更新 tasks 和 spec-to-code map | Superpowers writing-plans：implementation plan、Bite-Sized Tasks、优先 failing tests、小步实现、Plan Review Loop、Execution Handoff、fresh verification | 把 OpenSpec tasks 适配到 writing-plans、TDD 和 spec-to-code map | Karpathy preflight、surgical changes、不做无关重构、不写投机抽象 |
| Review | 检查 spec / code / test 是否同步，确认行为改动都有 Spec ID | 接收 review 反馈前先验证事实，支持 cross-agent verification | 把 diff、OpenSpec、progress 和 evidence 路由到工程审查或交叉核验 | Karpathy Diff Audit，检查错误假设、过度设计、无关改动和不可验证目标 |
| QA | 从 requirements、scenarios、MUST NOT 生成 acceptance、negative、risk 和 regression 矩阵 | 用证据驱动验收，不只看 happy path | 把 OpenSpec requirements 适配成 QA 矩阵、执行计划和 signoff | 关注边界条件、残余风险和未验证假设 |
| Ship | 检查 OpenSpec tasks、QA signoff、rollback、monitoring 和 release blockers | 完成前必须有新鲜验证证据，不确定项必须标注 | 汇总 contract、QA evidence、rollback 和 monitoring 后给出 ship / no-ship | 确认可发布范围足够小，阻止含混风险被包装成完成态 |
| Git / PR | commit 和 PR 关联 change-id、Spec ID、验证方式和回滚说明 | 小步、可验证、可恢复的提交纪律 | 把 change-id、Spec ID、验证证据和回滚信息写入分支、暂存、commit 与 PR | 审查 staged diff 是否 surgical，拒绝无关文件和顺手重构 |
| Archive | 归档 change、决策、文档覆盖和最终产物索引 | 把上下文落盘，避免历史只留在聊天记录 | 把完成证据回写到 OpenSpec archive、decision ledger 和文档索引 | 记录实际范围，避免归档时扩大解释 |
| Retro | 对照 OpenSpec contract 回看流程缺口 | 把执行经验转成下一轮可操作改进 | 把 contract、evidence 和执行经验适配成可复用改进项 | 复盘是否存在错误假设、过度设计、非最小改动或验证不足 |

自然语言不会被简单关键词直接升级成完整流程。SuperSpecFlow 先做 Intake Gate：

| 请求类型 | 处理方式 |
|---|---|
| 纯问答 / 解释 | 直接回答，不启动完整流程 |
| 轻量任务 | 说明目标、影响范围、验证方式，小范围完成 |
| 非平凡行为变更 | 进入 Think / Spec，形成 change-id 和 Spec ID |
| 已有规格实现 | 进入 Build，按 OpenSpec tasks 执行 |
| Review / QA / Ship / Git | 进入对应阶段 |
| 高风险变更 | 强制 Spec、QA、Ship、Git/PR 门禁 |

## Workflow Scale 路线

`workflow-scale-architecture` 定义了两阶段增强路线：

1. `browser-mcp-qa-adapter`：先让 `/ssf-qa` 从文档 QA 扩展为 evidence-backed QA。它会把 acceptance matrix 中的 E2E / user journey 场景转成 `.superspecflow/qa/<change-id>/qa-execution-plan.md`，并在目标和工具可用时记录 `browser-run-report.md` 与 `qa-evidence/`。没有可运行目标或浏览器/MCP 工具不可用时，必须写 blocked signoff，不得声明自动化浏览器路径通过。
2. `parallel-worktree-spec-clusters`：再让大 change 拆成 parent change 和多个 Spec cluster。每个 cluster 可以在独立 worktree 中执行 build/review/QA/Git；parent change 通过 `.superspecflow/clusters/<parent-change>/integration-gate.md` 汇总 cluster QA evidence、review、commit 和跨 cluster 回归后才能进入 ship。

QA evidence 是后续 Review / Ship / Git / Archive 可引用的事实来源，但不替代 OpenSpec requirements 或 Spec ID。Worktree 只是执行隔离机制，不是发布边界。

`visual-ui-qa-adapter` 在 browser/MCP QA 之后补充视觉验收协议。它让 `/ssf-qa` 可以为 `platform: web | mini-program` 的 UI 还原、截图对比和视觉回归场景生成 `.superspecflow/qa/<change-id>/visual-execution-plan.md`，并记录 `.superspecflow/qa/<change-id>/visual-comparison-report.md` 与 `qa-evidence/visual/`。第一版只定义协议和门禁，不内置图片 diff 算法，不绑定具体小程序 runner。

## 路由契约

SuperSpecFlow 路由与适配层有明确输入输出，不是关键词触发器，也不是自有角色框架。

- **路由输入**：用户自然语言、显式 `/ssf-*` 命令、是否已有 change-id / Spec ID、宿主项目上下文、风险等级、可用 evidence 和当前 Git / runtime 状态。
- **路由输出**：请求分类、下一阶段（问答、轻量任务、Think、Spec、Build、Review、QA、Ship、Git、Archive、Retro）、是否需要 OpenSpec contract、需要使用的 Superpowers 执行纪律、应写入或读取的阶段产物。
- **执行纪律选择记录**：当任务进入正式 change，所选 Superpowers 纪律必须落到对应产物中，例如 brainstorming context、implementation plan、TDD 证据、review notes、verification evidence、qa signoff、spec-to-code map 或 progress handoff；这些记录引用 OpenSpec change-id / Spec ID，但不替代 OpenSpec requirements。

## 版本策略

SuperSpecFlow 使用 SemVer。当前包版本记录在 `VERSION`，发布记录写入 `CHANGELOG.md`。

- Patch，例如 `1.1.1`：缺陷修复、门禁补强、文档或测试修正。
- Minor，例如 `1.2.0`：新增兼容命令、模板、流程或安装能力。
- Major，例如 `2.0.0`：破坏现有命令语义、产物路径或安装接入方式。

查看当前版本：

```bash
./update.sh --version
```

## 快速接入

SuperSpecFlow 同时支持 Claude Code 和 Codex CLI。默认会同时准备两个宿主的 global wrapper；只装其中一个用 `--claude-only` 或 `--codex-only` 收窄。

全局安装脚本会生成 wrapper 和同步能力文件；如果 `~/.claude/CLAUDE.md` 或 `~/.codex/AGENTS.md` 不存在，脚本会创建并写入 include 行。如果这些全局指令文件已存在，脚本只打印应手动追加的 include 行，不擅自改写用户已有规则。

安装前确认：

- 本机需要 `git` 和 `bash`；使用一句话命令时还需要 `curl`。
- 发布或同步前建议安装 `bats` 以运行完整测试；没有 `bats` 时仍可运行 `./scripts/validate-pack.sh`。
- `rg` 是可选加速工具；缺失时验证脚本会退化到 `grep`。
- `bootstrap.sh` 会把 `~/.superspecflow/` 更新到官方 `master`，已存在 checkout 时会执行 `fetch + reset --hard origin/master`。不要在该安装目录保存未提交的个人改动。

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
3. 校验：grep "SuperSpecFlow" 对应的 ~/.claude/CLAUDE.md 或 ~/.codex/AGENTS.md，确认 include 行已写入；如果全局指令文件已存在且脚本提示要手动追加，把那一行原文展示给我。
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

### 平台差异速查

| 宿主 | 全局安装同步内容 | 说明 |
|---|---|---|
| Claude Code | `~/.claude/skills/`、`~/.claude/agents/`、`~/.claude/commands/`、`~/.claude/superspecflow/CLAUDE.global.md` | 支持显式 `/ssf-*` 命令文件；可选 SessionStart hook 用于更快检测项目 opt-in。 |
| Codex CLI | `~/.codex/skills/`、`~/.codex/superspecflow/AGENTS.global.md` | 主要依赖 `AGENTS.md` routing 和 skills；显式 slash command 是否注册取决于当前 Codex 运行环境。 |
| 两端共同点 | global wrapper + 项目 `.superspecflow/enabled` sentinel | 全局安装只提供能力；项目 opt-in 后才接管自然语言 Intake Gate。 |

详细安装、兼容路径和卸载方式见 [docs/installation.md](docs/installation.md)。Claude Code / Codex 差异见 [docs/compatibility.md](docs/compatibility.md)。

## 卸载

与安装一对一对称，三种方式任选其一。卸载只移除 SuperSpecFlow 自己写入的 include 行、generated wrappers 和能力文件，绝不改动用户在 `CLAUDE.md` / `AGENTS.md` 里的其他内容。

### 方式 1：让 AI 帮你卸（推荐）

打开你的 Claude Code 或 Codex CLI，把下面整段粘贴进去：

```text
请把 SuperSpecFlow 从本机卸载：

1. 如果 ~/.superspecflow/scripts/uninstall-global.sh 存在，执行：
   ~/.superspecflow/scripts/uninstall-global.sh --both --purge
   该脚本会精确移除 ~/.claude/CLAUDE.md 和 ~/.codex/AGENTS.md 里的 SuperSpecFlow include 行（其他内容保留），清理 generated wrappers 与 manifest 中记录且未被用户修改的能力文件，并删除 ~/.superspecflow/ 目录。
2. 如果 ~/.superspecflow/ 不存在，但 ~/.claude/CLAUDE.md 或 ~/.codex/AGENTS.md 里还有 SuperSpecFlow include 行：
   找出形如 "@~/.claude/superspecflow/CLAUDE.global.md"、"@~/.codex/superspecflow/AGENTS.global.md" 或旧版 "@/path/to/SuperSpecFlow/routing/*.global.md" 的行，把那一行（且只有那一行）删除。如果文件因此变空，把文件本身也删除。
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
# 1. 找出 include 行（形如 @~/.claude/superspecflow/CLAUDE.global.md）
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
| QA | `acceptance-matrix.md`、`negative-test-matrix.md`、`risk-matrix.md`、`regression-checklist.md`、`exploratory-test-notes.md`、`qa-signoff.md`、`qa-execution-plan.md`、`browser-run-report.md`、`visual-execution-plan.md`、`visual-comparison-report.md` |
| Release | `release-checklist.md`、`rollback-plan.md`、`monitoring-plan.md`、`ship-decision.md`、`migration-plan.md`、`pr-description.md` |
| Git / PR | `git-checklist.md`、`git-status-audit.md`、`commit-message.md`、`commit-gate.md`、`git-pr-gate.md`、`git-pr-archive.md`、`git-hooks/commit-msg` |
| Archive / Retro | `archive-summary.md`、`documentation-coverage.md`、`retro.md` |
| Progress / Verification | `progress-state.json`、`progress-timeline.md`、`progress-verification.md`、`progress-handoff.md`、`verification-request.md`、`verification-evidence.md`、`verification-reviewer-notes.md`、`verification-signoff.md` |
| Cluster | `cluster-plan.md`、`cluster-status.md`、`integration-gate.md` |

## 目录结构

| 路径 | 说明 |
|---|---|
| `commands/` | 显式命令入口，一条命令一个 Markdown 文件 |
| `skills/` | 阶段能力定义，供 Claude Code / Codex 读取执行 |
| `agents/` | 阶段视角和专用 persona，用于产品、规格、工程、审查、QA、发布和 Git 工作 |
| `routing/` | 全局薄壳和默认完整路由 |
| `templates/` | 各阶段产物模板和集成入口片段 |
| `scripts/` | 安装、初始化、验证和 hook 脚本 |
| `docs/` | 安装、兼容性、分支策略等用户文档 |
| `openspec/changes/` | 本仓库自身行为规则变更的 OpenSpec contract |
| `openspec/change-ledger.md` | 本仓库 OpenSpec changes 的 committable 状态索引，记录 active / complete / archived / superseded 和 evidence gaps |
| `engineering/<change-id>/` | 本仓库包源码层工程交付物，例如 spec-to-code map |
| `tests/` | bats 测试，覆盖安装、初始化、artifact path、progress、verification 等契约 |
| `examples/` | 示例变更流程，展示从 OpenSpec 到 QA、release、archive、retro 的产物 |

## 文档地图

| 文档 | 用途 |
|---|---|
| [docs/installation.md](docs/installation.md) | 详细安装、项目 opt-in、兼容接入和卸载说明 |
| [docs/compatibility.md](docs/compatibility.md) | Claude Code / Codex CLI 差异、命令可用性和包验证说明 |
| [docs/branching-strategy.md](docs/branching-strategy.md) | Git Flow、`ssf/<change-id>-<slug>` 分支命名和发布分支规则 |
| [CHANGELOG.md](CHANGELOG.md) | 当前版本的新增、变更和移除记录 |
| [examples/add-membership-renewal-reminder/README.md](examples/add-membership-renewal-reminder/README.md) | 端到端示例 change 的 OpenSpec、工程、QA、发布、归档和复盘产物 |
| [NOTICE.md](NOTICE.md) | 设计来源和第三方工作流致谢 |

## 版本控制边界

SuperSpecFlow 仓库提交工作流包源码和 OpenSpec 变更契约：`routing/`、`skills/`、`commands/`、`agents/`、`templates/`、`scripts/`、用户文档、测试、示例和 `openspec/`。其中 `openspec/` 是本仓库行为规则变更的 change contract，不能被当作运行时产物忽略。

不要提交本地 workflow 运行时、安装副本或缓存产物，例如 `superpowers/`、`docs/superpowers/`、`.superspecflow/`、`.claude/`、`.codex/` 和 `.DS_Store`。

宿主项目运行时产物统一写入 `.superspecflow/`：

| 产物 | 宿主项目运行时路径 |
|---|---|
| Engineering artifacts | `.superspecflow/engineering/<change-id>/` |
| Intake artifacts | `.superspecflow/intake/<change-id>/` |
| QA artifacts | `.superspecflow/qa/<change-id>/` |
| Release artifacts | `.superspecflow/release/<change-id>/` |
| Archive artifacts | `.superspecflow/archive/<change-id>/` |
| Retro artifacts | `.superspecflow/retro/<change-id>/` |
| Decision records | `.superspecflow/decisions/` |
| Spec-to-code maps | `.superspecflow/maps/<change-id>/` |
| Review artifacts | `.superspecflow/reviews/<change-id>/` |
| Karpathy audits | `.superspecflow/karpathy/<change-id>/` |
| Cluster artifacts | `.superspecflow/clusters/<parent-change>/` |

`/ssf-init` 会创建常用运行时目录：`intake/`、`engineering/`、`qa/`、`release/`、`archive/`、`retro/`、`decisions/`、`maps/`、`reviews/`、`karpathy/`、`progress/` 和 `verification/`。`.superspecflow/clusters/` 由 Spec cluster 流程按需创建，不是普通项目 opt-in 的必备目录。

读取历史产物时采用新路径优先、旧路径 fallback；新写入不再推荐根目录旧路径。`.superspecflow/progress/`、`.superspecflow/verification/` 和 `.superspecflow/clusters/` 分别由 `progress-tracking`、`cross-agent-verification` 和 `parallel-worktree-spec-clusters` 定义文件协议。

SuperSpecFlow 包源码仓库不提交 `.superspecflow/` 运行时实例；本仓库自身的 durable 状态摘要写入 `openspec/change-ledger.md`，具体实现映射继续写入 `engineering/<change-id>/`。

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

新增的 runtime gate scripts 可单独运行：

```bash
./scripts/validate-commit-message.sh <commit-message-file>
./scripts/validate-qa-signoff.sh .superspecflow/qa/<change-id>/qa-signoff.md
./scripts/validate-change-ledger.sh
```

测试目录使用 bats：

```bash
./scripts/test.sh
```

如果本机没有 bats，可以至少运行 `./scripts/validate-pack.sh` 做包结构和文档契约验证。

## 设计来源

SuperSpecFlow 融合并适配了：

- OpenSpec：规格驱动变更。
- Superpowers：agentic engineering discipline。
- gstack：多角色评审与发布门禁。
- multica-ai/andrej-karpathy-skills：Think Before Coding、Simplicity First、Surgical Changes、Goal-Driven Execution。

`ssf-karpathy` 是适配到本工作流的行为层，不是原仓库逐字复制。

## License

SuperSpecFlow 使用 MIT License，完整文本见 [LICENSE](LICENSE)。设计来源和致谢见 [NOTICE.md](NOTICE.md)。
