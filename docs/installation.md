# SuperSpecFlow Installation Guide

本文面向把 SuperSpecFlow 接入已有项目的用户。目标是启用完整 AI 软件研发工作流，同时不覆盖宿主项目已有 `AGENTS.md`、`CLAUDE.md` 或业务规则。

## 0. 安装前确认

先确认三件事：

1. 使用环境：Claude Code、Codex CLI，或两者都用。
2. 安装范围：全局安装，还是只给某个项目安装。
3. 宿主项目是否已有 `AGENTS.md` / `CLAUDE.md`。

如果宿主项目已有指令文件，不要覆盖，也不要复制大段路由内容。推荐通过软连接入 SuperSpecFlow，并在宿主项目指令文件中只保留极薄入口。

## 1. 第三方工作流关系

SuperSpecFlow 集成的是多套研发方法，不是把它们都作为应用运行时依赖安装到宿主项目。

| 来源 | 在 SuperSpecFlow 中的作用 | 用户安装时怎么处理 |
|---|---|---|
| OpenSpec | change-id、proposal、specs、tasks、archive 的规格驱动结构 | 不要求安装外部运行时；在宿主项目中按需生成 `openspec/changes/<change-id>/` |
| Superpowers | 先理解、再计划、TDD、小步实现、验证、处理 review 先验证 | 可选增强；如果用户已安装 Superpowers，SuperSpecFlow 与其纪律兼容；未安装也可使用本包内 `ssf-*` skills |
| gstack | 产品、设计、工程、QA、安全、发布多角色门禁 | 通过 `agents/` 和 `skills/` 表达，不需要额外依赖 |
| Karpathy skills | 编码前暴露假设、简单优先、外科手术式修改、目标驱动验证 | 已适配为 `skills/ssf-karpathy`，不是原仓库逐字复制 |
| GitOps | 分支、暂存、commit（英文类型 + 中文正文）、PR、回滚与 Spec ID 对齐 | 使用宿主项目自己的 Git；可选安装 commit hook |

## 2. 版本控制边界

SuperSpecFlow 仓库自身只提交工作流包源码和 OpenSpec 变更契约。`openspec/` 是本仓库行为规则变更的可追踪 contract，应随对应 change-id 提交；不要把它和运行时产物一起忽略。

不要在 SuperSpecFlow 仓库提交本地 workflow 运行时、安装副本或缓存产物，例如 `superpowers/`、`.superspecflow/`、`.claude/`、`.codex/` 和 `.DS_Store`。这些产物可能由外部工具、本机安装或 agent 会话生成，应留在本地或重新生成。

SuperSpecFlow 本仓库的 `engineering/<change-id>/` 是包源码层可提交工程交付目录，不属于宿主项目运行时产物。宿主项目运行时产物使用 `.superspecflow/<stage>/` 命名空间，读取时新路径优先、旧路径 fallback，新写入不再推荐根目录旧路径。

宿主业务项目的规则不同：如果宿主项目采用 OpenSpec 管理需求，其项目内 `openspec/` 应正常提交；如果团队选择 repo 内 opt-in，`.superspecflow/` 中的 routing 接入文件是否提交由宿主项目约定决定，但不要提交本机缓存、日志、工具安装副本或外部 `superpowers/` 运行产物。

## 3. 推荐：方案 C 零侵入接入

方案 C 让宿主项目的 `CLAUDE.md` / `AGENTS.md` 零改动即可启用 SuperSpecFlow。一次性全局安装，按项目 opt-in。

### 3.1 全局安装一次

在 SuperSpecFlow 仓库中执行：

```bash
./scripts/install-global.sh
```

脚本会：

- 检测 `~/.claude/CLAUDE.md`：不存在则创建并写入 `@<pack>/routing/CLAUDE.global.md`；存在则只打印应追加的行，不擅自改写。
- 同样规则处理 `~/.codex/AGENTS.md`。
- 询问是否启用 Claude Code SessionStart hook（推荐）。同意后打印应合并到 `~/.claude/settings.json` 的官方 schema JSON 片段，不擅自改写。

### 3.2 给某个项目 opt-in

进入宿主项目根目录，执行：

```text
/ssf-init
```

或等价的：

```bash
bash <pack>/scripts/_ssf_init_apply.sh
```

会创建：

```text
.superspecflow/
├── enabled                 # sentinel，存在即 opt-in
├── engineering/            # implementation plan、dev handoff
├── qa/                     # acceptance、negative、risk、signoff
├── release/                # release checklist、rollback、monitoring、PR 描述
├── archive/                # archive summary、documentation coverage
├── retro/                  # /ssf-retro 产物
├── decisions/              # /ssf-decision 产物
├── maps/                   # spec-to-code-map.md
├── reviews/                # /ssf-review 报告
├── karpathy/               # /ssf-karpathy 报告
├── progress/               # 占位，由 progress-tracking change 定义
└── verification/           # 占位，由 cross-agent-verification change 定义
```

