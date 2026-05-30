# SuperSpecFlow Installation Guide

本文面向把 SuperSpecFlow 接入已有项目的用户。目标是启用完整 AI 软件研发工作流，同时不覆盖宿主项目已有 `AGENTS.md`、`CLAUDE.md` 或业务规则。

## 0. 安装前确认

先确认三件事：

1. 使用环境：Claude Code、Codex CLI，或两者都用。
2. 安装范围：全局安装，还是只给某个项目安装。
3. 宿主项目是否已有 `AGENTS.md` / `CLAUDE.md`。

如果宿主项目已有指令文件，不要覆盖，也不要复制大段路由内容。推荐使用方案 C：全局安装 SuperSpecFlow 能力和 global wrapper，再由项目内 `/ssf-init` 创建 `.superspecflow/enabled` sentinel。

## 1. 第三方工作流关系

SuperSpecFlow 集成的是多套研发方法，不是把它们都作为应用运行时依赖安装到宿主项目。

| 来源 | 在 SuperSpecFlow 中的作用 | 用户安装时怎么处理 |
|---|---|---|
| OpenSpec 合同层 | change-id、proposal、specs、tasks、archive 的规格驱动结构 | 不要求安装外部运行时；在宿主项目中按需生成 `openspec/changes/<change-id>/` |
| Superpowers 执行纪律层 | 先理解、再计划、TDD、小步实现、验证、处理 review 先验证 | 可选增强；如果用户已安装 Superpowers，SuperSpecFlow 与其纪律兼容；未安装也可使用本包内 `ssf-*` skills |
| SuperSpecFlow 路由与适配层 | 把自然语言请求路由到 OpenSpec contract 与 Superpowers 执行纪律组合，并连接阶段产物 | 安装 routing、skills、agents、commands 和 templates；不接管宿主项目业务规则 |
| Karpathy skills | 编码前暴露假设、简单优先、外科手术式修改、目标驱动验证 | 已适配为 `skills/ssf-karpathy`，不是原仓库逐字复制 |
| GitOps | 分支、暂存、commit（英文类型 + 中文正文）、PR、回滚与 Spec ID 对齐 | 使用宿主项目自己的 Git；可选安装 commit hook |

## 2. 版本控制边界

SuperSpecFlow 仓库自身只提交工作流包源码和 OpenSpec 变更契约。`openspec/` 是本仓库行为规则变更的可追踪 contract，应随对应 change-id 提交；不要把它和运行时产物一起忽略。

不要在 SuperSpecFlow 仓库提交本地 workflow 运行时、安装副本或缓存产物，例如 `superpowers/`、`docs/superpowers/`、`.superspecflow/`、`.claude/`、`.codex/` 和 `.DS_Store`。这些产物可能由外部工具、本机安装或 agent 会话生成，应留在本地或重新生成。

SuperSpecFlow 本仓库的 `engineering/<change-id>/` 是包源码层可提交工程交付目录，不属于宿主项目运行时产物。宿主项目运行时产物使用 `.superspecflow/<stage>/` 命名空间，读取时新路径优先、旧路径 fallback，新写入不再推荐根目录旧路径。

宿主业务项目的规则不同：如果宿主项目采用 OpenSpec 管理需求，其项目内 `openspec/` 应正常提交；如果团队选择 repo 内 opt-in，`.superspecflow/` 中的 routing 接入文件是否提交由宿主项目约定决定，但不要提交本机缓存、日志、工具安装副本或外部 `superpowers/` / `docs/superpowers/` 运行产物。

## 3. 推荐：方案 C 零侵入接入

方案 C 让宿主项目的 `CLAUDE.md` / `AGENTS.md` 零改动即可启用 SuperSpecFlow。一次性全局安装，按项目 opt-in。

### 3.1 全局安装一次

提供三种入口，按推荐顺序排列。无论用哪种方式，最终都执行 `scripts/install-global.sh`：Claude 侧同步 `~/.claude/{skills,agents,commands}` 和 global wrapper；Codex 侧同步 `~/.codex/skills` 和 global wrapper；然后把 wrapper include 写入 `~/.claude/CLAUDE.md` 和/或 `~/.codex/AGENTS.md`。

#### 方式 1：让 AI 帮你装（推荐）

打开 Claude Code 或 Codex CLI，把下面整段中文粘贴进去：

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

#### 方式 2：一句话命令

```bash
# 两个 CLI 都装（默认）
curl -fsSL https://raw.githubusercontent.com/HobaoKing/SuperSpecFlow/master/scripts/bootstrap.sh | bash

# 只装 Claude Code
curl -fsSL https://raw.githubusercontent.com/HobaoKing/SuperSpecFlow/master/scripts/bootstrap.sh | bash -s -- --claude-only

# 只装 Codex CLI
curl -fsSL https://raw.githubusercontent.com/HobaoKing/SuperSpecFlow/master/scripts/bootstrap.sh | bash -s -- --codex-only
```

