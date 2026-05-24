# Technical Design: browser-mcp-qa-adapter

## Architecture Summary

`browser-mcp-qa-adapter` 扩展 `ssf-qa` 的 QA runtime 文件协议。现有 QA 文档仍保留，新增三类 evidence-backed browser QA 产物：

```text
.superspecflow/qa/<change-id>/
  qa-execution-plan.md
  browser-run-report.md
  qa-evidence/
```

`acceptance-matrix.md` 仍是测试覆盖入口。`qa-execution-plan.md` 只派生可执行用户路径，不替代原矩阵。`browser-run-report.md` 记录实际执行。`qa-signoff.md` 汇总执行状态并引用证据。

## Data Flow

```text
OpenSpec requirements
  → acceptance-matrix.md
  → qa-execution-plan.md
  → target/tool availability check
  → browser or MCP execution
  → qa-evidence/
  → browser-run-report.md
  → qa-signoff.md
```

当目标或工具不可用时，流程在 availability check 阶段转入 blocked signoff，并记录人工验证替代步骤。

## API / Interface Changes

### `ssf-qa`

`ssf-qa` 增加以下规则：

- 从 acceptance matrix 识别 E2E / user journey 场景。
- 生成 `qa-execution-plan.md`。
- 检查目标和浏览器/MCP 工具可用性。
- 可执行时运行 journey 并写入 `browser-run-report.md`。
- 不可执行时写入 blocked signoff。

### `qa-gatekeeper`

`qa-gatekeeper` 增加以下职责：

- 将可执行场景转换为 journey。
- 明确 target、preconditions、steps、expected results 和 evidence。
- 防止无 evidence 的自动化通过声明。

## Data Model Changes

### QA Execution Plan

`qa-execution-plan.md` 最小字段：

- Change ID
- Source acceptance matrix
- Target URL or runnable target
- Tooling mode
- Journey ID
- Spec IDs
- Preconditions
- Steps
- Expected results
- Evidence to capture
- Blocked reason

### Browser Run Report

`browser-run-report.md` 最小字段：

- Timestamp
- Agent
- Target
- Tool
- Journey results
- Step-level results
- Failure point
- Evidence references
- Console / network summary when available
- Manual fallback when blocked

### QA Evidence

`qa-evidence/` 可以保存：

- Screenshots
- Trace references
- Console summaries
- Network summaries
- Sanitized notes

不得保存 secrets、tokens、凭据、生产客户数据或敏感日志。

## Security / Permission Considerations

Browser QA 不得自动执行生产环境真实世界动作。涉及支付、发布、邮件发送、外部 webhook、批量写入或删除等高风险行为时，必须使用测试环境、mock、人工 gate 或 blocked signoff。

Agent 保存证据前必须避免写入 secret、token、凭据、生产客户数据或敏感日志。若证据来自真实环境，必须在 signoff 中说明环境和脱敏状态。

## Failure Modes

- Target missing：写 `Blocked: No runnable target`。
- Tool missing：写 `Blocked: Tool unavailable`。
- Journey failed：写 `Failed`，记录失败步骤和 evidence。
- Evidence capture failed：不声明 `Automated Browser Passed`，记录缺失证据和残余风险。
- Sensitive evidence risk：停止保存证据，改写脱敏摘要或 blocked signoff。

## Observability

第一版通过文件证据提供可观察性：

- `qa-execution-plan.md` 说明计划跑什么。
- `browser-run-report.md` 说明实际跑了什么。
- `qa-evidence/` 保存或引用证据。
- `qa-signoff.md` 汇总推荐和风险。

后续 pack validation 应检查关键文件名、状态枚举和 runtime 路径是否出现在 `ssf-qa`、`qa-gatekeeper`、routing 和 templates 中。

## Migration Plan

现有 QA runtime 文件保持兼容。新增文件只在 browser/MCP QA 适用时生成；无法运行时生成 blocked signoff 和必要的 report，不要求已有 change 迁移。

## Rollback Plan

回滚本 change 的实现后，`ssf-qa` 回到文档 QA 模式。已生成的 `qa-execution-plan.md`、`browser-run-report.md` 和 `qa-evidence/` 属于宿主项目运行时产物，可按宿主项目策略保留或删除。

## Alternatives Considered

- 只在 `qa-signoff.md` 中增加一段浏览器记录：拒绝，执行计划、实际报告和证据有不同读写职责。
- 强制所有 QA 都运行浏览器：拒绝，许多项目没有可运行前端或浏览器工具。
- 第一版绑定某个 MCP server：拒绝，SuperSpecFlow 应定义协议，不绑定 vendor。
- 自动启动任意服务：拒绝，启动命令和安全边界必须由宿主项目或用户明确提供。
