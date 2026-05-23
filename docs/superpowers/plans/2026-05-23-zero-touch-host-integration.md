# 零侵入宿主项目接入 实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让宿主项目无需修改 `CLAUDE.md` / `AGENTS.md` 即可启用 SuperSpecFlow Intake Gate，通过全局 routing 薄壳 + 项目级 `.superspecflow/enabled` sentinel 实现 opt-in。

**Architecture:** 全局新增 `routing/CLAUDE.global.md` / `AGENTS.global.md` 作为薄壳，include 既有 `routing/CLAUDE.routing.md` / `AGENTS.routing.md` 主体；通过 C1（LLM 在会话首次 Bash 探测 `.superspecflow/enabled`）兜底 + C3（Claude Code SessionStart hook 注入 `<ssf-status>` 信号）加成两条腿判定 opt-in 状态；`.superspecflow/` 同时作为 SSF 自有产物归一根目录；OpenSpec 路径与既有 `install-project-symlinks.sh` 老用户路径不动；高风险关键词清单从项目根 `CLAUDE.md` 同步一段到 routing 主体（最小例外）。

**Tech Stack:** Bash（shell 脚本与 hook）、Markdown（routing / commands / docs）、bats-core（shell 测试，若仓库未安装则降级为可执行的手工断言脚本）。

**关联 Spec:** `docs/superpowers/specs/2026-05-23-zero-touch-host-integration-design.md`
**Change ID:** `zero-touch-host-integration`

---

## 0. 全局约定

- **commit 规范**：本仓库 `CLAUDE.md` 第 66-122 行。标题 `<英文类型>(<英文范围>): <中文摘要>`，正文必须含"变更编号 / 关联规格 / 变更内容 / 验证方式 / 风险与回滚"五段。每个任务的提交步骤都给出完整 commit 模板。
- **路径约定**：以下出现的 `<repo>` 一律指 `/Users/wang/Documents/SuperSpecFlow`（开发机绝对路径）；安装到用户环境后会替换为用户 clone 出的仓库绝对路径，这是 install-global.sh 要解决的事。
- **TDD 适用范围**：本计划主要产物是 shell 脚本与 Markdown 文档。对 shell 脚本（`session-start-detect.sh`、`install-global.sh`）使用 bats-core 风格测试；对 Markdown 文档（routing / commands / docs）采用 `scripts/validate-pack.sh` 风格的"内容契约"断言测试。
- **测试运行命令统一**：每个任务给出独立运行命令。最终全部接入 `scripts/validate-pack.sh`，最后一个任务跑全量自检。
- **禁止扩大范围**：spec 8.2 中明示的"高风险关键词清单同步到 routing 主体"是 routing 主体唯一允许的修改；其余 routing 主体内容**严禁**任何 task 触碰。
- **禁止删除/重命名 `scripts/install-project-symlinks.sh`**：老用户兼容路径。
- **禁止改 OpenSpec 路径**：所有 `openspec/changes/<id>/` 路径在 ssf-* skills/agents 中保持不变。

---

## 1. File Structure

### 1.1 新增文件

| 路径 | 责任 |
|---|---|
| `routing/CLAUDE.global.md` | Claude Code 全局 routing 薄壳。包含 C1 自检测前置段 + 项目级覆盖判定段 + include 既有 `CLAUDE.routing.md` |
| `routing/AGENTS.global.md` | Codex / 其他 agent 全局 routing 薄壳，结构同上，include `AGENTS.routing.md` |
| `scripts/hooks/session-start-detect.sh` | Claude Code SessionStart hook 脚本。检测 cwd 下 `.superspecflow/enabled` 是否存在，向 stdout 输出 `<ssf-status>enabled|disabled</ssf-status>`。任何异常都退化为 disabled |
| `scripts/install-global.sh` | 全局安装脚本。检测 `~/.claude/CLAUDE.md`、`~/.codex/AGENTS.md` 是否已含 include 行，未含则打印提示；询问是否安装 hook，同意时打印应合并到 `~/.claude/settings.json` 的 JSON 片段；**不**擅自改写用户全局文件 |
| `tests/hooks/test_session_start_detect.bats` | session-start-detect.sh 行为测试 |
| `tests/install/test_install_global.bats` | install-global.sh 行为测试（在临时 HOME 下隔离运行） |
| `tests/init/test_ssf_init_zero_touch.bats` | `/ssf-init` 创建产物目录骨架的契约测试 |

### 1.2 修改文件

| 路径 | 修改范围 |
|---|---|
| `commands/ssf-init.md` | 整体重写为零侵入语义：sentinel + 子目录骨架；显式说明"不再创建 routing 软链；不再写宿主 CLAUDE.md / AGENTS.md" |
| `routing/CLAUDE.routing.md` | **仅追加一段** "高风险关键词" 清单（与项目根 `CLAUDE.md` 第 179-183 行同步），位置紧跟 `## Karpathy 编码纪律` 前。其余主体内容不动 |
| `routing/AGENTS.routing.md` | 同上 |
| `docs/installation.md` | 新增"推荐：方案 C 零侵入接入"章节作为新的第 2 节；原"软连接入"降级为"兼容方案"，章节号顺移 |
| `README.md` | 顶部接入指引指向 `docs/installation.md` 的新方案 C 章节 |
| `scripts/validate-pack.sh` | 追加针对全局 routing 文件、hook 脚本、ssf-init 新形态的自检项 |

### 1.3 显式不动文件

- `scripts/install-project-symlinks.sh`
- `update.sh`（保持老的全局能力安装行为；本计划新增的 `install-global.sh` 与之**并列**，不替代）
- 所有 ssf-* skills / agents 中涉及 `openspec/` 的路径
- `routing/CLAUDE.routing.md` / `routing/AGENTS.routing.md` 除"高风险关键词追加段"以外的所有内容

### 1.4 测试组织

仓库目前没有 `tests/` 目录。本计划新建 `tests/`，结构：

```
tests/
├── lib/                                # 共享测试帮手
│   └── test_helper.bash                # setup/teardown、临时 HOME、fixture 工厂
├── hooks/
│   └── test_session_start_detect.bats
├── install/
│   └── test_install_global.bats
└── init/
    └── test_ssf_init_zero_touch.bats
```

如果 CI / 开发环境没有 bats-core，每个 `.bats` 文件第一行给出兜底说明："bats 不存在时使用 `bash tests/run-fallback.sh` 跑等价的纯 bash 断言"——这部分在最后一个任务里建。

---

## 2. 任务总览

按依赖顺序：

1. Task 1：建测试脚手架（test_helper、空跑通的 smoke test）
2. Task 2：实现 `scripts/hooks/session-start-detect.sh` + 测试
3. Task 3：实现 `routing/CLAUDE.global.md` + `routing/AGENTS.global.md`（含 C1 文本指令）
4. Task 4：同步高风险关键词清单到 `routing/CLAUDE.routing.md` + `routing/AGENTS.routing.md`（最小例外）
5. Task 5：重写 `commands/ssf-init.md` 为零侵入语义 + 测试
6. Task 6：实现 `scripts/install-global.sh` + 测试
7. Task 7：更新 `docs/installation.md` 新增方案 C 章节，原方案降级
8. Task 8：更新 `README.md` 接入指引
9. Task 9：扩展 `scripts/validate-pack.sh` 覆盖新文件
10. Task 10：端到端 smoke（在临时 HOME + 临时 project 里完整跑一遍）

每个任务结束都 commit 一次，便于 review 与回滚。

---

## 3. 任务细节

### Task 1: 建测试脚手架

**Files:**
- Create: `tests/lib/test_helper.bash`
- Create: `tests/smoke/test_scaffold.bats`

**目标**：让后续任务能立刻 TDD，先把"测试能跑"这件事跑通。

- [ ] **Step 1: 检测 bats-core 是否可用**

```bash
command -v bats || echo "MISSING"
```

预期：输出 bats 路径，或输出 `MISSING`。
若 `MISSING`：在 macOS 上执行 `brew install bats-core`；其他平台参考 https://bats-core.readthedocs.io。安装后继续。

- [ ] **Step 2: 写脚手架 helper**

`tests/lib/test_helper.bash`：