`bootstrap.sh` 会把仓库 clone 到 `~/.superspecflow/`（可用环境变量 `SUPERSPECFLOW_HOME` 覆盖），然后调用 `install-global.sh` 并透传参数。已存在 checkout 时会 `fetch + reset --hard origin/master`。一句话命令的 raw URL 始终指向 `master` 分支：开发分支上的改动合入 master 后才会被一句话安装拿到。

防御性行为：

- `~/.superspecflow/` 已存在但不是 git 仓库 → 报错并要求手动处理，不删除。
- `~/.superspecflow/` 的 `origin` 与官方 URL 不一致 → 报错并要求手动处理，不改 remote。
- 未安装 `git` → 直接报错退出。

#### 方式 3：手动 clone

```bash
git clone https://github.com/HobaoKing/SuperSpecFlow.git ~/.superspecflow
~/.superspecflow/scripts/install-global.sh                  # 默认 --both
~/.superspecflow/scripts/install-global.sh --claude-only    # 只装 Claude Code
~/.superspecflow/scripts/install-global.sh --codex-only     # 只装 Codex CLI
```

也可以 clone 到任意自选目录运行 `scripts/install-global.sh`，include 行使用绝对路径，不强制路径必须是 `~/.superspecflow/`。

#### 脚本行为

`install-global.sh` 会：

- 根据 `--claude-only` / `--codex-only` / `--both`（默认）决定写哪些宿主。`--claude-only` 与 `--codex-only` 互斥。
- Claude 侧同步 `skills/`、`agents/`、`commands/` 到 `~/.claude/`。
- Codex 侧同步 `skills/` 到 `~/.codex/skills/`。
- 生成不含 `<repo>` 占位符的 global wrapper：`~/.claude/superspecflow/CLAUDE.global.md` 和 `~/.codex/superspecflow/AGENTS.global.md`。
- 写入 pack root 元数据：`~/.claude/superspecflow/pack-root` 和 `~/.codex/superspecflow/pack-root`，供已安装的 `/ssf-init` 确定性定位当前 SuperSpecFlow 包。
- 检测 `~/.claude/CLAUDE.md`：不存在则创建并写入 wrapper include；存在则只打印应追加的行，不擅自改写。
- 同样规则处理 `~/.codex/AGENTS.md`。
- 仅在写入 Claude 一侧时，打印 Claude Code SessionStart hook 的可选 JSON 片段（建议手动合并到 `~/.claude/settings.json`）。`--no-hook` 跳过该提示。脚本不擅自改写 `settings.json`。

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
├── intake/                 # intake-gate.md
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

## 4. 兼容路径索引

新用户优先使用第 3 节方案 C：全局安装 + 项目 `/ssf-init`，不修改宿主项目 `AGENTS.md` / `CLAUDE.md`。

旧版项目软连接入仍受支持，但只作为兼容路径保留。需要继续维护旧项目时，使用附录 A 的 `install-project-symlinks.sh` 流程；新项目不要再手工 `ln -sfn` routing 文件。

如果当前环境不支持 `@` include，使用 `templates/integration/*.snippet.md` 的极薄文字入口作为 fallback，不要复制完整 routing 正文。

## 5. Claude Code 安装

### 5.1 项目级安装

优先使用第 3 节方案 C 的全局安装与项目 `/ssf-init`。旧项目如需保留软连接入，见附录 A。

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

全局安装默认只提供能力文件和 global wrapper，不接管所有项目的自然语言。项目只有在存在 `.superspecflow/enabled` 或显式 routing include 时，才启用 SuperSpecFlow Intake Gate。

查看当前工具包版本：

```bash
./update.sh --version
```

如果全局安装时也要初始化某个项目的自然语言路由，显式打开开关：

```bash
./update.sh --enable-natural-language <project>
```

该选项会在完成全局安装后调用项目初始化流程，为指定项目创建 `.superspecflow/enabled` sentinel 和标准运行产物目录，但仍不会覆盖宿主项目 `AGENTS.md` 或 `CLAUDE.md`。

## 6. Codex CLI 安装

推荐使用全局安装脚本同步 Codex skills 与 wrapper：

```bash
./scripts/install-global.sh --codex-only
```

然后进入宿主项目执行：

```text
/ssf-init
```

项目级软连 routing 只作为旧项目兼容路径保留，见附录 A。不要把 SuperSpecFlow 仓库根目录的 `AGENTS.md` 当作宿主项目完整替代品。

## 7. 可选安装项

### 7.1 commit message hook

在宿主项目中执行：

```bash
cp templates/git-hooks/commit-msg .git/hooks/commit-msg
chmod +x .git/hooks/commit-msg
```

该 hook 只检查 commit message 是否符合 `<英文类型>(<英文范围>): <中文摘要>` 标题规范与中文正文底线，不替代 `ssf-git` 的 change-id / Spec ID / 验证证据门禁。

### 7.2 Superpowers

如果用户希望同时使用 Superpowers 原生 skills，可按 Superpowers 自身说明安装。SuperSpecFlow 不假设它一定存在；本包已经把必要执行纪律体现在 `ssf-think`、`ssf-build`、`ssf-review`、`ssf-karpathy` 等 skills 中。

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

