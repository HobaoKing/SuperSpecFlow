# Technical Design: progress-tracking

## Architecture Summary

新增一个运行时进度协议目录：`.superspecflow/progress/<change-id>/`。该目录属于宿主项目的执行状态，不是 SuperSpecFlow 包源码的一部分。

每个 change-id 对应一个进度目录，目录内使用四个文件分工记录事实：

- `state.json`：机器可读的当前状态摘要。
- `timeline.md`：按时间追加的人类可读事件记录。
- `verification.md`：验证命令、输出摘要、时间和适用范围。
- `handoff.md`：中断、上下文压缩或换 agent 时的恢复说明。

OpenSpec 仍是需求契约来源；progress 文件只记录执行过程和验证事实，不取代 proposal、design、tasks 或 specs。

## Data Flow

任务开始：

1. Agent 确认 change-id。
2. Agent 查找 `.superspecflow/progress/<change-id>/`。
3. 如果目录不存在，agent 可以创建最小进度目录。
4. Agent 写入或更新 `state.json`，并在 `timeline.md` 追加开始事件。

任务执行：

1. Agent 完成一个可验证步骤后更新 `state.json`。
2. Agent 在 `timeline.md` 追加关键决策、任务完成、阻塞和恢复事件。
3. Agent 运行验证后写入 `verification.md`，并在 `state.json.last_verification` 引用该记录。
4. Agent 中断前或移交前更新 `handoff.md`。

恢复流程：

1. Agent 先读取 `.superspecflow/progress/<change-id>/state.json`。
2. Agent 再读取 `.superspecflow/progress/<change-id>/handoff.md`。
3. Agent 根据状态和交接摘要识别当前阶段、最近验证、阻塞点和下一步。
4. Agent 再读取 `openspec/changes/<change-id>/` 中的 OpenSpec 文件。
5. Agent 对比 progress 与 OpenSpec tasks，发现冲突时以 OpenSpec 为需求契约，以 progress 为执行事实，并在 `timeline.md` 记录冲突和处理结果。

## File Protocol

### `state.json`

`state.json` 是当前进度的机器可读摘要。第一版要求字段保持小而稳定：

```json
{
  "change_id": "progress-tracking",
  "phase": "spec",
  "status": "in_progress",
  "current_task": "Draft OpenSpec progress protocol",
  "completed_tasks": [],
  "blocked": false,
  "blockers": [],
  "last_updated": "2026-05-24T00:00:00Z",
  "last_agent": "codex",
  "last_verification": {
    "timestamp": "2026-05-24T00:00:00Z",
    "summary": "Not run",
    "reference": "verification.md#not-run"
  },
  "openspec": {
    "change_path": "openspec/changes/progress-tracking",
    "spec_ids": []
  }
}
```

`status` 允许的取值：

- `not_started`
- `in_progress`
- `blocked`
- `ready_for_review`
- `ready_for_qa`
- `complete`
- `abandoned`

`phase` 允许的取值应与 SuperSpecFlow 生命周期对齐：

- `think`
- `spec`
- `build`
- `review`
- `qa`
- `ship`
- `git`
- `archive`
- `retro`

`last_verification` 在该 change 从未运行过验证时，可以使用占位值 `summary: "Not run"`、`reference: "verification.md#not-run"`，表示尚无可引用的验证证据。

### `timeline.md`

`timeline.md` 是 append-oriented 的事件日志。每条记录应包含时间戳、agent、事件类型、摘要，以及相关时给出受影响的文件或任务。

推荐条目格式：

```markdown
## 2026-05-24T00:00:00Z - codex - task-started

- Change: progress-tracking
- Summary: Started drafting progress protocol OpenSpec.
- Files: openspec/changes/progress-tracking/
```

### `verification.md`

`verification.md` 记录完成声明所依据的验证证据。每条验证记录应包含时间戳、agent、命令或人工检查、范围、结果以及输出摘要。

推荐条目格式：

```markdown
## 2026-05-24T00:00:00Z - codex - pass

- Scope: progress-tracking spec draft
- Command: `rtk git diff --check -- openspec/changes/progress-tracking`
- Result: pass
- Output summary: No whitespace errors.
- Freshness: Recorded after the latest content edit.
```

如果验证是人工执行的，记录必须写明人工方法和检查过的文件。如果验证无法运行，记录必须写明原因以及对应的完成声明是否需要降低范围。

### `handoff.md`

