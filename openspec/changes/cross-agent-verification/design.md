# Technical Design: cross-agent-verification

## Architecture Summary

新增一个文件化 handoff 目录：`.superspecflow/verification/<change-id>/`。主 agent 在该目录写入核验请求与证据，review agent 在同一目录写入独立核验笔记和最终 signoff。

该设计依赖 `progress-tracking` 提供 `.superspecflow/progress/<change-id>/` 事实底座，但只把 progress 当作只读输入。cross-agent-verification 不定义 progress 文件协议，也不负责更新 progress。

## Data Flow

1. 主 agent 根据 OpenSpec change、当前 diff、progress 和已执行验证创建 `.superspecflow/verification/<change-id>/request.md`。
2. 主 agent 将命令输出摘要、测试结果、人工检查记录和相关文件引用写入 `evidence.md`。
3. review agent 读取 OpenSpec、diff、`.superspecflow/progress/<change-id>/`、`request.md` 和 `evidence.md`。
4. review agent 将核验过程、发现、无法确认的事项和引用依据写入 `reviewer-notes.md`。
5. 当且仅当 evidence 存在且包含可复查内容时，review agent 写入 `signoff.md`。
6. 主控流程读取 `signoff.md` 的结果，并决定继续修改、阻塞整合或进入后续门禁。

## File Interfaces

### `request.md`

由主 agent 创建。内容必须说明：

- `change-id`
- 请求核验的范围和阶段
- 期望 review agent 检查的 Spec ID
- 相关 OpenSpec 文件路径
- diff 来源或获取方式
- progress 目录引用：`.superspecflow/progress/<change-id>/`
- evidence 文件引用
- 主 agent 已知的限制、跳过项或待确认事项

### `evidence.md`

由主 agent 创建。内容必须说明：

- 已执行的验证命令和结果摘要
- 失败、跳过或未运行的验证及原因
- 人工核验记录，若有
- 关键输出、日志、截图或构建产物的路径引用，若有
- 每条 evidence 关联的 Spec ID 或任务 ID

`evidence.md` 不应只包含结论性描述。它必须提供 review agent 能复查的命令、路径、摘要或引用。

### `reviewer-notes.md`

由 review agent 创建。内容必须说明：

- review agent 实际读取的 OpenSpec、diff、progress 和 evidence 来源
- 对每个被检查 Spec ID 的判断
- 发现的问题、疑点和无法确认的事实
- 是否存在 evidence 缺口
- 建议的后续动作

该文件可以在 evidence 缺失时创建，用于说明无法 signoff 的原因。

### `signoff.md`

由 review agent 创建。内容必须包含：

- `result`：只能是 `approve`、`changes-requested` 或 `blocked`
- 已检查的 Spec ID
- 使用过的验证命令、证据条目或文件引用
- 残余风险
- review agent 标识和时间戳

没有 `evidence.md`，或 `evidence.md` 没有可复查内容时，review agent 不得创建 `signoff.md`。

## API / Interface Changes

- 新增验证 handoff 目录：`.superspecflow/verification/<change-id>/`。
- 新增固定 handoff 文件：
  - `request.md`：由主 agent 写入。
  - `evidence.md`：由主 agent 写入。
  - `reviewer-notes.md`：由 review agent 写入，可以在 evidence 缺失时创建。
  - `signoff.md`：由 review agent 在 evidence 可复查时写入。
- 读取 progress 目录：`.superspecflow/progress/<change-id>/`。

## Data Model Changes

`signoff.md` 的结果枚举第一版只允许：

- `approve`
- `changes-requested`
- `blocked`

建议 `signoff.md` 使用稳定字段标题，便于人工和后续工具读取：

```markdown
# Cross-Agent Verification Signoff: <change-id>

Result: approve | changes-requested | blocked
Reviewer: <agent>
Reviewed At: <ISO-8601 timestamp>

## Checked Spec IDs

- <SPEC-ID>

## Evidence Reviewed

- <command or evidence reference>

## Findings

- <finding>

## Residual Risks

- <risk>
```

## Security / Permission Considerations

review agent 不能把聊天上下文、未提交的口头说明或外部不可复查声明作为核验依据。可用输入仅限 OpenSpec、diff、progress 和 evidence。

handoff 文件不得要求 review agent 执行生产发布、修改权限、删除数据或触发真实世界动作。若核验需要高风险操作，review agent 必须返回 `blocked` 并说明所需人工门禁。

## Failure Modes

- `request.md` 缺失：review agent 返回 notes，说明无法确认核验范围，不创建 signoff。
- `evidence.md` 缺失或为空：review agent 返回 notes，说明 evidence 缺口，不创建 signoff。
- progress 目录缺失：review agent 可以继续基于 OpenSpec、diff 和 evidence 核验，但必须在 notes 和 signoff 残余风险中记录 progress 不可用。
- Spec ID 与 diff 不匹配：signoff 结果应为 `changes-requested` 或 `blocked`。
- evidence 与命令结果矛盾：signoff 结果应为 `changes-requested` 或 `blocked`，并列出矛盾来源。

## Observability

handoff 的可观察性来自固定文件路径和可引用的 evidence 条目。主控流程可以通过检查 `signoff.md` 是否存在、`Result` 是否为允许枚举、以及 `Checked Spec IDs` / `Evidence Reviewed` / `Residual Risks` 是否非空来判断核验是否完整。

## Migration Plan

该 change 是新增契约，不迁移现有 review 文件。后续可在 review、QA 或 Git gate 中逐步要求关键 change 生成 `.superspecflow/verification/<change-id>/`。

## Rollback Plan

回滚后，流程继续使用现有单 agent review / QA / Git gate。已经生成的 `.superspecflow/verification/<change-id>/` 可作为本地运行时产物保留或清理，不影响 OpenSpec change contract。

## Alternatives Considered

- 双 agent 强制共同签署：拒绝，第一版目标是轻量 handoff，不改变现有门禁拓扑。
- 抽象共识协议或多方投票：拒绝，复杂度超过当前问题，且难以映射到人工可读 evidence。
- 让 review agent 读取完整聊天上下文：拒绝，不利于独立核验，也无法保证事实可复查。
- 由 cross-agent-verification 定义 progress 文件协议：拒绝，该职责属于 `progress-tracking`。
