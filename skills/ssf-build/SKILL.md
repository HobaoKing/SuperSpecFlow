---
name: ssf-build
description: 阶段三（建）。用户输入 /ssf-build 或由 ssf-spec 续接时触发。按 OpenSpec tasks 执行，使用 Superpowers 风格：理解、计划、TDD、小步实现、验证、更新 spec-to-code-map。
---

# ssf-build — 按规格执行

## 目标

从 OpenSpec change contract 到可验证实现。

本阶段体现 Superpowers 的价值：AI 不凭感觉写代码，而是先理解、再计划、再写失败测试、再最小实现、再验证。

## 触发

- 显式：`/ssf-build`、`/ssf-build all`、`/ssf-build N`
- 隐式：用户要求实现、修 bug、加 API、重构、根据 spec 开发
- 自动：`ssf-spec` readiness 为 Ready 后续接

## 前置条件

如果没有可用 OpenSpec change，先暂停并要求提供 change-id，或进入 `ssf-spec`。

## 强制规则

- 没有 Spec ID，不做行为变更。
- 没有任务映射，不改代码。
- 优先 TDD：能写测试的行为先写失败测试。
- 不做 OpenSpec 之外的功能。
- 发现范围偏差，暂停，不自行扩展。
- 每完成一个 task，更新 tasks.md。
- 宿主项目运行时工程产物写入 `.superspecflow/engineering/<change-id>/`。
- 宿主项目运行时 spec-to-code map 写入 `.superspecflow/maps/<change-id>/spec-to-code-map.md`。
- 如果是在 SuperSpecFlow 本仓库实现包源码变更，工程交付物保留在 `engineering/<change-id>/spec-to-code-map.md`，该路径可提交且不得视为运行时产物。
- 读取运行时工程产物时使用 new path first：先读 `.superspecflow/engineering/<change-id>/` 和 `.superspecflow/maps/<change-id>/`，缺失时 fallback 到兼容期旧路径。
- 如果宿主项目存在或需要创建 progress 状态，维护 `.superspecflow/progress/<change-id>/state.json`、`timeline.md`、`verification.md` 和 `handoff.md`。
- 中断、上下文压缩或换 agent 后恢复已有 change 时，先读取 `.superspecflow/progress/<change-id>/state.json` 和 `handoff.md`，再读取 OpenSpec。
- 声称 task、阶段或 change 完成前，必须在 `.superspecflow/progress/<change-id>/verification.md` 写入或引用 fresh verification。

## Step 1 — Implementation Plan

宿主项目默认输出到 `.superspecflow/engineering/<change-id>/implementation-plan.md`；SuperSpecFlow 本仓库包源码实现可把工程交付物写入 `engineering/<change-id>/`。

implementation-plan.md 必须按以下 6 个子节生成。代码示例和命令使用宿主项目的语言、测试框架和包管理工具，不预设 Python/JS/TS 等。

### 1.1 Plan Header

```markdown
# Implementation Plan: [change-id]

**Goal:** [一句话目标]

**Architecture:** [2-3 句架构方向]

**Spec Contract:** `openspec/changes/<change-id>/specs/`

**Tech Stack:** [关键技术、库、版本]

---
```

### 1.2 Scope Check

```markdown
## Scope Check

- In scope:
  - ...
- Out of scope:
  - ...
```

如果范围涉及多个相互独立的子系统，停下来建议拆 sub-plans（参考 superpowers:writing-plans 的 Scope Check），不要硬塞进一份 plan。

### 1.3 File Structure

```markdown
## File Structure

- Create: `path/to/new-file.ext` — [单一职责，一句话]
- Modify: `path/to/existing.ext` — [本次变更职责]
- Test: `tests/path/file.test.ext` — [测试覆盖范围]
```

先锁定文件边界再拆任务。每个文件应有单一职责；变更聚集的文件归到同一个 task。

### 1.4 Bite-Sized Tasks

