# Developer Handoff: add-membership-renewal-reminder

## Change Summary

会员中心新增续费提醒入口，覆盖展示窗口、关闭状态和埋点事件。

## Specs Implemented

- MEMBERSHIP-001
- MEMBERSHIP-002
- MEMBERSHIP-003
- MEMBERSHIP-004
- MEMBERSHIP-N1
- MEMBERSHIP-N2
- MEMBERSHIP-N3

## Files Changed

- `src/membership/renewalReminder.ts`
- `src/membership/renewalReminder.test.ts`
- `src/membership/MemberCenter.tsx`
- `src/membership/MemberCenter.test.tsx`
- `src/analytics/events.ts`

## Tests Added / Updated

- 展示判断单元测试。
- 会员中心组件测试。
- 非会员、超出提醒窗口、关闭提醒后的负向测试。

## Commands Run

- `pnpm test src/membership/renewalReminder.test.ts`
- `pnpm test src/membership/MemberCenter.test.tsx`

## Known Risks

- 会员周期 ID 如果为空，关闭状态无法正确绑定；当前策略是不展示关闭后的抑制状态。

## Migration / Rollback

无数据库迁移。回滚 UI 和判断函数即可。

## QA Focus Areas

- 非会员不得看到提醒。
- 到期前 7 天边界。
- 关闭后刷新页面不再展示。
- 展示和关闭埋点准确。