`/ssf-init` **不**修改宿主项目的 `CLAUDE.md` / `AGENTS.md`。

### 3.3 项目级 routing 覆盖（可选）

如果某个项目想覆盖全局默认 routing，可在该项目里手动创建：

```text
.superspecflow/CLAUDE.routing.md
.superspecflow/AGENTS.routing.md
```

它们的内容会替代全局 routing 主体。默认不需要这两个文件。

### 3.4 工作原理

- 全局 routing 薄壳 `routing/CLAUDE.global.md` 在会话启动时执行 opt-in 自检测：
  - 优先读取 Claude Code SessionStart hook 注入的 `<ssf-status>` 标签（C3 加成）。
  - 否则在会话内执行一次 Bash：`test -f .superspecflow/enabled`（C1 兜底）。
- 状态 = enabled：启用 Intake Gate。
- 状态 = disabled：不接管自然语言，但 `/ssf-*` 显式命令始终可用。

## 4. 兼容方案：项目软连接入

> 老用户兼容路径。新用户优先使用上一节方案 C。

软连安装让宿主项目引用 SuperSpecFlow 的集中路由和能力文件。升级 SuperSpecFlow 后，宿主项目不需要手动同步大段文本。

在 SuperSpecFlow 仓库中执行：

```bash
./scripts/install-project-symlinks.sh <project>
```

该脚本会在宿主项目中创建：

```text
.superspecflow/
  AGENTS.routing.md -> <SuperSpecFlow>/routing/AGENTS.routing.md
  CLAUDE.routing.md -> <SuperSpecFlow>/routing/CLAUDE.routing.md
  templates -> <SuperSpecFlow>/templates
.claude/
  agents/* -> <SuperSpecFlow>/agents/*
  commands/ssf-*.md -> <SuperSpecFlow>/commands/ssf-*.md
  skills/ssf-* -> <SuperSpecFlow>/skills/ssf-*
```

然后在宿主项目已有 `AGENTS.md` / `CLAUDE.md` 中只保留极薄入口。不要复制完整 routing 文件。

`AGENTS.md` 示例：

```markdown
@./.superspecflow/AGENTS.routing.md
```

`CLAUDE.md` 示例：

```markdown
@./.superspecflow/CLAUDE.routing.md
```

这种方式仍会修改宿主项目指令文件，但只增加一行 include，不复制 SuperSpecFlow 规则正文。如果当前环境不支持 `@` include，再使用 `templates/integration/*.snippet.md` 中的极薄文字入口作为 fallback。

也可以在支持 slash command 的环境中，在宿主项目里执行：

```text
/ssf-init
```

`/ssf-init` 是项目初始化动作：它创建 `.superspecflow/enabled` sentinel 和标准运行产物子目录，不修改宿主项目指令文件。其他 `/ssf-*` 命令只是一次性调用，不会自动创建 `.superspecflow/`。

## 5. Claude Code 安装

### 5.1 项目级安装

优先使用第 4 节的软连脚本。

如果团队不允许 symlink，可以复制能力文件，但仍不要覆盖宿主项目指令文件：

```bash
mkdir -p <project>/.claude
cp -R agents commands skills <project>/.claude/
cp -R routing templates <project>/.superspecflow/
```

然后在宿主项目 `AGENTS.md` / `CLAUDE.md` 中加入极薄入口，指向 `.superspecflow/*.routing.md`。

不要执行覆盖式命令，例如把 SuperSpecFlow 根目录的 `AGENTS.md` 或 `CLAUDE.md` 直接复制到宿主项目根目录。

### 5.2 全局安装

```bash
./update.sh
```

全局安装默认只提供 skills / commands / agents 能力，不接管所有项目的自然语言。项目只有在存在 `.superspecflow/` 或显式 `@./.superspecflow/*.routing.md` include 时，才启用 SuperSpecFlow Intake Gate。

如果全局安装时也要初始化某个项目的自然语言路由，显式打开开关：

```bash
./update.sh --enable-natural-language <project>
```

该选项会在完成全局安装后调用项目初始化流程，为指定项目创建 `.superspecflow/` 软链，但仍不会覆盖宿主项目 `AGENTS.md` 或 `CLAUDE.md`。

## 6. Codex CLI 安装

推荐全局安装 skills：

```bash
mkdir -p ~/.codex/skills
cp -R skills/* ~/.codex/skills/
```

然后在宿主项目中软连 routing 文件：

```bash
mkdir -p <project>/.superspecflow
ln -sfn <SuperSpecFlow>/routing/AGENTS.routing.md <project>/.superspecflow/AGENTS.routing.md
ln -sfn <SuperSpecFlow>/templates <project>/.superspecflow/templates
```