```bash
#!/usr/bin/env bash
# 共享测试帮手。bats 测试用 `load '../lib/test_helper'` 引入。

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export REPO_ROOT

# 创建隔离的临时 HOME，避免污染用户环境。
ssf_make_tmp_home() {
  local tmp
  tmp="$(mktemp -d "${TMPDIR:-/tmp}/ssf-home.XXXXXX")"
  mkdir -p "$tmp/.claude" "$tmp/.codex"
  echo "$tmp"
}

# 创建一个临时 project 目录。
ssf_make_tmp_project() {
  mktemp -d "${TMPDIR:-/tmp}/ssf-proj.XXXXXX"
}

ssf_cleanup_tmp() {
  local dir="$1"
  case "$dir" in
    /tmp/ssf-*|/var/folders/*/T/ssf-*) rm -rf "$dir" ;;
    *) echo "拒绝清理可疑路径: $dir" >&2; return 1 ;;
  esac
}
```

- [ ] **Step 3: 写脚手架 smoke 测试**

`tests/smoke/test_scaffold.bats`：

```bash
#!/usr/bin/env bats

load '../lib/test_helper'

@test "REPO_ROOT 指向仓库根" {
  [ -f "$REPO_ROOT/CLAUDE.md" ]
  [ -d "$REPO_ROOT/routing" ]
}

@test "ssf_make_tmp_home 创建可写目录并含 .claude / .codex" {
  home="$(ssf_make_tmp_home)"
  [ -d "$home/.claude" ]
  [ -d "$home/.codex" ]
  ssf_cleanup_tmp "$home"
}
```

- [ ] **Step 4: 跑 smoke 测试**

```bash
cd /Users/wang/Documents/SuperSpecFlow
bats tests/smoke/test_scaffold.bats
```

预期：2 个测试都 PASS。

- [ ] **Step 5: Commit**

```bash
git add tests/
git commit -m "$(cat <<'EOF'
test(tests): 引入 bats 测试脚手架与共享 helper

变更编号：zero-touch-host-integration
关联规格：docs/superpowers/specs/2026-05-23-zero-touch-host-integration-design.md

变更内容：
- 新增 tests/lib/test_helper.bash，提供临时 HOME、临时 project 与受限清理工具
- 新增 tests/smoke/test_scaffold.bats 验证脚手架自身可用

验证方式：
- bats tests/smoke/test_scaffold.bats（2 PASS）

风险与回滚：
- 风险：bats 在用户环境缺失会导致后续任务无法 TDD；已在 Task 1 step 1 中提示安装
- 回滚：rm -rf tests/，本提交 revert
EOF
)"
```

---

### Task 2: SessionStart hook 脚本

**Files:**
- Create: `scripts/hooks/session-start-detect.sh`
- Create: `tests/hooks/test_session_start_detect.bats`

**目标**：在 Claude Code 启动会话时输出**符合官方 SessionStart hook 协议**的 JSON，`additionalContext` 字段携带 `<ssf-status>enabled|disabled</ssf-status>` 标签，作为 C3 加成路径。任何异常都退化为 disabled，不抛错。

**协议要点**（依据 Claude Code 官方 hooks 文档）：

- 脚本通过 stdout 输出**单行 JSON**：
  ```json
  {"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"<ssf-status>enabled</ssf-status>"}}
  ```
- Claude Code 会把 `additionalContext` 注入会话上下文，后续 LLM 读取 routing 时即可看见 `<ssf-status>` 标签
- 退出码恒为 0，任何错误均输出 disabled 版本的 JSON

- [ ] **Step 1: 写失败测试**

`tests/hooks/test_session_start_detect.bats`：

```bash
#!/usr/bin/env bats

load '../lib/test_helper'

setup() {
  PROJECT="$(ssf_make_tmp_project)"
  HOOK="$REPO_ROOT/scripts/hooks/session-start-detect.sh"
}

teardown() {
  ssf_cleanup_tmp "$PROJECT"
}

# 解析 JSON 中 additionalContext 字段的工具函数（不依赖 jq，使用 grep + sed）
extract_context() {
  # 输入：JSON 单行；输出：additionalContext 字符串值
  printf '%s' "$1" | sed -nE 's/.*"additionalContext":"([^"]*)".*/\1/p'
}

@test "cwd 无 .superspecflow/enabled 时 additionalContext 为 disabled 标签" {
  cd "$PROJECT"
  run "$HOOK"
  [ "$status" -eq 0 ]
  ctx="$(extract_context "$output")"
  [ "$ctx" = "<ssf-status>disabled</ssf-status>" ]
}

@test "cwd 有 .superspecflow/enabled 时 additionalContext 为 enabled 标签" {
  mkdir -p "$PROJECT/.superspecflow"
  touch "$PROJECT/.superspecflow/enabled"
  cd "$PROJECT"
  run "$HOOK"
  [ "$status" -eq 0 ]
  ctx="$(extract_context "$output")"
  [ "$ctx" = "<ssf-status>enabled</ssf-status>" ]
}

@test "CLAUDE_PROJECT_DIR 环境变量优先于 cwd" {
  mkdir -p "$PROJECT/.superspecflow"
  touch "$PROJECT/.superspecflow/enabled"
  cd /tmp
  CLAUDE_PROJECT_DIR="$PROJECT" run "$HOOK"
  [ "$status" -eq 0 ]
  ctx="$(extract_context "$output")"
  [ "$ctx" = "<ssf-status>enabled</ssf-status>" ]
}

@test "输出始终是符合 hook 协议的单行 JSON" {
  cd "$PROJECT"
  run "$HOOK"
  [ "$status" -eq 0 ]
  # 必须包含官方协议三个关键字段
  [[ "$output" == *"hookSpecificOutput"* ]]
  [[ "$output" == *"\"hookEventName\":\"SessionStart\""* ]]
  [[ "$output" == *"additionalContext"* ]]
  # 必须是单行（行数 = 1）
  line_count="$(printf '%s' "$output" | wc -l | tr -d ' ')"
  [ "$line_count" = "0" ] || [ "$line_count" = "1" ]
}

@test "任何不可预期错误也只输出 disabled，不抛非零退出" {
  CLAUDE_PROJECT_DIR="/nonexistent/$(uuidgen 2>/dev/null || echo xxx)" run "$HOOK"
  [ "$status" -eq 0 ]
  ctx="$(extract_context "$output")"
  [ "$ctx" = "<ssf-status>disabled</ssf-status>" ]
}
```

- [ ] **Step 2: 跑测试确认全部失败**

```bash
bats tests/hooks/test_session_start_detect.bats
```

预期：5 个测试 FAIL（脚本不存在）。

- [ ] **Step 3: 实现 hook 脚本**

`scripts/hooks/session-start-detect.sh`：

```bash
#!/usr/bin/env bash
# SuperSpecFlow Claude Code SessionStart hook (C3 加成路径)
# 输出符合官方 SessionStart hook 协议的 JSON，additionalContext 字段携带 <ssf-status> 标签。
# 任何错误一律退化为 disabled 版本的合法 JSON，绝不向上抛异常。

set +e

emit() {
  # 单行 JSON，标签作为 additionalContext 字符串内容。
  local status="$1"   # enabled | disabled
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"<ssf-status>%s</ssf-status>"}}\n' "$status"
  exit 0
}

trap 'emit disabled' ERR

project_dir="${CLAUDE_PROJECT_DIR:-$PWD}"

if [ ! -d "$project_dir" ]; then
  emit disabled
fi

if [ -f "$project_dir/.superspecflow/enabled" ]; then
  emit enabled
fi

emit disabled
```

赋可执行权限：

```bash
chmod +x scripts/hooks/session-start-detect.sh
```

- [ ] **Step 4: 跑测试确认全部通过**

```bash
bats tests/hooks/test_session_start_detect.bats
```

预期：5 PASS。

- [ ] **Step 5: Commit**

