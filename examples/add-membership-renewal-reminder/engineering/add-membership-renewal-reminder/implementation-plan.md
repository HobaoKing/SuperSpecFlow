# Implementation Plan: add-membership-renewal-reminder

## Scope Boundary
- In scope: 会员中心续费提醒展示、关闭、埋点。
- Out of scope: 支付、订阅、退款、价格、站外通知。

## Task Order
1. 先写展示判断的单元测试。
2. 实现最小判断函数。
3. 写关闭提醒测试并实现关闭状态判断。
4. 写会员中心组件测试。
5. 增加 UI 入口和埋点。
6. 更新 spec-to-code-map 和 tasks。

## Test Strategy
- Unit: 展示判断函数覆盖会员、非会员、到期窗口和关闭状态。
- Integration: 会员中心渲染提醒、关闭提醒、埋点。
- E2E: 手工验证会员中心关键路径。
- Negative: 非会员、8 天后到期、已关闭提醒均不展示。

## Files Expected to Change

- `src/membership/renewalReminder.ts`
- `src/membership/renewalReminder.test.ts`
- `src/membership/MemberCenter.tsx`
- `src/membership/MemberCenter.test.tsx`
- `src/analytics/events.ts`

## Risks / Pause Conditions

- 发现需要修改支付或订阅逻辑时暂停。
- 发现会员周期 ID 不可用时暂停并回到 spec。
- 发现关闭状态需要数据库迁移时暂停并补 migration plan。