每个 task 必须包含 5 个 bite-sized 步骤（每步 2-5 分钟）。代码块给出可直接 copy-paste 的完整内容，禁止「添加验证逻辑」这类抽象描述。

```markdown
### Task N: [Component Name]

**Spec:** [SPEC-ID]

**Files:**
- Create: `path/to/file.ext`
- Modify: `path/to/existing.ext:行号范围`
- Test: `tests/path/file.test.ext`

- [ ] **Step 1: 写失败测试**

  [完整测试代码，宿主项目语言，可直接 copy-paste]

- [ ] **Step 2: 跑测试确认失败**

  Run: `<宿主项目测试命令，含具体路径和断言点>`
  Expected: FAIL with "<具体错误信息>"

- [ ] **Step 3: 写最小实现**

  [完整实现代码，宿主项目语言，可直接 copy-paste]

- [ ] **Step 4: 跑测试确认通过**

  Run: `<同 Step 2>`
  Expected: PASS

- [ ] **Step 5: 准备 Git gate**

  ```bash
  git status --short
  git diff --stat
  git diff --check
  git add tests/path/file.test.ext path/to/file.ext
  git diff --staged --stat
  git diff --staged --check
  ```

  然后进入 `/ssf-commit [change-id]`，不得在 implementation plan 中直接提交。
```

强制约束：

- 每个 task 必须有且只有一个 `**Spec:**` 字段引用 SPEC-ID
- Step 1 和 Step 3 的代码块必须完整可执行，禁止 `...` 省略或抽象描述
- Step 2 和 Step 4 的测试命令必须含具体路径和断言点，禁止「运行测试」这类抽象表述
- Step 5 只能准备 Git gate，commit 消息由 `/ssf-commit` 生成并检查
- 模板和生成计划必须保留 `Bite-Sized Tasks`、`Plan Review Loop` 和 `Execution Handoff` 标题，便于 Superpowers writing-plans 契约验证。

### 1.5 Plan Review Loop

implementation-plan.md 完整写出后，使用可用的 Agent tool 或 reviewer prompt 评审：

- Reviewer prompt：优先使用宿主环境已安装的 Superpowers `plan-document-reviewer-prompt.md`；如果不可定位，不得猜测固定 Claude plugin cache path。
- 传给子代理：
  - Plan 路径
  - Spec contract 路径（`openspec/changes/<change-id>/specs/`）
- 循环：
  - ✅ Approved → 进入 1.6
  - ❌ Issues Found → 修复后重新 dispatch，最多 3 轮
  - 超过 3 轮 → 交人工裁决

注意：reviewer prompt 是英文，针对 superpowers 单一 plan 结构。读中文 plan 和 OpenSpec SPEC-ID 时反馈仍有参考价值，但可能漏检项目特定约束。连续两轮出现明显不适配（例如要求把 SPEC-ID 删掉、不识别中文 commit 模板）时，记录 follow-up，跳过本步并恢复人工审阅。

如果 reviewer prompt、Agent tool 或宿主环境不可用，不得静默跳过；必须在 implementation plan 的 `Blocked / Waived Evidence` 记录 `Reviewer prompt unavailable`、原因、残余风险和人工替代检查。

### 1.6 Execution Handoff

plan 评审通过后，二选一进入 Step 4 执行任务：

- **Subagent-Driven（推荐）**：每个 task 由新鲜 subagent 执行（参考 superpowers:subagent-driven-development），上下文干净、迭代快、可二阶段评审
- **Inline**：在本会话内 batch 执行（参考 superpowers:executing-plans），含 checkpoint 评审

明确告诉用户选哪种、为什么，然后进入 Step 4。

## Step 2 — Spec-to-Code Map

宿主项目默认输出到 `.superspecflow/maps/<change-id>/spec-to-code-map.md`；SuperSpecFlow 本仓库包源码实现保留 `engineering/<change-id>/spec-to-code-map.md`。

```markdown
# Spec to Code Map: [change-id]

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SPEC-001 | ... | ... | ... | Planned |
```

## Step 3 — Progress Tracking

