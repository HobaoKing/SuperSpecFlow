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
- 目标和浏览器/MCP 工具可用时，执行路径并记录 `.superspecflow/qa/<change-id>/browser-run-report.md` 与 `.superspecflow/qa/<change-id>/qa-evidence/`。
- 目标不可用时，QA signoff 使用 `Blocked: No runnable target`；浏览器/MCP 工具不可用时，使用 `Blocked: Tool unavailable`。
- 不得在没有 `browser-run-report.md`、`qa-evidence/` 或明确人工验证记录时声明 `Automated Browser Passed`。
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

## Step 8 — Parent Cluster QA

如果 `<change-id>` 是 parent change 且存在 `.superspecflow/clusters/<change-id>/`：

1. 读取 `cluster-plan.md` 和 `cluster-status.md`。
2. 汇总每个 cluster 的 QA signoff、browser-run-report、qa-evidence、review 和 blocker。
3. 记录 parent integration 级回归结果；缺少证据时 Recommendation 不能是 `Ship`。

## Step 9 — 自动续接

- Recommendation 为 `Ship` 或 `Ship with monitoring`：进入 `ssf-ship`。
- Recommendation 为 `Do not ship`：停下，列出 blockers。