```bash
git add scripts/hooks/session-start-detect.sh tests/hooks/
git commit -m "$(cat <<'EOF'
feat(scripts): 新增 SessionStart hook 探测项目级 opt-in 信号

变更编号：zero-touch-host-integration
关联规格：docs/superpowers/specs/2026-05-23-zero-touch-host-integration-design.md（5.2 C3）

变更内容：
- 新增 scripts/hooks/session-start-detect.sh：按 Claude Code 官方 SessionStart hook 协议输出单行 JSON，additionalContext 字段携带 <ssf-status>enabled|disabled</ssf-status> 标签
- 任何错误均退化为 disabled 版本的合法 JSON，避免会话启动报错
- 新增 5 个 bats 测试覆盖 enabled / disabled / CLAUDE_PROJECT_DIR / 协议结构 / 异常退化

验证方式：
- bats tests/hooks/test_session_start_detect.bats（5 PASS）

风险与回滚：
- 风险：用户 settings.json 未配置该 hook 时 C3 不生效；C1 兜底仍然工作（见 Task 3）
- 回滚：删除脚本与测试，从用户 settings.json 移除 hook 条目
EOF
)"
```

---

### Task 3: 全局 routing 薄壳

**Files:**
- Create: `routing/CLAUDE.global.md`
- Create: `routing/AGENTS.global.md`

**目标**：实现 D3：薄壳 + **指令式条件读取**既有 routing 主体。包含 C1 自检测指令、项目级覆盖判定、显式命令始终可用、条件读取主体的指令。

**关键决策**：**不使用 `@<repo>/routing/CLAUDE.routing.md` 自动 include 写法**。原因：`@` 在任何会话都会被无条件解析，那样 disabled 项目也会吃到完整 Intake Gate 文本，破坏方案 C 的核心承诺。改为对 LLM 的指令式约束："SSF 状态 = enabled 且无项目级覆盖时，**用 Read 工具读取**对应文件；disabled 时不得读取。"

- [ ] **Step 1: 写 `routing/CLAUDE.global.md`**

```markdown
# SuperSpecFlow Global Routing for Claude Code

本文件是 SuperSpecFlow 的全局薄壳入口，被用户家目录 `~/.claude/CLAUDE.md` 通过 `@<repo>/routing/CLAUDE.global.md` 引用。它只做四件事：项目 opt-in 自检测、显式命令始终可用声明、项目级覆盖判定、条件读取主体 routing。

## 1. 项目 opt-in 自检测（必须在响应任何非问答类请求前完成）

判定 SSF 状态优先级：

1. 若对话上下文已包含 `<ssf-status>enabled</ssf-status>` 或 `<ssf-status>disabled</ssf-status>` 标签（由 Claude Code SessionStart hook 注入），直接采用其值，**不再**执行下面的 Bash 探测。
2. 否则在本会话内**只执行一次** Bash：

   ```bash
   test -f .superspecflow/enabled && echo enabled || echo disabled
   ```

   将结果作为本会话 SSF 状态使用，后续不重复探测。

## 2. 显式命令始终可用

无论 SSF 状态如何，下列 `/ssf-*` 显式命令都可被用户调用，按对应 skill 执行一次性动作：

```text
/ssf-think /ssf-spec /ssf-build /ssf-review /ssf-qa /ssf-ship
/ssf-archive /ssf-retro /ssf-decision /ssf-map /ssf-karpathy
/ssf-init /ssf-git /ssf-branch /ssf-commit /ssf-pr
```

## 3. 项目级覆盖判定

当 SSF 状态 = `enabled` 时，按下列顺序决定 routing 主体来源：

- 若当前项目存在 `.superspecflow/CLAUDE.routing.md`：**用 Read 工具读取该文件**，将其作为本会话 routing 主体，**不再**读取下一步的全局默认文件。
- 否则进入第 4 节。

## 4. 条件读取默认 routing 主体（不使用 @ 自动 include）

**重要**：本文件**故意不**使用 `@<repo>/routing/CLAUDE.routing.md` 自动展开写法。因为 `@` 在所有会话都会被无条件解析，会破坏 SSF 状态 = `disabled` 时"不接管自然语言"的承诺。

替代约束（必须遵守）：

- **当且仅当** SSF 状态 = `enabled` 且未命中第 3 节项目级覆盖时，你（LLM）须**主动用 Read 工具读取** `<repo>/routing/CLAUDE.routing.md`，并采用其内容作为本会话 routing 主体。
- 当 SSF 状态 = `disabled` 时，**不得**读取该文件，也不得应用其中的约束。
- 路径中的 `<repo>` 占位符会被 `install-global.sh` 替换为用户仓库绝对路径。

## 5. SSF 状态 = disabled 时的行为

- 不接管自然语言请求，按 Claude Code 默认行为响应。
- 仅当用户显式输入 `/ssf-*` 命令时执行对应 skill。
- 不强制 Intake Gate、不强制 change-id、不要求中文 commit。
- **不读取** `<repo>/routing/CLAUDE.routing.md`。

## 6. 安装说明

本文件由 `scripts/install-global.sh` 协助引入 `~/.claude/CLAUDE.md`。已有用户全局文件时脚本只打印应追加行，不擅自改写。
```

- [ ] **Step 2: 写 `routing/AGENTS.global.md`**

结构同上，把所有 `CLAUDE` 替换为 `AGENTS`，把 `~/.claude/CLAUDE.md` 替换为 `~/.codex/AGENTS.md`，并把第 1 节关于 `<ssf-status>` 标签的优先级条目删掉（Codex 没有等价 hook 机制；保留 Bash 探测作为唯一路径）。

`routing/AGENTS.global.md`：

```markdown
# SuperSpecFlow Global Routing for Codex / Generic Agents

本文件是 SuperSpecFlow 的全局薄壳入口，被用户家目录 `~/.codex/AGENTS.md` 通过 `@<repo>/routing/AGENTS.global.md` 引用。

## 1. 项目 opt-in 自检测（必须在响应任何非问答类请求前完成）

在本会话内**只执行一次** Bash：

```bash
test -f .superspecflow/enabled && echo enabled || echo disabled
```

将结果作为本会话 SSF 状态使用，后续不重复探测。

## 2. 显式命令始终可用

无论 SSF 状态如何，下列 `/ssf-*` 显式命令都可被用户调用：

```text
/ssf-think /ssf-spec /ssf-build /ssf-review /ssf-qa /ssf-ship
/ssf-archive /ssf-retro /ssf-decision /ssf-map /ssf-karpathy
/ssf-init /ssf-git /ssf-branch /ssf-commit /ssf-pr
```

## 3. 项目级覆盖判定

当 SSF 状态 = `enabled` 时，按下列顺序决定 routing 主体来源：

- 若当前项目存在 `.superspecflow/AGENTS.routing.md`：用工具读取该文件，作为本会话 routing 主体，不再进入第 4 节。
- 否则进入第 4 节。

## 4. 条件读取默认 routing 主体（不使用 @ 自动 include）

**重要**：本文件**故意不**使用 `@<repo>/routing/AGENTS.routing.md` 自动展开写法，理由与 CLAUDE.global.md 相同。

替代约束：

- **当且仅当** SSF 状态 = `enabled` 且未命中第 3 节项目级覆盖时，主动读取 `<repo>/routing/AGENTS.routing.md`，并采用其内容作为本会话 routing 主体。
- 当 SSF 状态 = `disabled` 时，不得读取该文件，也不得应用其中的约束。

## 5. SSF 状态 = disabled 时的行为

不接管自然语言；仅响应 `/ssf-*` 显式命令；按 agent 默认行为处理其他请求；不读取 `<repo>/routing/AGENTS.routing.md`。

## 6. 安装说明

由 `scripts/install-global.sh` 协助引入 `~/.codex/AGENTS.md`。
```

- [ ] **Step 3: 人工核对**

```bash
ls routing/CLAUDE.global.md routing/AGENTS.global.md
# 必须不包含 @ 自动 include 写法
! grep -E "^@<repo>/routing/CLAUDE\.routing\.md" routing/CLAUDE.global.md
! grep -E "^@<repo>/routing/AGENTS\.routing\.md" routing/AGENTS.global.md
# 必须包含指令式条件读取的关键字
grep -q "主动用 Read 工具读取\|主动读取" routing/CLAUDE.global.md
grep -q "主动用 Read 工具读取\|主动读取" routing/AGENTS.global.md
```

预期：两文件存在；不含 `@<repo>/routing/...` 行首 include；包含指令式条件读取关键字。

- [ ] **Step 4: Commit**

