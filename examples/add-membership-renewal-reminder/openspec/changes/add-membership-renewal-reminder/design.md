# Technical Design: add-membership-renewal-reminder

## Architecture Summary

在会员中心已有会员状态数据上增加一个展示判断函数和一个轻量 UI 入口。关闭状态保存在用户偏好或会员周期级别的提醒状态中。

## Data Flow

1. 会员中心读取当前用户会员状态。
2. `shouldShowRenewalReminder` 根据会员身份、到期时间和关闭状态返回布尔值。
3. UI 根据布尔值展示续费提醒入口。
4. 展示和关闭行为写入埋点。

## API / Interface Changes

- 新增读取关闭状态的字段：`renewalReminderDismissedForCycle`。
- 新增关闭提醒动作：`dismissRenewalReminder(cycleId)`。

## Data Model Changes

低风险版本可以复用用户偏好存储。若需要持久化到数据库，必须先补 `migration-plan.md`。

## Security / Permission Considerations

只允许当前登录用户关闭自己的提醒状态。不得暴露其他用户会员到期时间。

## Failure Modes

- 会员状态读取失败：不展示提醒。
- 关闭提醒失败：保留提醒并提示稍后重试。
- 埋点失败：不阻塞用户路径。

## Observability

- `membership_renewal_reminder_shown`
- `membership_renewal_reminder_clicked`
- `membership_renewal_reminder_dismissed`

## Migration Plan

本示例不涉及数据库迁移。如改为新增表或字段，必须补充迁移计划和回滚计划。

## Rollback Plan

回滚 UI 入口和展示判断函数，保留已记录的埋点数据不影响用户路径。

## Alternatives Considered

- 邮件提醒：触达更强，但涉及通知偏好和退订，范围过大。
- 全站 banner：曝光更高，但容易干扰非会员路径。
- 会员中心入口：范围最小，可验证续费点击和用户反馈。
