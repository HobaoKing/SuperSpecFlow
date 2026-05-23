# Retro: add-membership-renewal-reminder

## What Went Well

- MVP 范围控制在会员中心入口，避免触碰支付和站外通知。
- Spec IDs 覆盖正向和负向行为。
- QA 覆盖非会员、关闭提醒和到期边界。

## What Got Stuck

- 关闭状态的存储位置需要较早确认。
- 是否实验分组在 spec 阶段未完全定论。

## Product Quality
- Pain clear: Yes
- Scope controlled: Yes
- Non-goals clear: Yes

## Spec Quality
- Requirements testable: Yes
- MUST NOT complete: Yes
- Tasks sized well: Yes

## Engineering Quality
- TDD followed: Yes
- Spec-to-code map accurate: Yes
- Review blockers: None

## QA Quality
- Acceptance matrix complete: Yes
- Negative tests complete: Yes
- Regression coverage: Yes

## Release Quality
- Rollback clear: Yes
- Monitoring clear: Yes
- Residual risk: 首日观察埋点口径和关闭状态反馈。

## Process Improvements

1. In ssf-spec: 对状态存储位置增加更明确的开放问题处理。
2. In ssf-build: 若发现需要数据库字段，立即暂停并补 migration plan。
3. In ssf-qa: 保留边界时间测试作为默认检查项。
4. In ssf-ship: 对埋点类变更默认要求首日监控指标。
