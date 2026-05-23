# Negative Test Matrix: add-membership-renewal-reminder

| MUST NOT ID | Forbidden Behavior | Test | Expected Failure / Guard | Blocker |
|---|---|---|---|---|
| MEMBERSHIP-N1 | 向非会员展示续费提醒 | 非会员打开会员中心 | 不渲染提醒入口 | Yes |
| MEMBERSHIP-N2 | 向已关闭本轮提醒的用户重复展示 | 已关闭用户刷新会员中心 | 不渲染提醒入口 | Yes |
| MEMBERSHIP-N3 | 改变支付、订阅、退款或计费逻辑 | 检查 diff 和回归支付入口 | 无计费文件改动，支付入口不变 | Yes |
