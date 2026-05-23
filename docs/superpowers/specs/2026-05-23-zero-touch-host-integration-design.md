# 零侵入宿主项目接入 设计文档

- 日期：2026-05-23
- 主题：Zero-Touch Host Integration
- 状态：草案，待 spec review 与用户复核
- 范围：仅本次接入机制；不含 progress 持久化与跨 CLI 互验，留作后续独立 change

## 1. 背景与问题

SuperSpecFlow 当前的接入方式（`scripts/install-project-symlinks.sh` + 宿主 `CLAUDE.md` / `AGENTS.md` 中加 `@./.superspecflow/*.routing.md`）虽然只增加一行 include，但仍然要求改动宿主项目的指令文件。用户希望进一步降低接入成本：

- 宿主项目的 `CLAUDE.md`、`AGENTS.md` 一行都不动。
- 在用户家目录做一次全局安装，所有项目按需 opt-in。
- 通过文件系统信号决定某个项目是否启用 SuperSpecFlow Intake Gate，避免全局接管所有项目（保留既有原则：`routing/CLAUDE.routing.md` 第 62-64 行）。
- `.superspecflow/` 同时作为 SSF 自有产物的根目录，便于维护和阅读。

## 2. 设计目标 / 非目标

### 2.1 目标

1. 宿主项目 `CLAUDE.md` / `AGENTS.md` 零改动即可启用 SuperSpecFlow。
2. 单次全局安装，对所有项目可用；但项目级仍需显式 opt-in，未 opt-in 项目不被自然语言接管。
3. SSF 自有产物（decisions、retro、qa、reviews、karpathy、maps、ship）归一到 `.superspecflow/` 下。
4. 兼容现有"软链 + 项目级 @入口"用户，老用户行为不变。
5. 兼容 OpenSpec 既有目录 `openspec/changes/<id>/`，不破坏外部工具假设。

### 2.2 非目标

1. 不重排 OpenSpec 目录结构。
2. 不规定 Superpowers 等外部 skill 的工作目录。
3. 不在本 spec 设计 plan → code 之间的进度持久化协议（留作 `progress-tracking` change）。
4. 不在本 spec 设计 Claude ↔ Codex 跨 CLI 互验协议（留作 `cross-agent-verification` change）。
5. 不实现把外部用户的 `~/.claude/CLAUDE.md`、`~/.claude/settings.json` 强制覆盖的脚本；只做检测与提示。

## 3. 关键决策

| 编号 | 决策 | 选项 | 选定 | 理由 |
|---|---|---|---|---|
| D-1 | 项目 opt-in 信号载体 | LLM 自检测 / sentinel + 上下文信号 / Claude Code hook | LLM 自检测 (C1) 兜底 + Claude Code SessionStart hook (C3) 加成 | C1 是最低公分母覆盖所有 agent；C3 在 Claude Code 里做到真自动化 |
| D-2 | 全局 routing 文件组织 | 新文件直写 / 现有文件双模式 / 全局薄壳 include 现有 routing | 全局薄壳 + include (D3) | 主体 routing 仍是单一事实源，全局只套自检测闸门 |
| D-3 | `.superspecflow/` 内容形态 | 纯 sentinel / sentinel + 可选覆盖 / 维持现有软链全套 | sentinel + 可选覆盖 (E2) | 默认零维护；少数项目可放项目级 routing 覆盖文件 |
| D-4 | SSF 产物目录归一范围 | 全部强收（含 OpenSpec、Superpowers） / 仅收 SSF 自有产物 / 门面式间接 | 仅收 SSF 自有产物 (G2) | OpenSpec 留根目录兼容外部工具；Superpowers 是别人的工具不越权 |

## 4. 总体架构

### 4.1 全局层（一次性安装）

```text
~/.claude/CLAUDE.md       用户加一行: @<repo>/routing/CLAUDE.global.md
~/.codex/AGENTS.md        用户加一行: @<repo>/routing/AGENTS.global.md
~/.claude/settings.json   可选: SessionStart hook 调用 <repo>/scripts/hooks/session-start-detect.sh
```

### 4.2 项目层（每个想接入的项目）

```text
宿主项目根/
├── CLAUDE.md            零改动
├── AGENTS.md            零改动
├── openspec/            保留在根目录，路径不变
│   └── changes/<id>/
└── .superspecflow/
    ├── enabled                  sentinel，空文件，存在即 opt-in
    ├── CLAUDE.routing.md        可选，项目级 routing 覆盖（E2）
    ├── AGENTS.routing.md        可选，项目级 routing 覆盖（E2）
    ├── decisions/               /ssf-decision 产物
    ├── retro/                   /ssf-retro 产物
    ├── qa/                      QA signoff
    ├── reviews/                 /ssf-review 报告
    ├── karpathy/                /ssf-karpathy 报告
    ├── maps/                    spec-to-code-map.md
    ├── ship/                    release notes、rollback plan
    └── progress/                占位，结构由后续 progress-tracking change 定义
```

## 5. 组件设计