```bash
git add routing/CLAUDE.global.md routing/AGENTS.global.md
git commit -m "$(cat <<'EOF'
feat(routing): 新增全局薄壳 routing 入口与项目级 opt-in 自检测

变更编号：zero-touch-host-integration
关联规格：docs/superpowers/specs/2026-05-23-zero-touch-host-integration-design.md（4.1 / 5.1 / 5.2）

变更内容：
- 新增 routing/CLAUDE.global.md：C1 兜底（Bash 一次性探测）+ C3 优先（读 <ssf-status> 标签）+ 项目级覆盖判定 + 指令式条件读取既有 CLAUDE.routing.md
- 新增 routing/AGENTS.global.md：结构同上，去掉 hook 优先（Codex 无等价机制），保留 Bash 探测兜底
- 故意不使用 @<repo>/routing/*.routing.md 自动 include 写法，避免 disabled 项目被无条件注入完整 routing 主体
- 全局文件中 `<repo>` 为字面占位符，由 install-global.sh 在打印提示行时替换为用户仓库绝对路径

验证方式：
- 人工核对两文件存在且不含 @ 自动 include 写法
- 后续 Task 9 在 validate-pack.sh 中追加结构断言

风险与回滚：
- 风险：依赖 LLM 严格遵守"disabled 不读取主体文件"指令；若 LLM 越界读取，会破坏方案 C 的"不接管"承诺
- 回滚：删除两文件，从用户全局文件移除 include 行
EOF
)"
```

---

### Task 4: 高风险关键词同步到 routing 主体（最小例外）

**Files:**
- Modify: `routing/CLAUDE.routing.md`（追加一段）
- Modify: `routing/AGENTS.routing.md`（追加一段）

**目标**：让方案 C 路径下"登录、认证"等高风险关键词能被识别。**严禁**触碰 routing 主体的其他任何内容。

- [ ] **Step 1: 读取项目根 CLAUDE.md 第 179-183 行作为权威来源**

```bash
sed -n '179,183p' CLAUDE.md
```

预期输出：

```
## 高风险关键词

看到以下关键词时，自动提高门禁级别：

支付、订阅、退款、计费、权限、登录、认证、数据库、迁移、删除、批量、webhook、密钥、安全、生产、发布、用户数据。
```

- [ ] **Step 2: 定位 `routing/CLAUDE.routing.md` 中 `## Karpathy 编码纪律` 行号**

```bash
grep -n "^## Karpathy 编码纪律" routing/CLAUDE.routing.md
```

记录行号，下一步在该行**之前**插入。

- [ ] **Step 3: 用 Edit 工具在 `## Karpathy 编码纪律` 之前插入新段**

要插入的文本（行尾保留一个空行与原 `## Karpathy 编码纪律` 分隔）：

```markdown
## 高风险关键词

看到以下关键词时，自动提高门禁级别：

支付、订阅、退款、计费、权限、登录、认证、数据库、迁移、删除、批量、webhook、密钥、安全、生产、发布、用户数据。

```

用 Edit 工具，`old_string` 为 `## Karpathy 编码纪律`，`new_string` 为上述新段 + `## Karpathy 编码纪律`，保证唯一匹配。

- [ ] **Step 4: 对 `routing/AGENTS.routing.md` 重复 Step 2-3**

同样在 `## Karpathy 编码纪律` 之前插入同一段。

- [ ] **Step 5: 验证主体其他内容未被改动**

```bash
git diff routing/CLAUDE.routing.md routing/AGENTS.routing.md
```

预期：两文件的 diff **只包含**新追加的 6 行（含空行）；没有任何其他内容被改动或重排。如果 diff 显示了其他改动，立刻 `git checkout -- routing/` 重做 Step 3-4。

- [ ] **Step 6: 验证关键词同步无遗漏**

```bash
grep -c "登录、认证" routing/CLAUDE.routing.md routing/AGENTS.routing.md
```

预期：两个文件各输出 `1`。

- [ ] **Step 7: Commit**

```bash
git add routing/CLAUDE.routing.md routing/AGENTS.routing.md
git commit -m "$(cat <<'EOF'
spec(routing): 同步高风险关键词清单到 routing 主体

变更编号：zero-touch-host-integration
关联规格：docs/superpowers/specs/2026-05-23-zero-touch-host-integration-design.md（8.2 最小例外）

变更内容：
- 在 routing/CLAUDE.routing.md 与 routing/AGENTS.routing.md 的 ## Karpathy 编码纪律 之前各追加一段"高风险关键词"清单
- 内容与项目根 CLAUDE.md 第 179-183 行严格一致
- 这是 spec 8.2 中明示的最小例外，主体其他内容不变

验证方式：
- git diff routing/ 仅包含新追加的 6 行
- grep -c "登录、认证" 两文件各输出 1

风险与回滚：
- 风险：未来根 CLAUDE.md 清单变更而 routing 主体未同步会再次造成漂移；通过 Task 9 validate-pack.sh 追加一致性断言
- 回滚：git revert 本提交
EOF
)"
```

---

### Task 5: 重写 `commands/ssf-init.md` 为零侵入语义

**Files:**
- Modify: `commands/ssf-init.md`（整体重写）
- Create: `tests/init/test_ssf_init_zero_touch.bats`

**目标**：`/ssf-init` 不再创建软链；只创建 `.superspecflow/enabled` + 7 个产物子目录骨架 + `progress/` 占位；不写宿主 CLAUDE.md / AGENTS.md。

**关键约束**：`commands/*.md` 是 LLM 指令文件，不是可执行脚本。我们没法直接对 LLM 行为单测；但可以测"如果一个 agent 严格按照 ssf-init.md 的步骤跑会产生什么"——做法是把 Step 列出的副作用提炼成一个**契约脚本** `scripts/_ssf_init_apply.sh`（私有），由 ssf-init.md 步骤直接复用 + bats 测试。

- [ ] **Step 1: 写失败测试**

`tests/init/test_ssf_init_zero_touch.bats`：

```bash
#!/usr/bin/env bats

load '../lib/test_helper'

setup() {
  PROJECT="$(ssf_make_tmp_project)"
  APPLY="$REPO_ROOT/scripts/_ssf_init_apply.sh"
}

teardown() {
  ssf_cleanup_tmp "$PROJECT"
}

@test "_ssf_init_apply 在空项目里创建 .superspecflow/enabled" {
  cd "$PROJECT"
  run "$APPLY"
  [ "$status" -eq 0 ]
  [ -f "$PROJECT/.superspecflow/enabled" ]
}

@test "创建七个产物子目录" {
  cd "$PROJECT"
  "$APPLY"
  for sub in decisions retro qa reviews karpathy maps ship; do
    [ -d "$PROJECT/.superspecflow/$sub" ] || { echo "missing $sub"; return 1; }
  done
}

@test "创建 progress/ 占位目录" {
  cd "$PROJECT"
  "$APPLY"
  [ -d "$PROJECT/.superspecflow/progress" ]
}

@test "progress/ 内不写任何占位文件" {
  cd "$PROJECT"
  "$APPLY"
  # 期待为空目录；ls -A 应无输出
  [ -z "$(ls -A "$PROJECT/.superspecflow/progress")" ]
}

@test "不创建任何 routing 软链 / 覆盖文件" {
  cd "$PROJECT"
  "$APPLY"
  [ ! -e "$PROJECT/.superspecflow/CLAUDE.routing.md" ]
  [ ! -e "$PROJECT/.superspecflow/AGENTS.routing.md" ]
  [ ! -e "$PROJECT/.superspecflow/templates" ]
}

@test "不修改宿主 CLAUDE.md / AGENTS.md（即使存在）" {
  cd "$PROJECT"
  printf 'EXISTING-CLAUDE\n' > CLAUDE.md
  printf 'EXISTING-AGENTS\n' > AGENTS.md
  "$APPLY"
  [ "$(cat CLAUDE.md)" = "EXISTING-CLAUDE" ]
  [ "$(cat AGENTS.md)" = "EXISTING-AGENTS" ]
}

@test "幂等：重复执行不报错也不破坏既有子目录内容" {
  cd "$PROJECT"
  "$APPLY"
  echo "user-data" > "$PROJECT/.superspecflow/decisions/keep.md"
  run "$APPLY"
  [ "$status" -eq 0 ]
  [ "$(cat "$PROJECT/.superspecflow/decisions/keep.md")" = "user-data" ]
}
```

- [ ] **Step 2: 跑测试确认全部失败**

