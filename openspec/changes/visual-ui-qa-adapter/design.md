# Technical Design: visual-ui-qa-adapter

## Architecture Summary

`visual-ui-qa-adapter` 为 `ssf-qa` 增加视觉 QA 文件协议。它建立在 acceptance matrix 和现有 QA runtime 之上，专门处理 Web / 小程序 UI 1:1 还原、历史基线截图回归、截图对比和人工视觉验收。

```text
.superspecflow/qa/<change-id>/
  visual-execution-plan.md
  visual-comparison-report.md
  qa-evidence/
    visual/
```

该 change 只定义协议和门禁，不实现截图执行器或图片 diff 算法。Web、小程序、外部视觉测试平台或人工流程都可以通过同一套 evidence 协议接入。

## Data Flow

```text
OpenSpec requirements
  -> acceptance-matrix.md
  -> visual-execution-plan.md
  -> baseline / actual screenshot availability check
  -> optional automated diff or manual visual comparison
  -> qa-evidence/visual/
  -> visual-comparison-report.md
  -> qa-signoff.md
```

若 baseline、actual 截图或声明需要的 diff 输出缺失，流程进入 blocked 或 manual verified 状态，不得声明自动视觉通过。

## API / Interface Changes

### `ssf-qa`

`ssf-qa` 增加以下规则：

- 从 acceptance matrix 识别 UI 还原、视觉回归、截图对比和设计对齐场景。
- 生成 `visual-execution-plan.md`。
- 记录 `platform: web | mini-program`。
- 检查 baseline、actual screenshot 和 comparison output 是否存在。
- 生成 `visual-comparison-report.md`。
- 在 `qa-signoff.md` 中记录视觉 QA 状态并引用 evidence。

### `qa-gatekeeper`

`qa-gatekeeper` 增加以下职责：

- 检查视觉场景是否有可复查 evidence。
- 区分自动 diff 通过、人工视觉验收、失败和 blocked。
- 防止无 baseline、无 actual 截图或无 report 的视觉通过声明。

### Templates

新增模板：

- `templates/visual-execution-plan.md`
- `templates/visual-comparison-report.md`

更新模板：

- `templates/qa-signoff.md`

## Data Model Changes

### Visual Execution Plan

`visual-execution-plan.md` 最小字段：

- Change ID
- Source acceptance matrix
- Platform: `web | mini-program`
- Spec ID
- Scenario
- Route / URL / page path
- Viewport / device profile
- DPR
- Theme
- Locale
- Environment
- Data preconditions
- Baseline policy
- Actual screenshot source
- Optional reference image / design source
- Comparison mode: automated diff / manual comparison
- Expected visual result
- Evidence path
- Blocked reason

### Visual Comparison Report

`visual-comparison-report.md` 最小字段：

- Timestamp
- Agent
- Platform
- Scenario and Spec ID
- Baseline path or reference
- Baseline approval / reviewer
- Actual screenshot path or reference
- Diff output path or reference, if available
- Optional reference image / design source
- Threshold, if automated diff is used
- Actual difference summary
- Ignored regions
- Manual reviewer, if manual comparison is used
- Accepted differences
- Residual risk
- Status
- Evidence references
- Redaction check

### Visual Evidence Directory

`.superspecflow/qa/<change-id>/qa-evidence/visual/` 可以保存或引用：

- Baseline screenshots
- Actual screenshots
- Diff images
- Optional reference images or design-source screenshots
- External report summaries
- Manual comparison notes
- Redacted design/reference images

不得保存 secrets、tokens、凭据、生产客户数据、未脱敏个人信息或敏感日志。

## Security / Permission Considerations

视觉证据可能包含真实用户数据、内部业务信息或个人信息。Agent 保存证据前必须检查敏感信息，必要时改用脱敏截图、裁剪图、文本摘要或 blocked signoff。

小程序端第一版只定义协议，不要求 agent 调用具体 runner。若宿主项目提供执行器，agent 必须遵循宿主项目权限和安全边界。

## Failure Modes

- Missing baseline：写 `Blocked: Missing baseline`。
- Missing actual screenshot：写 `Blocked: Missing actual screenshot`。
- Diff tool unavailable：仅当 visual execution plan 要求 automated diff 时写 `Blocked: Diff tool unavailable`。
- Visual mismatch：写 `Visual Failed`，记录差异区域和 evidence。
- Manual comparison only：写 `Manual Visual Verified`，记录 reviewer、判断依据和残余风险。
- Evidence privacy risk：停止保存原始截图，改用脱敏证据或 blocked signoff。

## Observability

第一版通过文件证据提供可观察性：

- `visual-execution-plan.md` 说明要验收哪些 UI 场景。
- `visual-comparison-report.md` 说明 baseline、actual、diff 或人工对比结果。
- `qa-evidence/visual/` 保存或引用视觉证据。
- `qa-signoff.md` 汇总视觉 QA 状态和残余风险。

Pack validation 应检查关键文件名、状态枚举、platform 枚举、baseline 门禁和 runtime 路径是否出现在 `ssf-qa`、`qa-gatekeeper`、routing 和 templates 中。

视觉阈值第一版只记录外部工具输出，不定义具体算法。`visual-comparison-report.md` 至少保留 threshold、actual difference summary、ignored regions 和 result。人工验收 reviewer 使用自由文本标识，但必须足以让宿主项目追溯验收来源。

## Migration Plan

现有 QA runtime 文件保持兼容。没有视觉 QA 场景的 change 不需要生成 visual runtime 文件。已有 browser QA 产物不迁移，视觉 QA 只在 acceptance matrix 明确需要 UI 视觉验收、截图对比或 UI 1:1 还原时启用。

## Rollback Plan

回滚本 change 的实现后，`ssf-qa` 回到当前 browser/MCP QA 和文档 QA 模式。已生成的 `visual-execution-plan.md`、`visual-comparison-report.md` 和 `qa-evidence/visual/` 属于宿主项目运行时产物，可按宿主项目策略保留或删除。

## Alternatives Considered

- 扩展 `browser-mcp-qa-adapter`：拒绝。浏览器用户路径执行和视觉还原验收职责不同。
- 第一版内置图片 diff 脚本：拒绝。SuperSpecFlow 应先定义流程协议，不绑定具体图像算法。
- 第一版绑定微信开发者工具：拒绝。小程序端工具链差异大，先做协议层更稳。
- 只用 `qa-signoff.md` 增加一段视觉说明：拒绝。视觉计划、对比报告和证据目录职责不同，必须可复查。
