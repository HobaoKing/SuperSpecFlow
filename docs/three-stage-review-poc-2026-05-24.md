# Three-Stage Review Loop PoC (2026-05-24)

## 背景

2026-05-24 给 `ssf-think` / `ssf-spec` / `ssf-build` 三个 skill 各加了一个评审循环步骤（Step 6.5 / Step 5.5 / Step 1.5），均调用 superpowers 自带的 reviewer prompt：

- `~/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.5/skills/brainstorming/spec-document-reviewer-prompt.md`
- `~/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.5/skills/writing-plans/plan-document-reviewer-prompt.md`

已知风险：两份 prompt 是英文的，针对 superpowers 单一 design.md / plan 文件结构设计。SuperSpecFlow 产出是中文 + OpenSpec 多文件结构（含 SPEC-ID / scenario / MUST NOT）。本 PoC 验证 reviewer 在实际项目语境下的表现，决定是否需要写项目化中文 reviewer。

## 方法

- **场景**：模拟新增 `/ssf-doctor` 健康检查命令（项目真实可能要的小功能）
- **产出**：在 `/tmp/ssf-doctor-poc/` 下完整走一遍三阶段输出
  - 阶段 A：`think-design.md`（ssf-think 单一 design.md）
  - 阶段 B：`openspec/{proposal,specs/doctor,design,tasks}.md`（ssf-spec 多文件 OpenSpec 合同）
  - 阶段 C：`engineering/implementation-plan.md`（ssf-build 新 1.1–1.6 结构）
- **评审**：每阶段产出后用 `Agent` tool 起 general-purpose 子代理，传 superpowers 自带 prompt
- **不真实施任何代码**——目标只是验证 reviewer 行为

## 三次评审结果

### 阶段 A: spec-document-reviewer 审 think-design.md

- **Status**: Approved（一次过）
- **关键观察**：
  - reviewer 用中文回复反馈
  - 明确识别"ssf-think 阶段输出契约"，说出"结构与 ssf-think 阶段输出契约一致"
  - 识别"开放问题 #4"、"风险段"等具体章节引用
- **Recommendations 摘录**（4 条，全部有实操价值）：
  - 建议开放问题 #4 在 planning 前先决策，避免 plan 阶段回到 think
  - 建议把"误报 SessionStart hook"作为显式 bats 验收用例
  - 建议退出码语义和 `--no-color` 在 plan 阶段对齐 bats 测试
  - 建议中文输出 follow-up 登记到候选 spec 列表，避免遗失

### 阶段 B: spec-document-reviewer 审 OpenSpec 多文件

- **Status**: Approved（一次过）
- **关键观察**：
  - 完整读取 4 份文件并综合评审
  - 主动做 SPEC-ID 反向溯源：列出每个 SPEC-ID 对应哪些 Scenario、被哪些 Task 引用
  - 明确识别 N-prefix 的 MUST NOT ID 语义
  - 做跨文件一致性检查（proposal Risk vs spec DOCTOR-005 vs design Failure Modes）
- **发现的真实矛盾**（3 个，PoC 没刻意埋）：
  1. `design.md` 引入 `INFO` / `N/A` 状态，但 `DOCTOR-005` 只定义 PASS/WARN/FAIL → 真实内部矛盾
  2. `proposal.md` Risk 3 给 `→ Run: 手动修复` 是抽象建议，违反 `DOCTOR-005` 要求的"具体命令" → 真实违约
  3. `proposal.md` Open Question 4 的 WARN 处理与 `DOCTOR-003` Scenario "未 opt-in 时 FAIL" 在语义上需要更清晰的分情况
- **附加建议**：T6 的 `手动跑 /ssf-doctor 验证` 改成 contract test（PATH stub）以便机器验证

### 阶段 C: plan-document-reviewer 审 implementation-plan.md

- **Status**: Approved（一次过）
- **关键观察**：
  - 完整列出 DOCTOR-001 ~ DOCTOR-005 + DOCTOR-N001 ~ DOCTOR-N004 的 Task 覆盖映射
  - 显式确认 MUST NOT 全覆盖
  - 正确理解 PoC 简化（"T2–T10 只给 header"是有意为之）