```bash
bats tests/init/test_ssf_init_zero_touch.bats
```

预期：7 个测试 FAIL（脚本不存在）。

- [ ] **Step 3: 实现契约脚本 `scripts/_ssf_init_apply.sh`**

```bash
#!/usr/bin/env bash
# SuperSpecFlow /ssf-init 副作用契约脚本（私有）。
# 由 commands/ssf-init.md 中的步骤直接调用，使 bats 测试可对其行为做契约验证。
# 严禁修改宿主 CLAUDE.md / AGENTS.md。严禁创建 routing 软链。

set -euo pipefail

project="${SSF_INIT_PROJECT_DIR:-$PWD}"

mkdir -p "$project/.superspecflow"
: > "$project/.superspecflow/enabled" || true

for sub in decisions retro qa reviews karpathy maps ship progress; do
  mkdir -p "$project/.superspecflow/$sub"
done

# progress/ 必须保持空（结构由后续 progress-tracking change 定义）。
# 不写 .gitkeep、不写 README，避免与未来 change 冲突。

# 显式打印只读提示；不修改任何宿主指令文件。
cat <<MSG
SuperSpecFlow 项目 opt-in 已生效：$project/.superspecflow/enabled

下一步（仅在尚未做过全局安装时）：
  bash <pack>/scripts/install-global.sh

如果你只想给本项目使用而不做全局安装，可手动在 $project/CLAUDE.md 中加入：
  @<pack>/routing/CLAUDE.global.md
（这一行为可选；不加也不影响 /ssf-* 显式命令）
MSG
```

赋可执行权限：

```bash
chmod +x scripts/_ssf_init_apply.sh
```

- [ ] **Step 4: 跑测试确认全部通过**

```bash
bats tests/init/test_ssf_init_zero_touch.bats
```

预期：7 PASS。

- [ ] **Step 5: 重写 `commands/ssf-init.md`**

整体替换为：

```markdown
Initialize SuperSpecFlow opt-in for the current project (zero-touch host integration).

Argument: $ARGUMENTS

This command is a project opt-in action. It creates `.superspecflow/` in the current project and **must not** modify the host project's `AGENTS.md` or `CLAUDE.md`.

Steps:

1. Confirm the current working directory is the project to opt in.
2. Locate the SuperSpecFlow pack root. Prefer the directory that contains `routing/CLAUDE.global.md`, `routing/AGENTS.global.md`, `commands/`, `skills/`, and `agents/`.
3. Run the contract script:

   ```bash
   bash <pack>/scripts/_ssf_init_apply.sh
   ```

   This creates:
   - `.superspecflow/enabled` (sentinel, empty file)
   - `.superspecflow/{decisions,retro,qa,reviews,karpathy,maps,ship}/` (产物子目录)
   - `.superspecflow/progress/` (占位，保持空，由后续 progress-tracking change 定义)

4. **Do not** create `.superspecflow/CLAUDE.routing.md`, `.superspecflow/AGENTS.routing.md`, or `.superspecflow/templates`. These are reserved for **optional** project-level overrides; users add them only when they want to override the global default routing.
5. **Do not** edit the host `CLAUDE.md` or `AGENTS.md`. If the user wants global activation, point them at `scripts/install-global.sh`. If they want project-only activation without global install, they may manually add `@<pack>/routing/CLAUDE.global.md` to their project's `CLAUDE.md` themselves.
6. Print the next-step guidance produced by the contract script.

Notes:

- Explicit `/ssf-*` commands work regardless of whether `.superspecflow/` exists; they are one-off actions and do not implicitly create the sentinel.
- Re-running `/ssf-init` is idempotent: existing subdirectory contents are preserved.
- For legacy compatibility, `scripts/install-project-symlinks.sh` still works and creates the older symlink-based layout. New users should prefer `/ssf-init` + `scripts/install-global.sh`.
```

- [ ] **Step 6: 再跑一次测试确认未回归**

```bash
bats tests/init/test_ssf_init_zero_touch.bats
```

预期：7 PASS（行为不变）。

- [ ] **Step 7: Commit**

```bash
git add commands/ssf-init.md scripts/_ssf_init_apply.sh tests/init/
git commit -m "$(cat <<'EOF'
feat(commands): 重写 /ssf-init 为零侵入语义并新增契约脚本

变更编号：zero-touch-host-integration
关联规格：docs/superpowers/specs/2026-05-23-zero-touch-host-integration-design.md（5.3）

变更内容：
- 整体重写 commands/ssf-init.md：不再创建软链，只创建 .superspecflow/enabled + 7 个产物子目录 + progress/ 占位
- 新增 scripts/_ssf_init_apply.sh 作为 ssf-init.md 的副作用契约脚本，便于 bats 测试
- 新增 tests/init/test_ssf_init_zero_touch.bats 覆盖 7 个契约（enabled / 子目录 / progress 空 / 不创建 routing / 不改宿主指令文件 / 幂等）

验证方式：
- bats tests/init/test_ssf_init_zero_touch.bats（7 PASS）

风险与回滚：
- 风险：老用户习惯 /ssf-init 创建软链，行为变化需在 docs/installation.md 中说明；scripts/install-project-symlinks.sh 仍保留为兼容方案
- 回滚：git revert 本提交；老路径 install-project-symlinks.sh 不受影响
EOF
)"
```

---

### Task 6: 全局安装脚本

**Files:**
- Create: `scripts/install-global.sh`
- Create: `tests/install/test_install_global.bats`

**目标**：实现 5.4。只做检测 + 提示，**不擅自**改写用户 `~/.claude/CLAUDE.md` / `~/.codex/AGENTS.md` / `~/.claude/settings.json`。仅在用户全局文件**完全不存在**时可创建。

- [ ] **Step 1: 写失败测试**

`tests/install/test_install_global.bats`：

```bash
#!/usr/bin/env bats

load '../lib/test_helper'

setup() {
  HOME_DIR="$(ssf_make_tmp_home)"
  INSTALL="$REPO_ROOT/scripts/install-global.sh"
  # 隔离用户环境
  export HOME="$HOME_DIR"
  rm -rf "$HOME_DIR/.claude" "$HOME_DIR/.codex"
}

teardown() {
  ssf_cleanup_tmp "$HOME_DIR"
}

@test "首次运行：~/.claude/CLAUDE.md 不存在时直接创建并写入 include 行" {
  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]
  [ -f "$HOME/.claude/CLAUDE.md" ]
  grep -q "routing/CLAUDE.global.md" "$HOME/.claude/CLAUDE.md"
}

@test "首次运行：~/.codex/AGENTS.md 不存在时直接创建并写入 include 行" {
  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]
  [ -f "$HOME/.codex/AGENTS.md" ]
  grep -q "routing/AGENTS.global.md" "$HOME/.codex/AGENTS.md"
}

@test "已有 CLAUDE.md 且已含 include 行：脚本跳过，文件不变" {
  mkdir -p "$HOME/.claude"
  printf 'EXISTING\n@%s/routing/CLAUDE.global.md\n' "$REPO_ROOT" > "$HOME/.claude/CLAUDE.md"
  before="$(cat "$HOME/.claude/CLAUDE.md")"
  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.claude/CLAUDE.md")" = "$before" ]
}

@test "已有 CLAUDE.md 但缺 include 行：脚本不擅自改写，打印应追加的行" {
  mkdir -p "$HOME/.claude"
  printf 'EXISTING\n' > "$HOME/.claude/CLAUDE.md"
  before="$(cat "$HOME/.claude/CLAUDE.md")"
  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.claude/CLAUDE.md")" = "$before" ]
  [[ "$output" == *"@${REPO_ROOT}/routing/CLAUDE.global.md"* ]]
  [[ "$output" == *"请手动追加"* || "$output" == *"manually append"* ]]
}

@test "--no-hook 时不打印 hook 配置片段" {
  run "$INSTALL" --yes --no-hook
  [ "$status" -eq 0 ]
  [[ "$output" != *"session-start-detect.sh"* ]]
}

@test "默认（带 hook）打印 settings.json 应合并的官方 schema JSON 片段，且不擅自改写" {
  mkdir -p "$HOME/.claude"
  printf '{}' > "$HOME/.claude/settings.json"
  before="$(cat "$HOME/.claude/settings.json")"
  run "$INSTALL" --yes
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.claude/settings.json")" = "$before" ]
  # 官方 hook schema 关键字段必须全部出现
  [[ "$output" == *"session-start-detect.sh"* ]]
  [[ "$output" == *"SessionStart"* ]]
  [[ "$output" == *"matcher"* ]]
  [[ "$output" == *"\"type\": \"command\""* ]] || [[ "$output" == *"\"type\":\"command\""* ]]
}

@test "退出码恒为 0（脚本不应因用户拒绝合并而失败）" {
  mkdir -p "$HOME/.claude"
  printf 'EXISTING\n' > "$HOME/.claude/CLAUDE.md"
  run "$INSTALL" --yes
  [ "$status" -eq 0 ]
}
```