### 8.1 Zero-touch 检查

在宿主项目中执行：

```bash
test -f .superspecflow/enabled && echo enabled
ls -d .superspecflow/{intake,engineering,qa,release,archive,retro,decisions,maps,reviews,karpathy,progress,verification}
```

期望：项目 opt-in sentinel 和标准运行产物目录存在，且宿主 `AGENTS.md` / `CLAUDE.md` 未被修改。

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
2. 重新运行 `scripts/install-global.sh`，刷新 global wrapper 和能力文件。
3. 确认宿主项目仍存在 `.superspecflow/enabled`；软连兼容路径用户再确认 `.superspecflow/*.routing.md` 指向正确仓库路径。
4. 运行宿主项目自己的测试和 SuperSpecFlow pack 自检。
5. 不自动覆盖宿主项目已有 `AGENTS.md` / `CLAUDE.md`。

## 10. 卸载流程

与第 3.1 节安装一对一对称，三种方式任选其一。三种方式都只移除 SuperSpecFlow 自己写入的内容，不动用户在 `CLAUDE.md` / `AGENTS.md` 里的其他规则。

### 10.1 全局卸载

#### 方式 1：让 AI 帮你卸（推荐）

打开 Claude Code 或 Codex CLI，把下面整段中文粘贴进去：

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

#### 方式 2：本地脚本

`uninstall-global.sh` 与 `install-global.sh` 对称：

```bash
# 同时清两个宿主，并删除 pack 目录
~/.superspecflow/scripts/uninstall-global.sh --both --purge

# 只清 Claude Code，保留 pack 目录
~/.superspecflow/scripts/uninstall-global.sh --claude-only

# 只清 Codex CLI，保留 pack 目录
~/.superspecflow/scripts/uninstall-global.sh --codex-only
```

防御性行为：

- 精确移除 include 行：仅删除恰好等于本仓库 install 时写入的那一行，文件其它内容原样保留。
- 清理 generated global wrappers 和 manifest 中记录且未被用户修改的 `ssf-*` commands / skills / agents；已有同名用户文件不会被覆盖或删除。
- 文件因移除而变空 → 删除整个文件；否则保留文件，只删那一行。
- `--purge` 删除 pack 目录所在路径（`~/.superspecflow/` 或用户手动 clone 的位置），如果当前工作目录在 pack 内部会拒绝执行，避免 `rm -rf` 掉运行中的脚本。
- 重复运行幂等，不报错。
- `~/.claude/settings.json` 里的 SessionStart hook 只打印提示，**不擅自改写**该文件（与安装时对称）。

#### 方式 3：手动

```bash
# 1. 找出本机所有 SuperSpecFlow include 行
grep SuperSpecFlow ~/.claude/CLAUDE.md ~/.codex/AGENTS.md 2>/dev/null

# 2. 用编辑器删除这些行；如果文件因此变空，删除整个文件
#    (Claude: @~/.claude/superspecflow/CLAUDE.global.md)
#    (Codex:  @~/.codex/superspecflow/AGENTS.global.md)
#    (legacy source include: @<pack>/routing/*.global.md)

# 3. 删除 pack 目录（默认 clone 位置）
rm -rf ~/.superspecflow

# 4. 如有 SessionStart hook，从 ~/.claude/settings.json 移除 command 指向
#    <pack>/scripts/hooks/session-start-detect.sh 的 hook 条目
```

### 10.2 项目级卸载（方案 C / 零侵入接入）

```bash
rm -rf <project>/.superspecflow
```

这会移除：

- `.superspecflow/enabled` sentinel（关闭项目 opt-in）
- 所有运行时产物子目录（`intake/`、`engineering/`、`qa/`、`release/`、`archive/`、`retro/`、`decisions/`、`maps/`、`reviews/`、`karpathy/`、`progress/`、`verification/`）
- 项目级 routing 覆盖文件（`CLAUDE.routing.md`、`AGENTS.routing.md`，如果用户曾手动创建）

`/ssf-init` 不会修改宿主项目的 `CLAUDE.md` / `AGENTS.md`，所以项目级卸载不需要回滚指令文件。

注意：`~/.superspecflow/`（家目录的装包路径）与 `<project>/.superspecflow/`（项目运行时）是两个独立目录，项目级卸载不会影响全局安装。

### 10.3 项目级卸载（方案 §4 / 软连接入路径）

如果是通过 `install-project-symlinks.sh` 安装，需要回滚链接和宿主项目指令文件中的 include：

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

## 附录 A：项目软连接入兼容路径

> 旧用户兼容路径。新项目优先使用第 3 节方案 C。

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

```markdown
@./.superspecflow/AGENTS.routing.md
@./.superspecflow/CLAUDE.routing.md
```

这种方式仍会修改宿主项目指令文件，但只增加一行 include，不复制 SuperSpecFlow 规则正文。如果当前环境不支持 `@` include，再使用 `templates/integration/*.snippet.md` 中的极薄文字入口作为 fallback。
