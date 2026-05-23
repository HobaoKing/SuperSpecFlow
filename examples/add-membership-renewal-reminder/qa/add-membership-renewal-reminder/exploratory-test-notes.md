# Exploratory Test Notes: add-membership-renewal-reminder

## Mission

确认续费提醒不会错误触达用户，也不会改变会员中心原有路径。

## Areas Explored

- 到期前 7 天边界。
- 会员、非会员、已过期会员。
- 关闭提醒后刷新页面。
- 埋点失败时页面可用性。

## Edge Cases

- 到期时间为空：不展示提醒。
- 时区导致剩余天数接近边界：按服务端到期时间计算。
- 关闭提醒请求失败：提醒保留并提示稍后重试。

## Observability / Logs Checked

- `membership_renewal_reminder_shown`
- `membership_renewal_reminder_clicked`
- `membership_renewal_reminder_dismissed`

## Notes

未发现阻塞问题。

## Follow-ups

后续可评估是否加入实验分组。