注意：测试用 `--yes` 取代交互式 prompt，用 `--no-hook` 跳过 hook 部分。脚本要支持这两个 flag。

- [ ] **Step 2: 跑测试确认全部失败**

```bash
bats tests/install/test_install_global.bats
```

预期：7 FAIL（脚本不存在）。

- [ ] **Step 3: 实现 `scripts/install-global.sh`**

```bash
#!/usr/bin/env bash
# SuperSpecFlow 全局安装脚本（方案 C 推荐入口）
# 只做检测 + 提示。绝不擅自改写用户已存在的全局指令文件 / settings.json。

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ASSUME_YES=0
SKIP_HOOK=0

usage() {
  cat <<MSG
Usage: install-global.sh [--yes] [--no-hook]

Options:
  --yes      Skip interactive confirmation prompts.
  --no-hook  Skip Claude Code SessionStart hook setup.
MSG
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --yes) ASSUME_YES=1; shift ;;
    --no-hook) SKIP_HOOK=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown arg: $1" >&2; usage >&2; exit 1 ;;
  esac
done

confirm() {
  if [ "$ASSUME_YES" -eq 1 ]; then return 0; fi
  read -r -p "$1 [y/N] " ans
  [ "$ans" = "y" ] || [ "$ans" = "Y" ]
}

ensure_include() {
  local target="$1"          # ~/.claude/CLAUDE.md 或 ~/.codex/AGENTS.md
  local include_path="$2"    # routing/CLAUDE.global.md 或 routing/AGENTS.global.md
  local include_line="@${REPO_ROOT}/${include_path}"

  if [ ! -e "$target" ]; then
    mkdir -p "$(dirname "$target")"
    printf '%s\n' "$include_line" > "$target"
    echo "✓ created $target with SuperSpecFlow include"
    return 0
  fi

  if grep -Fq "$include_line" "$target"; then
    echo "= $target already includes SuperSpecFlow, skipped"
    return 0
  fi

  cat <<MSG

⚠ $target 已存在，但未包含 SuperSpecFlow include 行。
请手动追加（manually append）下面这一行到该文件靠前位置：

  $include_line

脚本不会擅自改写已有的用户全局指令文件。
MSG
  return 0
}

ensure_include "$HOME/.claude/CLAUDE.md" "routing/CLAUDE.global.md"
ensure_include "$HOME/.codex/AGENTS.md" "routing/AGENTS.global.md"

if [ "$SKIP_HOOK" -eq 0 ]; then
  hook_path="${REPO_ROOT}/scripts/hooks/session-start-detect.sh"
  cat <<MSG

—— 可选：Claude Code SessionStart hook ——
建议在 ~/.claude/settings.json 中合并以下片段（使用 Claude Code 官方 hook schema），
让会话启动时自动检测项目 opt-in：

{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {"type": "command", "command": "${hook_path}"}
        ]
      }
    ]
  }
}

脚本不会擅自改写 settings.json。若该文件不存在，可直接创建并仅包含上述内容。
MSG
fi

echo
echo "Done."
exit 0
```

赋可执行权限：

```bash
chmod +x scripts/install-global.sh
```

- [ ] **Step 4: 跑测试确认全部通过**

```bash
bats tests/install/test_install_global.bats
```

预期：7 PASS。

- [ ] **Step 5: Commit**

```bash
git add scripts/install-global.sh tests/install/
git commit -m "$(cat <<'EOF'
feat(scripts): 新增全局安装脚本 install-global.sh

变更编号：zero-touch-host-integration
关联规格：docs/superpowers/specs/2026-05-23-zero-touch-host-integration-design.md（5.4）

变更内容：
- 新增 scripts/install-global.sh：检测 ~/.claude/CLAUDE.md 与 ~/.codex/AGENTS.md 是否已含 include 行，未含且文件存在时仅打印提示，文件完全不存在时才直接创建
- 默认输出 Claude Code SessionStart hook 应合并到 ~/.claude/settings.json 的 JSON 片段；--no-hook 可跳过
- 全程不擅自改写用户已存在的全局文件，退出码恒为 0
- 新增 7 个 bats 测试覆盖：首次创建 / 已含 include 行 / 缺 include 行 / --no-hook / 默认带 hook（断言官方 schema 含 matcher 与 type:command）/ 不修改 settings.json / 退出码

验证方式：
- bats tests/install/test_install_global.bats（7 PASS）

风险与回滚：
- 风险：用户全局文件包含 BOM 或非 UTF-8 编码时 grep 行为差异；目前依赖 -F 字面匹配，已尽量稳健
- 回滚：rm scripts/install-global.sh tests/install/ 并 revert
EOF
)"
```

---

### Task 7: 更新 `docs/installation.md`

**Files:**
- Modify: `docs/installation.md`

**目标**：新增 §2 "推荐：方案 C 零侵入接入"；原 §2 "推荐安装：软连接入"降级为 §3 "兼容方案：项目软连接入"；后续章节号顺移；§6 烟测增加针对方案 C 的步骤。

**重要**：只改本章节的章节号与新增方案 C 内容，不要顺手重写其他文字。

- [ ] **Step 1: 读取当前 docs/installation.md，确认章节结构**

```bash
grep -nE "^## " docs/installation.md
```

记录现有 §0~§8 的行号。

- [ ] **Step 2: 用 Edit 工具在 §1 之后插入新 §2**

在 `## 2. 推荐安装：软连接入` 之前插入：

```markdown
## 2. 推荐：方案 C 零侵入接入

方案 C 让宿主项目的 `CLAUDE.md` / `AGENTS.md` 零改动即可启用 SuperSpecFlow。一次性全局安装，按项目 opt-in。

### 2.1 全局安装一次

在 SuperSpecFlow 仓库中执行：

```bash
./scripts/install-global.sh
```

脚本会：

- 检测 `~/.claude/CLAUDE.md`：不存在则创建并写入 `@<pack>/routing/CLAUDE.global.md`；存在则只打印应追加的行，不擅自改写。
- 同样规则处理 `~/.codex/AGENTS.md`。
- 询问是否启用 Claude Code SessionStart hook（推荐）。同意后打印应合并到 `~/.claude/settings.json` 的 JSON 片段，不擅自改写。

### 2.2 给某个项目 opt-in

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
├── decisions/              # /ssf-decision 产物
├── retro/                  # /ssf-retro 产物
├── qa/                     # QA signoff
├── reviews/                # /ssf-review 报告
├── karpathy/               # /ssf-karpathy 报告
├── maps/                   # spec-to-code-map.md
├── ship/                   # release notes、rollback plan
└── progress/               # 占位，由后续 progress-tracking change 定义
```

`/ssf-init` **不**修改宿主项目的 `CLAUDE.md` / `AGENTS.md`。

### 2.3 项目级 routing 覆盖（可选）

如果某个项目想覆盖全局默认 routing，可在该项目里手动创建：

```text
.superspecflow/CLAUDE.routing.md
.superspecflow/AGENTS.routing.md
```

它们的内容会替代全局 routing 主体。默认不需要这两个文件。

### 2.4 工作原理

- 全局 routing 薄壳 `routing/CLAUDE.global.md` 在会话启动时执行 opt-in 自检测：
  - 优先读取 Claude Code SessionStart hook 注入的 `<ssf-status>` 标签（C3 加成）。
  - 否则在会话内执行一次 Bash：`test -f .superspecflow/enabled`（C1 兜底）。
- 状态 = enabled：启用 Intake Gate。
- 状态 = disabled：不接管自然语言，但 `/ssf-*` 显式命令始终可用。

