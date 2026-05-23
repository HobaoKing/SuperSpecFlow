# Acceptance Matrix: add-membership-renewal-reminder

| Spec ID | Scenario | Test Level | Test Case | Expected Result | Priority | Status |
|---|---|---|---|---|---|---|
| MEMBERSHIP-001 | 到期前会员看到提醒 | Component | 渲染 7 天内到期会员中心 | 展示续费提醒入口 | P0 | Pass |
| MEMBERSHIP-002 | 到期时间超过 7 天 | Unit | 8 天后到期用户调用判断函数 | 返回不展示 | P0 | Pass |
| MEMBERSHIP-003 | 用户关闭提醒 | Component | 点击关闭后重新渲染会员中心 | 不再展示提醒 | P0 | Pass |
| MEMBERSHIP-004 | 提醒被展示 | Component | 符合条件时渲染会员中心 | 记录展示事件 | P1 | Pass |
| MEMBERSHIP-004 | 提醒被关闭 | Component | 点击关闭提醒 | 记录关闭事件 | P1 | Pass |