如果 `.superspecflow/progress/<change-id>/` 存在，或本次工作会持续超过一个可验证 task，使用 progress 协议记录运行状态：

```text
.superspecflow/progress/<change-id>/
  state.json
  timeline.md
  verification.md
  handoff.md
```

模板来源：

```text
templates/progress-state.json
templates/progress-timeline.md
templates/progress-verification.md
templates/progress-handoff.md
```

规则：

1. 开始或切换 task 时更新 `state.json`，并在 `timeline.md` 追加事件。
2. 运行测试、静态检查、烟测或人工检查后，在 `verification.md` 记录范围、命令或方法、结果和输出摘要。
3. `state.json.last_verification` 必须引用最近相关验证记录。
4. 准备停止且仍有 meaningful work remains 时更新 `handoff.md`。
5. fresh verification 必须晚于本次声明覆盖范围内的最新相关变更。

## Step 3.5 — Spec Cluster Execution

如果当前 change 属于 parent change 下的 Spec cluster：

1. 先读取 `.superspecflow/clusters/<parent-change>/cluster-plan.md`。
2. 确认当前 cluster 的 Spec IDs、worktree path、branch、依赖和 QA expectations。
3. 每完成 build、review、QA、commit 或遇到 blocker，更新 `.superspecflow/clusters/<parent-change>/cluster-status.md`。
4. 每个 cluster 仍必须独立维护 tasks、spec-to-code map、review、QA 和 Git evidence。
5. Worktree 只作为执行隔离机制，不得被当作发布边界。

## Step 4 — 执行任务

`/ssf-build all`：逐条执行。
`/ssf-build N`：只执行第 N 条。

每个任务遵循：

```text
Read → Plan → Failing Test → Minimal Code → Run Test → Update Map → Update tasks.md
```

每完成一条输出：

```text
✓ Task N done — [一句话说明]
Spec: [SPEC-ID]
Tests: [运行结果]
```

## Step 5 — 暂停条件

以下情况必须暂停：

- 任务和实际代码结构不符
- 需要修改任务范围外文件
- 发现 specs 缺失或冲突
- 存在两个以上合理实现路径
- 发现安全、权限、数据一致性风险
- 测试无法验证 requirement

暂停格式：

```markdown
⚠️ Task N 暂停

## 原因

## 影响的 Spec

## 选项
- A: ...
- B: ...

## 建议
```

## Step 6 — Dev Handoff

宿主项目默认输出到 `.superspecflow/engineering/<change-id>/dev-handoff.md`。

任务完成后输出：

```markdown
# Developer Handoff: [change-id]

## Change Summary

## Specs Implemented

## Files Changed

## Tests Added / Updated

## Commands Run

## Known Risks

## Migration / Rollback

## QA Focus Areas
```

## Step 7 — 自动续接

用户确认后进入 `ssf-review`。

## Karpathy Integration — 编码纪律门禁

详细纪律见 `skills/ssf-karpathy/SKILL.md`；本阶段只保留 build 必须执行的本地门禁：

- Step 1 前写明目标、假设、歧义、更简单方案和本次最小可行改动。
- 不做无关重构，不修改与 Spec ID 无关的文件，不为了未来扩展写抽象。
- 每个变更行都应能追溯到 Spec ID、测试或 bug 复现。
- 发现无关坏味道，记录到 follow-up，不直接改。

## Git Integration — 小步中文提交

详细提交纪律见 `skills/ssf-git/SKILL.md`；build 阶段只准备 Git gate，不直接替代 `/ssf-commit`。

每完成一个可验证 task，进入：

```text
/ssf-commit [change-id]
```

如果用户明确开启自动提交，提交前仍必须执行：

1. `git status --short`
2. `git diff --stat`
3. `git diff --check`
4. `git diff --staged --stat`
5. 确认 staged diff 只包含本 task
6. 使用符合规范的 commit message（标题 `<英文类型>(<英文范围>): <中文摘要>`，正文中文）

不得在未展示 staged diff 摘要的情况下提交。