```

接着把原 `## 2. 推荐安装：软连接入` 改为 `## 3. 兼容方案：项目软连接入`，并在该章节顶部加一行：

```markdown
> 老用户兼容路径。新用户优先使用上一节方案 C。
```

后续 §3 / §4 / §5 / §6 / §7 / §8 章节标题分别顺移为 §4 / §5 / §6 / §7 / §8 / §9。`§6.X` 烟测子节内的章节号同步顺移。

- [ ] **Step 3: 在新的烟测章节追加方案 C 烟测**

在烟测章节末尾追加：

```markdown
### X.Y 方案 C 烟测

```bash
# 在临时项目里验证 opt-in 信号
TMP=$(mktemp -d)
cd "$TMP"
bash <pack>/scripts/_ssf_init_apply.sh
test -f .superspecflow/enabled && echo "OK: opt-in 信号已写入"

# 验证 hook 脚本
bash <pack>/scripts/hooks/session-start-detect.sh
# 期望输出: <ssf-status>enabled</ssf-status>

cd /tmp
bash <pack>/scripts/hooks/session-start-detect.sh
# 期望输出: <ssf-status>disabled</ssf-status>
```
```

- [ ] **Step 4: 用 git diff 复核改动只在这三处**

```bash
git diff docs/installation.md | head -200
```

如果出现非预期 hunk，立刻 `git checkout -- docs/installation.md` 重做。

- [ ] **Step 5: Commit**

```bash
git add docs/installation.md
git commit -m "$(cat <<'EOF'
docs(installation): 新增方案 C 零侵入接入章节并将软连方案降级为兼容路径

变更编号：zero-touch-host-integration
关联规格：docs/superpowers/specs/2026-05-23-zero-touch-host-integration-design.md（5.3 / 5.4 / 7 兼容性）

变更内容：
- 新增 §2"推荐：方案 C 零侵入接入"，覆盖全局安装、项目 opt-in、可选覆盖、工作原理
- 原§2"推荐安装：软连接入"降级为§3"兼容方案：项目软连接入"，章节号整体顺移
- §6 烟测追加方案 C 验证步骤

验证方式：
- git diff 复核只触及新增章节、章节号顺移与新增烟测三处
- 阅读全文确认与 spec 第 4 节架构一致

风险与回滚：
- 风险：章节号顺移影响外部链接锚点；本仓库内未发现引用 §2/§3 锚点的链接
- 回滚：git revert 本提交
EOF
)"
```

---

### Task 8: 更新 `README.md` 接入指引

**Files:**
- Modify: `README.md`

**目标**：把 README 顶部"如何接入"那段指向方案 C；保留软连方案作为"兼容方案"备注。

**严格约束**：只动接入指引这一段；不改 README 其他部分。

- [ ] **Step 1: 定位接入指引段**

```bash
grep -nE "install|接入|安装|installation" README.md | head -20
```

确认要改的行号范围。

- [ ] **Step 2: 用 Edit 工具替换该段**

替换原"接入"段落为：

```markdown
## 接入

推荐方案：方案 C 零侵入接入，宿主项目 `CLAUDE.md` / `AGENTS.md` 零改动。

```bash
# 一次性全局安装
./scripts/install-global.sh

# 进入要 opt-in 的项目，执行
/ssf-init
```

详见 [docs/installation.md §2](docs/installation.md)。

兼容方案：[docs/installation.md §3](docs/installation.md)（项目软连接入，老用户路径）。
```

- [ ] **Step 3: 复核 diff**

```bash
git diff README.md
```

确认只动了接入段。

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "$(cat <<'EOF'
docs(meta): README 接入指引指向方案 C 零侵入接入

变更编号：zero-touch-host-integration
关联规格：docs/superpowers/specs/2026-05-23-zero-touch-host-integration-design.md

变更内容：
- README 接入段重写：推荐 install-global.sh + /ssf-init 两步走
- 兼容方案链接保留指向 docs/installation.md §3

验证方式：
- git diff README.md 仅触及接入段

风险与回滚：
- 风险：链接锚点失效；docs/installation.md 中 §2/§3 标题已与本段一致
- 回滚：git revert 本提交
EOF
)"
```

---

### Task 9: 扩展 `scripts/validate-pack.sh`

**Files:**
- Modify: `scripts/validate-pack.sh`

**目标**：让自检脚本覆盖本次新增的所有结构契约。**只追加新检查项，不重写既有逻辑。**

要新加的断言：

1. `routing/CLAUDE.global.md` 存在
2. `routing/CLAUDE.global.md` **不**包含 `@<repo>/routing/CLAUDE.routing.md` 自动 include 行（防止退回 @ 自动展开导致 disabled 失效）
3. `routing/CLAUDE.global.md` 包含指令式条件读取关键字（如 `主动用 Read 工具读取` 或 `主动读取`）
4. `routing/AGENTS.global.md` 同 1-3
5. `scripts/hooks/session-start-detect.sh` 存在且可执行
6. `scripts/install-global.sh` 存在且可执行
7. `scripts/_ssf_init_apply.sh` 存在且可执行
8. `routing/CLAUDE.routing.md` 含一段以 `## 高风险关键词` 开头的清单，且包含字串 `登录、认证`
9. `routing/AGENTS.routing.md` 同上
10. 高风险关键词清单与项目根 `CLAUDE.md` 一致性检查：grep 出现次数 ≥ 1，且两 routing 文件的清单文本与根 CLAUDE.md 完全一致（防止后续漂移）
11. `commands/ssf-init.md` **不**包含字符串 `ln -s`（防止退回到老软链语义）

- [ ] **Step 1: 读现有 validate-pack.sh 找到追加点**

```bash
grep -n "^# " scripts/validate-pack.sh | head -20
```

找一个"现有检查块结尾"作为追加位置。

- [ ] **Step 2: 追加新检查块**

在脚本临近 `if [ "$FAILED" -ne 0 ]` 之前插入：

```bash
# ---- 方案 C 零侵入接入结构契约 ----

# 全局 routing 薄壳存在且采用指令式条件读取，禁止 @ 自动 include 写法
for pair in "routing/CLAUDE.global.md:CLAUDE.routing.md" "routing/AGENTS.global.md:AGENTS.routing.md"; do
  global="${pair%%:*}"
  main="${pair##*:}"
  if [ ! -f "$global" ]; then
    fail "missing $global"
    continue
  fi
  # 必不含 @ 自动 include 写法（行首 @<repo>/routing/*.routing.md）
  if grep -E "^@<repo>/routing/${main}" "$global" >/dev/null; then
    fail "$global must not use @ auto-include for $main (breaks disabled-state opt-out)"
  else
    pass "$global free of @ auto-include for $main"
  fi
  # 必含指令式条件读取关键字
  if grep -q "主动用 Read 工具读取\|主动读取" "$global"; then
    pass "$global uses instruction-style conditional read"
  else
    fail "$global missing instruction-style conditional read for $main"
  fi
done

# 脚本存在并可执行
for f in scripts/hooks/session-start-detect.sh scripts/install-global.sh scripts/_ssf_init_apply.sh; do
  if [ ! -x "$f" ]; then
    fail "$f missing or not executable"
  else
    pass "$f executable"
  fi
done

# 高风险关键词清单已同步到 routing 主体
for f in routing/CLAUDE.routing.md routing/AGENTS.routing.md; do
  if ! grep -q "^## 高风险关键词" "$f"; then
    fail "$f missing 高风险关键词 section"
  elif ! grep -Fq "登录、认证" "$f"; then
    fail "$f 高风险关键词 section missing 登录、认证"
  else
    pass "$f 高风险关键词 section OK"
  fi
done

# 清单文本与根 CLAUDE.md 严格一致（防漂移）
canonical="$(sed -n '/^## 高风险关键词/,/^## /p' CLAUDE.md | sed '$d')"
for f in routing/CLAUDE.routing.md routing/AGENTS.routing.md; do
  candidate="$(sed -n '/^## 高风险关键词/,/^## /p' "$f" | sed '$d')"
  if [ "$canonical" != "$candidate" ]; then
    fail "$f 高风险关键词 section drifted from CLAUDE.md"
  else
    pass "$f 高风险关键词 section in sync with CLAUDE.md"
  fi
done

# ssf-init.md 不能退回到老软链语义
if grep -Fq "ln -s" commands/ssf-init.md; then
  fail "commands/ssf-init.md still uses ln -s (zero-touch must not symlink routing)"
else
  pass "commands/ssf-init.md zero-touch semantics OK"
fi
```