### 5.1 全局 routing 入口（D3）

新增 `routing/CLAUDE.global.md`，结构如下：

1. **自检测前置段**（C1 兜底逻辑）：
   - 指示 LLM 在响应非问答类请求前，使用 Bash 执行 `test -f .superspecflow/enabled && echo on || echo off`，本会话只检测一次并缓存。
   - 若 Claude Code 已通过 SessionStart hook 注入 `<ssf-status>` 信号，优先使用该信号，不重复探测。

2. **始终可用的显式命令段**：
   - 列出 `/ssf-*` 命令，强调这些命令与是否 opt-in 无关，永远可调用。

3. **项目级覆盖判定段**：
   - 指示 LLM 优先读取 `.superspecflow/CLAUDE.routing.md`（若存在）作为 routing 主体；否则回落到下一步的默认 include。

4. **默认 routing include 段**：
   - `@<repo>/routing/CLAUDE.routing.md`，保持主体内容单一事实源。

`routing/AGENTS.global.md` 结构同上，仅替换 include 目标为 `AGENTS.routing.md`。

### 5.2 自检测两条腿

#### C1 兜底（写在 global routing 文件内）

伪逻辑：

```text
若本会话尚未确定 SSF 状态:
    若上下文中存在 <ssf-status> 标签:
        采用其值 (enabled / disabled)
    否则:
        运行 `test -f .superspecflow/enabled` 一次
        缓存结果作为本会话 SSF 状态
若 SSF 状态 = enabled:
    启用完整 Intake Gate (按项目级覆盖或默认 routing)
否则:
    仅暴露 /ssf-* 显式命令，不接管自然语言
```

#### C3 加成（Claude Code SessionStart hook）

新增脚本 `scripts/hooks/session-start-detect.sh`：

- 读取 `$CLAUDE_PROJECT_DIR` 或退化使用 `pwd`。
- 若存在 `.superspecflow/enabled`，输出 `<ssf-status>enabled</ssf-status>`。
- 否则输出 `<ssf-status>disabled</ssf-status>`。
- 不产生任何副作用，不写文件，不发起网络请求。

安装方式由 `scripts/install-global.sh` 询问后协助写入 `~/.claude/settings.json`，或文档指导用户手动加入。

### 5.3 `/ssf-init`（升级为零侵入版）

更新 `commands/ssf-init.md` 语义：

1. 在 cwd 创建 `.superspecflow/enabled`（sentinel）。
2. 创建子目录骨架：`decisions/`、`retro/`、`qa/`、`reviews/`、`karpathy/`、`maps/`、`ship/`、`progress/`（progress 仅占位）。
3. 不写 `.superspecflow/*.routing.md`（E2：默认空，用户主动想覆盖时再创建）。
4. 不修改宿主项目的 `CLAUDE.md` / `AGENTS.md`。
5. 输出一段提示：是否完成了全局安装？若未完成指向 `docs/installation.md` 对应章节。

### 5.4 全局安装脚本

新增 `scripts/install-global.sh`，行为：

1. 检测 `~/.claude/CLAUDE.md`：
   - 不存在：直接创建并写入 `@<repo>/routing/CLAUDE.global.md`。
   - 存在但不含该 include 行：打印应追加的行，要求用户手动确认并追加（不擅自改写用户全局文件）。
   - 已包含该行：跳过。
2. 同样规则处理 `~/.codex/AGENTS.md` ↔ `AGENTS.global.md`。
3. 询问是否安装 Claude Code SessionStart hook：
   - 若同意且 `~/.claude/settings.json` 不存在该 hook：打印应合并的 JSON 片段，要求用户手动加入；脚本本身不擅自修改 `settings.json`。
4. 全程仅做"检测 + 提示 + 可逆操作"，不做不可逆动作。

### 5.5 兼容：保留 `scripts/install-project-symlinks.sh`

- 文件保留，行为不变。
- 在 README / docs 标注："仅在不愿做全局安装时使用；推荐 scripts/install-global.sh + /ssf-init"。
- E2 的"项目级 routing 覆盖"机制天然兼容老用户已经软链上来的 `.superspecflow/CLAUDE.routing.md`，老用户行为不变。

## 6. 一次请求的数据流

```text
用户在某项目里输入自然语言请求
    ↓
Claude Code 启动会话 (或 Codex / 其他 agent)
    ↓
[C3 路径] SessionStart hook 注入 <ssf-status>enabled|disabled</ssf-status>
    或
[C1 路径] 全局 routing 文件指令 LLM 跑 test -f .superspecflow/enabled
    ↓
SSF 状态 = enabled ?
├─ yes → 读取 .superspecflow/CLAUDE.routing.md (若存在) 否则 @<repo>/routing/CLAUDE.routing.md → 执行完整 Intake Gate
└─ no  → 仅暴露 /ssf-* 显式命令；自然语言按 LLM 默认行为响应
```

## 7. 风险与对策

