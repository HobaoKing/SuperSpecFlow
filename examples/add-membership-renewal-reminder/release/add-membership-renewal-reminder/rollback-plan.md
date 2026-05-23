# Rollback Plan: add-membership-renewal-reminder

## Rollback Trigger

- 非会员看到续费提醒。
- 关闭提醒后仍重复展示。
- 会员中心核心路径错误率升高。

## Rollback Steps

1. 回滚包含会员中心提醒入口的提交。
2. 重新部署前端。
3. 确认会员中心恢复到发布前状态。

## Data Considerations

本变更不修改计费数据。已记录的埋点事件可以保留。

## Owner

会员体验负责人。

## Verification After Rollback

- 非会员会员中心不显示提醒。
- 会员中心原有续费入口可用。
- 错误日志恢复到发布前水平。