- **Recommendations 摘录**（4 条，包括一条非常 sharp 的元反馈）：
  - **Task 6 写的"对阶段 B reviewer 矛盾的响应"备注其实是冗余的**——spec 本身 PASS/WARN/FAIL 三状态完整，没有矛盾。reviewer 指出这段备注反而会让实施者困惑（→ Plan 作者应删）
  - DOCTOR-N003 用 `unshare -n` 测试是环境依赖且 CI 可能 flaky；建议改成 stub `git` + static grep `git fetch` 不存在
  - Task 8 的 stub 机制（PATH override vs env var）没明确，建议给一行 hint
  - 建议显式注明 T8 覆盖 DOCTOR-001 的 CLI-in scenario、`scripts/doctor.sh` 已覆盖 CLI-out

## Prompt 适配性评估

| 维度 | 预期风险 | 实际表现 |
|---|---|---|
| 中文文档 | reviewer 可能读不准 | ✅ 完全读懂；用中文（或中英混合）回复反馈 |
| OpenSpec 多文件结构 | reviewer 可能要求合并文件 | ✅ 自动综合评审 4 份文件；做 SPEC-ID 反向溯源 |
| SPEC-ID 语义 | reviewer 可能不识别 | ✅ 显式识别并做 Task ↔ Spec ID 覆盖映射 |
| Scenario 语义 | reviewer 可能漏检 | ✅ 检查每个 Requirement 是否有 happy + negative scenario |
| MUST NOT 语义 | reviewer 可能忽略 N-prefix ID | ✅ 主动检查 N001–N004 的 task 覆盖 |
| 反馈质量 | 担心套话 | ✅ 三次评审共发现 5+ 个真实矛盾或工程化改进点 |
| 反馈格式 | 英文 output template | ✅ Status / Issues / Recommendations 三段式严格按 template；Issues 用中文表达，节标题用 prompt 模板的英文格式 |

**结论**：三次评审 **无显著不适配**。superpowers 自带 prompt 在 SuperSpecFlow 的中文 + OpenSpec 多文件语境下完全可用，无需立刻写项目化中文 reviewer。

## Follow-up

### 不需要做的事

- ❌ 写项目化中文 reviewer prompt（短期）
- ❌ 改 reviewer 调用方式（当前 Agent tool + prompt 路径足够）
- ❌ 限制只用单一文件（多文件结构 reviewer 处理得很好）

### 建议做的事

1. **更新 SKILL.md 注意事项**：把"反馈可能混合中英文"的预期写进 ssf-think Step 6.5 / ssf-spec Step 5.5 / ssf-build Step 1.5 的"注意"段（当前文案说"英文反馈"，实际表现更接近"中英混合反馈"）。**优先级：低**
2. **把本 PoC 发现的 reviewer 真实能力作为 ssf-* 流程的示例**：可以在 `examples/` 加一个 reference run，但不阻塞当前流程。**优先级：低**
3. **下次真实 change 使用三阶段评审循环时**：留意 reviewer 是否仍能稳定识别 SPEC-ID/scenario/MUST NOT 语义；如果出现退化，再考虑写项目化 prompt。**优先级：观察项**

### 必须做的事

- **无**。三阶段评审循环可投产。

## 结论

**三阶段评审循环（Step 6.5 / 5.5 / 1.5）效果优于预期，可直接进入真实使用。**

PoC 暴露了 ssf-doctor spec 本身的 3 个真实矛盾（status 状态机不一致、抽象建议违反"具体命令"约束、Open Question 处理与 Scenario 冲突），全部由 reviewer 自动发现。这说明评审循环的核心价值（"在产物诞生时立刻评一次"）在 SuperSpecFlow 项目语境下是成立的。

唯一的预期风险（"prompt 是英文 + 单一文件结构，可能不适配"）在实际测试中没有出现明显不适配。三个 reviewer 子代理表现稳定、反馈精准、克制（按 prompt 校准 Calibration 段不抠风格）。

## 附录：PoC 产物清单

`/tmp/ssf-doctor-poc/` 是临时位置，PoC 完成后由系统自动清理。如需重跑：

- 阶段 A 输入：`think-design.md`
- 阶段 B 输入：`openspec/proposal.md`、`openspec/specs/doctor.md`、`openspec/design.md`、`openspec/tasks.md`
- 阶段 C 输入：`engineering/implementation-plan.md`
- 评审 prompt：见本文档"背景"小节路径
