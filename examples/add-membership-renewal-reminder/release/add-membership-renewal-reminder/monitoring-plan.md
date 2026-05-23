# Monitoring Plan: add-membership-renewal-reminder

## Metrics

- 会员中心页面错误率。
- 续费提醒展示次数。
- 续费提醒点击率。
- 关闭提醒次数。

## Logs

- 会员状态读取失败日志。
- 关闭提醒失败日志。
- 埋点发送失败日志。

## Alerts

- 会员中心页面错误率高于基线。
- 关闭提醒接口错误率升高。

## First 24h Watch Items

- 非会员误展示反馈。
- 关闭后重复展示反馈。
- 到期边界用户的提醒展示是否符合预期。
