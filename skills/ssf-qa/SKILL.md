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

## Recommendation
- Ship
- Ship with monitoring
- Do not ship
```

## Step 7 — 自动续接

- Recommendation 为 `Ship` 或 `Ship with monitoring`：进入 `ssf-ship`。
- Recommendation 为 `Do not ship`：停下，列出 blockers。
