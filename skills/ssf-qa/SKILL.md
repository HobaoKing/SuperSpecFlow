---
name: ssf-qa
description: 阶段四点五（测）。用户输入 /ssf-qa 或由 ssf-review 续接时触发。基于 OpenSpec 生成 acceptance matrix、risk matrix、regression checklist、negative tests 和 QA signoff。
---

# ssf-qa — 规格驱动验收

## 目标

把 OpenSpec requirements 转成可执行测试和发布门禁。

本阶段体现 OpenSpec 的价值：测试不是凭感觉点页面，而是从 requirement、scenario、MUST NOT 生成验收矩阵。

## 触发

- 显式：`/ssf-qa [change-id]`
- 隐式：用户要求测试、QA、验收、测试用例、e2e、回归、能不能发
- 自动：`ssf-review` 无 🔴 后续接

## 关键规则

- 每个 requirement 至少映射一个测试。
- 每个 MUST NOT 至少映射一个负向测试。
- 每个 P0 风险必须是 release blocker，除非用户显式豁免。
- 不只测 happy path。
- 高风险功能必须包含回归和监控建议。
- QA 运行时产物默认写入 `.superspecflow/qa/<change-id>/`。
- 读取历史 QA 产物时先读 `.superspecflow/qa/<change-id>/`，缺失时 fallback 到兼容期旧路径；新写入不得推荐根目录 `qa/<change-id>/`。
- 对 E2E、user journey 或明确需要真实浏览器验证的场景，必须从 acceptance matrix 派生 `.superspecflow/qa/<change-id>/qa-execution-plan.md`。
- Browser/MCP execution plan 只能派生 E2E、user journey 或明确 browser-required 的 acceptance matrix 行，并必须 preserve Spec ID mapping。
- 目标和浏览器/MCP 工具可用时，执行路径并记录 `.superspecflow/qa/<change-id>/browser-run-report.md` 与 `.superspecflow/qa/<change-id>/qa-evidence/`。
- 目标不可用时，QA signoff 使用 `Blocked: No runnable target`；浏览器/MCP 工具不可用时，使用 `Blocked: Tool unavailable`。
- 不得在没有 `browser-run-report.md`、`qa-evidence/` 或明确人工验证记录时声明 `Automated Browser Passed`。
- Missing target requires `Blocked: No runnable target`；Tool unavailable requires `Blocked: Tool unavailable`；Failed journey forbids `Automated Browser Passed`。
- 对 UI 还原、视觉回归、截图对比或设计对齐场景，必须从 acceptance matrix 派生 `.superspecflow/qa/<change-id>/visual-execution-plan.md`。
- Visual execution plan 只能派生 UI restoration、screenshot comparison、visual regression 或 design-alignment 的 acceptance matrix 行，并必须 preserve Spec ID mapping。
- Visual QA 使用 `platform: web | mini-program`，并记录 route/page、viewport/device、DPR、theme、locale、environment、data preconditions、screenshot source 和 optional reference image/design source。
- Visual QA 证据写入或引用 `.superspecflow/qa/<change-id>/qa-evidence/visual/`，对比结果写入 `.superspecflow/qa/<change-id>/visual-comparison-report.md`。
- Visual QA 状态只能使用 `Visual Passed`、`Manual Visual Verified`、`Visual Failed`、`Blocked: Missing baseline`、`Blocked: Missing actual screenshot` 和 `Blocked: Diff tool unavailable`。
- `Visual Passed` 只能在 baseline、actual screenshot、comparison report 和 diff output / threshold result 齐全时使用。
- 没有自动 diff 时可使用 `Manual Visual Verified`，但必须记录 manual reviewer、comparison notes、accepted differences、residual risk 和 evidence path。
- Manual reviewer required for `Manual Visual Verified`。
- 不得在缺少 baseline、baseline 未确认、缺少 actual screenshot、缺少 visual comparison report 或缺少 evidence 时声明视觉通过。
- 不得把 `visual-execution-plan.md` 当作 acceptance matrix 的替代品，不得用聊天描述替代落盘 visual evidence。
- 不得把 actual screenshot 自动提升为 baseline；baseline 建立或更新必须记录 reviewer 或 approval gate、原因、timestamp 和关联 Spec ID。
- 小程序端第一版只定义协议，不绑定具体 runner、微信开发者工具、小程序 CLI、模拟器或具体图片 diff 算法。
- 视觉 `qa-evidence/visual/` 不得包含 secret、token、凭据、生产客户数据、未脱敏个人信息或敏感日志。
- `/ssf-qa <parent-change>` 在 Spec cluster 场景必须读取 `.superspecflow/clusters/<parent-change>/cluster-plan.md` 和 `cluster-status.md`，汇总 cluster QA evidence，并记录 parent integration 级回归或 blocked reason。

## Step 1 — Acceptance Matrix

