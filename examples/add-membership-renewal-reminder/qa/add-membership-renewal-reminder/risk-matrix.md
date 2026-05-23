# Risk Matrix: add-membership-renewal-reminder

| Risk | Area | Probability | Impact | Test Strategy | Release Blocker |
|---|---|---:|---:|---|---|
| 非会员误看到提醒 | Membership | 2 | 4 | 负向单元测试和组件测试 | Yes |
| 关闭后重复展示 | UX | 3 | 3 | 关闭状态回归测试 | Yes |
| 到期边界计算错误 | Membership | 2 | 4 | 7 天、8 天、已过期边界测试 | Yes |
| 埋点失败阻塞页面 | Analytics | 2 | 2 | 模拟埋点失败，确认 UI 不阻塞 | No |