| 风险 | 影响 | 对策 |
|---|---|---|
| C1 LLM 每会话执行 Bash 浪费一次工具调用 | 用户体验轻度下降 | C3 hook 注入信号优先，避免重复探测；C1 仅作兜底 |
| 用户全局 `CLAUDE.md` 已有大量内容，include 行被忽略 | 接入失效 | install-global.sh 检测并提示用户确认；文档强调 include 应放靠前位置 |
| 项目级覆盖文件与全局默认 routing 漂移 | 行为分裂 | 文档明示覆盖优先级；推荐项目级文件只覆盖必要片段，不复制整份 routing |
| 老用户软链 `.superspecflow/CLAUDE.routing.md` 与新机制冲突 | 老用户被破坏 | E2 默认把项目级文件视为覆盖源；老用户行为保持一致 |
| Codex 等 agent 不支持 hook | 自动化降级 | C1 兜底仍然工作；文档明确 hook 是 Claude Code 专属增强 |
| SessionStart hook 脚本失败 | 会话启动报错 | 脚本写为"任何错误也输出 disabled 不抛异常"；最坏情况退化为未接管 |

## 8. 文件清单

### 8.1 新增

- `routing/CLAUDE.global.md`
- `routing/AGENTS.global.md`
- `scripts/hooks/session-start-detect.sh`
- `scripts/install-global.sh`
- `docs/superpowers/specs/2026-05-23-zero-touch-host-integration-design.md`（本设计本身）

### 8.2 修改

- `commands/ssf-init.md`（升级为零侵入版 + 创建产物子目录骨架）
- `docs/installation.md`（新增"推荐：方案 C 零侵入接入"章节，原软链方案降级为"兼容方案"）
- `README.md`（接入指引指向新章节）
- `CLAUDE.md` / `AGENTS.md`（仅必要补充：在交互策略与接入说明部分指明 opt-in 信号载体；具体补充行需在 plan 阶段以 diff 级粒度落定，禁止范围漂移）
- `routing/CLAUDE.routing.md` / `routing/AGENTS.routing.md`（**仅同步高风险关键词清单一段**，从项目根 `CLAUDE.md` 第 179-183 行提取到 routing 主体，使全局接入路径也能识别"登录、认证、支付、权限"等高风险词；除该段以外的 routing 主体内容不动；此项为本 spec 的最小必要例外，不影响"主体事实源不变"的整体承诺）

### 8.3 不动

- `routing/CLAUDE.routing.md`、`routing/AGENTS.routing.md` 主体内容不变（高风险关键词清单同步见 8.2，是仅有的最小例外）
- `scripts/install-project-symlinks.sh`（保留为兼容方案）
- 所有 ssf-* skills 中涉及 `openspec/` 路径的文件（OpenSpec 路径不动）

## 9. 验证

### 9.1 接入正确性

| 场景 | 输入 | 期望 |
|---|---|---|
| 空目录、未跑 `/ssf-init` | 输入"解释一下 React useEffect" | 正常回答，不进 Intake Gate |
| 空目录、未跑 `/ssf-init` | 输入"我要做一个登录" | 不强行接管；按 LLM 默认行为响应 |
| 跑过 `/ssf-init` 的目录 | 输入"我要做一个登录" | 进入 Intake Gate，判定为非平凡行为变更（且若 routing 主体已包含高风险关键词清单则进一步标为高风险），进入 ssf-think |
| 跑过 `/ssf-init` 的目录 | 输入 `/ssf-think 续费提醒` | 显式命令直接执行，无需额外判定 |
| 项目里有 `.superspecflow/CLAUDE.routing.md` | 自然语言请求 | 该覆盖文件生效，全局默认 routing 不被采用 |
| Claude Code 装了 SessionStart hook | 启动会话 | 上下文中可见 `<ssf-status>` 标签，无需 LLM 跑探测命令 |

### 9.2 兼容性

| 场景 | 期望 |
|---|---|
| 老用户已有 `install-project-symlinks.sh` 生成的 `.superspecflow/` 软链结构 | 行为完全不变 |
| 项目内已有 `openspec/changes/<id>/` | 路径与流程不变 |
| 宿主项目 `CLAUDE.md` / `AGENTS.md` 完全不动 | 接入仍然生效（前提：全局已装、`.superspecflow/enabled` 存在） |

### 9.3 失败路径

| 故障 | 期望 |
|---|---|
| SessionStart hook 脚本不存在 / 执行失败 | C1 兜底接管，输出 disabled，不抛异常 |
| 用户全局 `CLAUDE.md` 缺 include 行 | install-global.sh 检测出并明确提示用户补 |
| `.superspecflow/enabled` 被误删 | 项目自动回退到未接管状态；`/ssf-init` 可重新创建 |

## 10. 后续 change（不在本 spec 实现）

| change-id（建议） | 范围 | 依赖 |
|---|---|---|
| `progress-tracking` | plan → code 之间的进度档案、测试进度、中断恢复协议 | 本 spec 的 `.superspecflow/progress/` 占位 |
| `cross-agent-verification` | Claude ↔ Codex 双签 / 互验门禁、共识协议 | `progress-tracking` |