```markdown
# Acceptance Matrix: [change-id]

| Spec ID | Scenario | Test Level | Test Case | Expected Result | Priority | Status |
|---|---|---|---|---|---|---|
| SPEC-001 | ... | Unit/Integration/E2E/Manual | ... | ... | P0/P1/P2 | Pending |
```

## Step 2 — Negative Test Matrix

```markdown
# Negative Test Matrix: [change-id]

| MUST NOT ID | Forbidden Behavior | Test | Expected Failure / Guard | Blocker |
|---|---|---|---|---|
```

## Step 3 — Risk Matrix

```markdown
# Risk Matrix: [change-id]

| Risk | Area | Probability | Impact | Test Strategy | Release Blocker |
|---|---|---:|---:|---|---|
```

## Step 4 — Regression Checklist

```markdown
# Regression Checklist: [change-id]

- [ ] Existing flow A still works
- [ ] Existing permissions unchanged
- [ ] Existing data remains compatible
- [ ] Existing tests pass
```

## Step 5 — Exploratory Charter

```markdown
# Exploratory Test Charter: [change-id]

## Mission

## Areas to Explore

## Edge Cases

## Observability / Logs to Check
```

## Step 6 — QA Signoff

```markdown
# QA Signoff: [change-id]

## Test Summary

## Passed

## Failed

## Release Blockers

## Non-blocking Issues

## Residual Risk

## Browser / MCP QA Status
- Status: Automated Browser Passed | Manual Verified | Blocked: No runnable target | Blocked: Tool unavailable | Failed
- Execution Plan:
- Browser Run Report:
- Evidence:
- Manual Verification Notes:

## Recommendation
- Ship
- Ship with monitoring
- Do not ship
```

## Step 7 — Browser / MCP QA Evidence

当 acceptance matrix 包含 E2E、user journey 或需要真实浏览器验证的场景：

1. 使用 `templates/qa-execution-plan.md` 创建 `.superspecflow/qa/<change-id>/qa-execution-plan.md`。
2. 每个 journey 必须引用 Spec ID、target、前置条件、步骤、预期结果和 evidence 类型。
3. 执行前确认 target 和浏览器/MCP 工具可用。
4. 可执行时使用 `templates/browser-run-report.md` 记录 target、tool、步骤结果、失败点和 evidence 引用。
5. evidence 写入或引用 `.superspecflow/qa/<change-id>/qa-evidence/`，不得包含 secret、token、凭据、生产客户数据或敏感日志。
6. 不可执行时仍写 `browser-run-report.md`，并在 QA signoff 中使用 `Blocked: No runnable target` 或 `Blocked: Tool unavailable`。

## Step 8 — Visual UI QA Evidence

当 acceptance matrix 包含 UI 还原、视觉回归、截图对比或设计对齐场景：

1. 使用 `templates/visual-execution-plan.md` 创建 `.superspecflow/qa/<change-id>/visual-execution-plan.md`。
2. 每个 visual scenario 必须引用 Spec ID、`platform: web | mini-program`、route/page、viewport/device、DPR、theme、locale、environment、data preconditions、screenshot source、baseline policy、comparison mode、expected visual result 和 evidence path。
3. 若存在设计稿或参考图，记录 optional reference image/design source；第一版不接入具体设计工具 API。
4. 使用 `templates/visual-comparison-report.md` 记录 baseline、baseline approval / reviewer、actual screenshot、diff output、threshold、actual difference、ignored regions、manual reviewer、accepted differences、residual risk 和 evidence references。
5. 视觉 evidence 写入或引用 `.superspecflow/qa/<change-id>/qa-evidence/visual/`，不得包含 secret、token、凭据、生产客户数据、未脱敏个人信息或敏感日志。
6. 缺少 baseline 时使用 `Blocked: Missing baseline`；缺少 actual screenshot 时使用 `Blocked: Missing actual screenshot`；声明 automated diff 但 diff 工具或输出不可用时使用 `Blocked: Diff tool unavailable`。
7. 没有自动 diff 但人工验收记录完整时，使用 `Manual Visual Verified` 并记录 residual risk。
8. 不得把 actual screenshot 自动提升为 baseline；baseline 建立或更新必须记录 reviewer 或 approval gate、原因、timestamp 和关联 Spec ID。

## Step 9 — Parent Cluster QA

如果 `<change-id>` 是 parent change 且存在 `.superspecflow/clusters/<change-id>/`：

1. 读取 `cluster-plan.md` 和 `cluster-status.md`。
2. 汇总每个 cluster 的 QA signoff、browser-run-report、qa-evidence、visual-comparison-report、review、Blocked Reason 和 blocker。
3. 记录 Browser QA Status、Visual QA Status、Manual QA Status、Evidence Paths 和 Parent Integration Regression。
4. 记录 parent integration 级回归结果；缺少证据时 Recommendation 不能是 `Ship`。

## Step 10 — 自动续接

- Recommendation 为 `Ship` 或 `Ship with monitoring`：进入 `ssf-ship`。
- Recommendation 为 `Do not ship`：停下，列出 blockers。