再在宿主项目 `AGENTS.md` 中加入 `@./.superspecflow/AGENTS.routing.md`。如果宿主项目没有 `AGENTS.md`，可以新建一个，但内容应包含宿主项目自身约束和该 include。不要把 SuperSpecFlow 仓库根目录的 `AGENTS.md` 当作宿主项目完整替代品。

## 7. 可选安装项

### 7.1 commit message hook

在宿主项目中执行：

```bash
cp templates/git-hooks/commit-msg .git/hooks/commit-msg
chmod +x .git/hooks/commit-msg
```

该 hook 只检查 commit message 是否符合 `<英文类型>(<英文范围>): <中文摘要>` 标题规范与中文正文底线，不替代 `ssf-git` 的 change-id / Spec ID / 验证证据门禁。

### 7.2 Superpowers

如果用户希望同时使用 Superpowers 原生 skills，可按 Superpowers 自身说明安装。SuperSpecFlow 不假设它一定存在；本包已经把必要纪律体现在 `ssf-think`、`ssf-build`、`ssf-review`、`ssf-karpathy` 等 skills 中。

### 7.3 OpenSpec 目录

宿主项目第一次进入 `ssf-spec` 时，可以创建：

```text
openspec/changes/<change-id>/
  proposal.md
  design.md
  tasks.md
  specs/
    <domain>.md
```

如果宿主项目已有 OpenSpec 目录，沿用现有目录结构，不要移动或重写已有 change。

## 8. 安装后烟测

### 8.1 软连检查

在宿主项目中执行：

```bash
ls -l .superspecflow
ls -l .claude/skills | grep ssf-
```

期望：`.superspecflow/*.routing.md`、`.superspecflow/templates` 和 `.claude/skills/ssf-*` 指向 SuperSpecFlow 仓库。

### 8.2 Intake Gate

输入：

```text
解释一下这个函数做什么
```

期望：进入 Intake Gate 后判定为纯问答 / 解释，不启动完整流程。

输入：

```text
我需要做一个登录
```

期望：进入 Intake Gate，判定为高风险非平凡行为变更，然后进入 `ssf-think`，不得直接写代码。

### 8.3 显式命令

输入：

```text
/ssf-think 会员续费提醒
```

期望：进入产品思考阶段，输出问题、用户路径、non-goals、success metrics，并准备 OpenSpec proposal 输入。

### 8.4 Pack 自检

在 SuperSpecFlow 仓库中运行：

```bash
./scripts/validate-pack.sh
```

期望：检查通过，且不会出现旧冒号命令、`hw` 旧前缀、冒号文件名或覆盖宿主指令文件的安装说明。

### 8.5 方案 C 烟测

```bash
# 在临时项目里验证 opt-in 信号
TMP=$(mktemp -d)
cd "$TMP"
bash <pack>/scripts/_ssf_init_apply.sh
test -f .superspecflow/enabled && echo "OK: opt-in 信号已写入"

# 验证 hook 脚本（输出符合 Claude Code SessionStart hook JSON 协议）
bash <pack>/scripts/hooks/session-start-detect.sh
# 期望输出（单行）: {"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"<ssf-status>enabled</ssf-status>"}}

cd /tmp
bash <pack>/scripts/hooks/session-start-detect.sh
# 期望输出（单行）: {"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"<ssf-status>disabled</ssf-status>"}}
```

## 9. 升级流程

升级 SuperSpecFlow 时：

1. 更新 SuperSpecFlow 仓库。
2. 确认宿主项目 `.superspecflow/*.routing.md` 仍指向正确仓库路径。
3. 如宿主项目移动目录，重新运行 `./scripts/install-project-symlinks.sh <project>`。
4. 运行宿主项目自己的测试和 SuperSpecFlow pack 自检。
5. 不自动覆盖宿主项目已有 `AGENTS.md` / `CLAUDE.md`。

## 10. 卸载流程

项目级卸载：

```bash
rm -f <project>/.superspecflow/AGENTS.routing.md
rm -f <project>/.superspecflow/CLAUDE.routing.md
rm -f <project>/.superspecflow/templates
rm -f <project>/.claude/agents/product-strategist.md
rm -f <project>/.claude/agents/spec-architect.md
rm -f <project>/.claude/agents/implementation-engineer.md
rm -f <project>/.claude/agents/code-reviewer.md
rm -f <project>/.claude/agents/qa-gatekeeper.md
rm -f <project>/.claude/agents/release-manager.md
rm -f <project>/.claude/agents/git-steward.md
rm -f <project>/.claude/commands/ssf-*.md
rm -f <project>/.claude/skills/ssf-*
```

然后从宿主项目 `AGENTS.md` / `CLAUDE.md` 中移除 `@./.superspecflow/*.routing.md` include 或 fallback 极薄入口。

全局卸载时，从 `~/.claude/` 或 `~/.codex/skills/` 删除对应 `ssf-*` skills 和 commands。