- [ ] **Step 3: 跑自检确认全部通过**

```bash
bash scripts/validate-pack.sh
```

预期：本任务新增的所有 PASS 行出现，无 FAIL。

- [ ] **Step 4: 模拟失败回归测试（手动验证）**

```bash
# 故意在 global routing 里塞一行 @ 自动 include 写法，验证 FAIL 触发
cp routing/CLAUDE.global.md /tmp/_bak
printf '\n@<repo>/routing/CLAUDE.routing.md\n' >> routing/CLAUDE.global.md
bash scripts/validate-pack.sh && echo "BUG: should have failed" || echo "OK: failure path works"
mv /tmp/_bak routing/CLAUDE.global.md
bash scripts/validate-pack.sh  # 恢复后再确认通过
```

预期：故意破坏时输出 `OK: failure path works`；恢复后再次全部 PASS。

- [ ] **Step 5: Commit**

```bash
git add scripts/validate-pack.sh
git commit -m "$(cat <<'EOF'
test(scripts): validate-pack 覆盖方案 C 零侵入接入的结构契约

变更编号：zero-touch-host-integration
关联规格：docs/superpowers/specs/2026-05-23-zero-touch-host-integration-design.md（9.1）

变更内容：
- 在 scripts/validate-pack.sh 追加 11 条结构断言：全局 routing 文件存在且**不**含 @ 自动 include 写法 / 全局 routing 含指令式条件读取关键字 / 三个脚本可执行 / 高风险关键词清单已同步且与根 CLAUDE.md 一致 / ssf-init.md 不退回 ln -s 语义
- 不重写既有检查逻辑

验证方式：
- bash scripts/validate-pack.sh（新增 PASS 行出现，无 FAIL）
- 手动模拟在 global routing 里塞入 @ 自动 include 行：确认 FAIL 触发；恢复后 PASS

风险与回滚：
- 风险：高风险关键词一致性 sed 块对中文标点敏感；当前 CLAUDE.md 与 routing 主体使用同一组中文标点，无差异
- 回滚：git revert 本提交
EOF
)"
```

---

### Task 10: 端到端 smoke

**Files:**
- Create: `tests/e2e/test_zero_touch_flow.bats`

**目标**：在临时 HOME + 临时 project 环境里串起来跑一遍，验证三件事：

1. 全局安装 → 项目 opt-in → hook 输出 enabled
2. 未 opt-in 项目 → hook 输出 disabled
3. 所有过程中宿主 CLAUDE.md / AGENTS.md 零改动

- [ ] **Step 1: 写端到端测试**

`tests/e2e/test_zero_touch_flow.bats`：

```bash
#!/usr/bin/env bats

load '../lib/test_helper'

setup() {
  HOME_DIR="$(ssf_make_tmp_home)"
  PROJECT="$(ssf_make_tmp_project)"
  export HOME="$HOME_DIR"
  rm -rf "$HOME/.claude" "$HOME/.codex"
}

teardown() {
  ssf_cleanup_tmp "$HOME_DIR"
  ssf_cleanup_tmp "$PROJECT"
}

@test "端到端：全局安装 → opt-in → hook 输出 enabled" {
  bash "$REPO_ROOT/scripts/install-global.sh" --yes --no-hook
  [ -f "$HOME/.claude/CLAUDE.md" ]
  [ -f "$HOME/.codex/AGENTS.md" ]

  cd "$PROJECT"
  SSF_INIT_PROJECT_DIR="$PROJECT" bash "$REPO_ROOT/scripts/_ssf_init_apply.sh"
  [ -f "$PROJECT/.superspecflow/enabled" ]

  run bash "$REPO_ROOT/scripts/hooks/session-start-detect.sh"
  [ "$output" = "<ssf-status>enabled</ssf-status>" ]
}

@test "端到端：未 opt-in 项目 → hook 输出 disabled" {
  cd "$PROJECT"
  run bash "$REPO_ROOT/scripts/hooks/session-start-detect.sh"
  [ "$output" = "<ssf-status>disabled</ssf-status>" ]
}

@test "端到端：opt-in 后宿主 CLAUDE.md / AGENTS.md 仍然零改动" {
  cd "$PROJECT"
  # 模拟宿主已有指令文件
  printf 'HOST-CLAUDE\n' > CLAUDE.md
  printf 'HOST-AGENTS\n' > AGENTS.md

  SSF_INIT_PROJECT_DIR="$PROJECT" bash "$REPO_ROOT/scripts/_ssf_init_apply.sh"

  [ "$(cat CLAUDE.md)" = "HOST-CLAUDE" ]
  [ "$(cat AGENTS.md)" = "HOST-AGENTS" ]
}
```

- [ ] **Step 2: 跑测试确认全部通过**

```bash
bats tests/e2e/test_zero_touch_flow.bats
```

预期：3 PASS。

- [ ] **Step 3: 跑全量 bats**

```bash
bats tests/
```

预期：全部 PASS（含前面所有 task 的测试）。

- [ ] **Step 4: 跑全量 validate-pack**

```bash
bash scripts/validate-pack.sh
```

预期：通过，无 FAIL。

- [ ] **Step 5: Commit**

```bash
git add tests/e2e/
git commit -m "$(cat <<'EOF'
test(tests): 端到端 smoke 串起方案 C 零侵入接入完整路径

变更编号：zero-touch-host-integration
关联规格：docs/superpowers/specs/2026-05-23-zero-touch-host-integration-design.md（9.1 全部场景）

变更内容：
- 新增 tests/e2e/test_zero_touch_flow.bats 覆盖三个场景：全局安装→opt-in→hook enabled / 未 opt-in→hook disabled / opt-in 后宿主指令文件零改动
- 全测试在隔离的临时 HOME 与临时 project 下运行，不污染用户环境

验证方式：
- bats tests/e2e/test_zero_touch_flow.bats（3 PASS）
- bats tests/（全量 PASS）
- bash scripts/validate-pack.sh（全量 PASS）

风险与回滚：
- 风险：端到端测试依赖 install-global.sh、_ssf_init_apply.sh、session-start-detect.sh 的契约稳定性；任一改动需先看本测试是否需要同步更新
- 回滚：rm -rf tests/e2e/ 并 revert
EOF
)"
```

---

## 4. 完成定义

按本仓库 `CLAUDE.md` "完成定义"对照：

- [ ] OpenSpec tasks 更新：本计划在 ssf-spec 阶段后由后续 change 在 `openspec/changes/zero-touch-host-integration/tasks.md` 中维护
- [ ] spec-to-code-map 更新：在最终一个 commit 时由实施者补到 `.superspecflow/maps/spec-to-code-map.md`（若尚未存在则创建）
- [ ] 所有 bats 测试通过：`bats tests/` 全量 PASS
- [ ] validate-pack 通过：`bash scripts/validate-pack.sh` 全量 PASS
- [ ] Git commit 标题与正文符合规范：每个 Task 的 commit 模板已给出
- [ ] PR 内容为中文
- [ ] rollback 说明完整：每个 commit 正文均含"风险与回滚"段
- [ ] QA signoff：写入 `.superspecflow/qa/zero-touch-host-integration.md`（由 ssf-qa 阶段产生）

## 5. 不在本计划范围

- `.superspecflow/progress/` 内部结构（留给 `progress-tracking` change）
- Claude ↔ Codex 跨 CLI 互验（留给 `cross-agent-verification` change）
- ssf-* skills / agents 中 `openspec/` 路径迁移（明确不动）
- `scripts/install-project-symlinks.sh` 行为变化（明确不动，保持兼容）
- `update.sh` 行为变化（明确不动）

## 6. Skill 参考

- `@superpowers:test-driven-development` —— 每个 task 都严格 RED → GREEN → COMMIT
- `@superpowers:verification-before-completion` —— 标记 task 完成前必须实际执行验证命令并看到预期输出
- `@superpowers:subagent-driven-development` 或 `@superpowers:executing-plans` —— 由执行者按任务顺序推进