`handoff.md` 是 `state.json` 之后第一份给人阅读的恢复文档。它应该在中断、上下文压缩或更换 agent 之前被重写或更新。

推荐章节：

```markdown
# Handoff: progress-tracking

## Current State

## Completed

## Next Step

## Fresh Verification

## Known Risks

## Read Next
```

`Read Next` 应列出新 agent 在读完 `state.json` 与 `handoff.md` 之后应当继续阅读的具体文件，通常以 `openspec/changes/<change-id>/` 下的 OpenSpec 文件开头。

## Agent Rules

- Agent 不得把 progress 文件当作 OpenSpec 需求契约的替代品。
- Agent 在中断、上下文压缩或交接后恢复时，必须先读取 `state.json` 与 `handoff.md`，再读取 OpenSpec 文件。
- Agent 修改任一 progress 文件时，必须同步更新 `state.json.last_updated`。
- Agent 必须把关键执行事件追加到 `timeline.md`，而不是静默覆盖历史。
- Agent 在 meaningful work remains 时停止前，必须更新 `handoff.md`。
- Agent 在声称任务、阶段或 change 完成前，必须在 `verification.md` 中写入或引用 fresh verification。
- Agent 不得用早于最新相关内容或行为变更的 verification 记录声明完成。

## Fresh Verification Definition

一条验证记录是 fresh 的，当且仅当它写入时间晚于被声明完成的文件、行为或任务范围的最新相关变更。

对于纯文档工作，fresh verification 可以是有针对性的文件检查、`git diff --check`、可用时的 markdown lint，或其它明确描述的人工检查。

对于行为变更，fresh verification 必须包含相关的自动化测试、烟测，或者明确写明自动检查无法运行的原因。完成声明必须限定在实际记录到的证据范围内。

## Repository Boundary

SuperSpecFlow 本仓库必须提交 OpenSpec 协议文件，但不得提交 `.superspecflow/progress/` 运行时实例。`.superspecflow/progress/` 是宿主项目的运行时状态目录。

宿主项目是否提交 `.superspecflow/progress/` 由宿主项目策略决定。本协议只定义文件含义和 agent 行为，不替宿主项目规定 Git 跟踪策略。

## API / Interface Changes

无代码 API 变更。第一版只定义文件协议和 agent 规则。

## Data Model Changes

新增进度状态数据模型，存放在宿主项目 `.superspecflow/progress/<change-id>/state.json`。OpenSpec change contract 不变。

## Security / Permission Considerations

Progress 文件可能包含本地路径、命令输出摘要、阻塞原因和 agent 交接信息。Agent 不应写入 secrets、tokens、凭据、私有客户数据或不应提交的敏感日志。

如果宿主项目选择提交 `.superspecflow/progress/`，必须由宿主项目自行评估敏感信息和保留周期。

## Failure Modes

- `state.json` 缺失：agent 按 OpenSpec 恢复，并在可写时创建新的 `state.json`，同时在 `timeline.md` 记录缺失。
- `state.json` 无法解析：agent 不应猜测机器状态，应读取 `handoff.md` 和 OpenSpec，并记录修复需要。
- `handoff.md` 缺失：agent 读取 `timeline.md` 和 OpenSpec，恢复后补写交接摘要。
- verification 过期：agent 必须重新验证或降低完成声明范围。
- progress 与 OpenSpec 冲突：需求以 OpenSpec 为准，执行事实以 progress 为证据，冲突必须记录在 `timeline.md`。

## Observability

第一版通过文件内容本身提供可观察性。后续 `cross-agent-verification` 可以读取 `state.json.last_verification`、`verification.md` 和 `handoff.md` 来判断是否存在足够的新鲜证据。

## Migration Plan

无既有进度协议需要迁移。采用该协议的宿主项目可以在首次执行 change 时创建 `.superspecflow/progress/<change-id>/`。

## Rollback Plan

回滚本 OpenSpec change 即可移除协议定义。由于第一版不实现代码行为，不需要数据迁移回滚。

## Alternatives Considered

- 只使用 OpenSpec `tasks.md` 记录进度：拒绝，tasks 是计划和完成列表，不适合记录验证证据、恢复摘要和运行时状态。
- 只使用一个 `progress.md` 文件：拒绝，机器可读状态、事件日志、验证证据和交接摘要有不同读写模式。
- 使用数据库或外部状态服务：拒绝，第一版应保持文件协议，便于 agent 在任意宿主项目中读写。
- 立即实现自动调度和 UI：拒绝，超出最小事实底座范围。
