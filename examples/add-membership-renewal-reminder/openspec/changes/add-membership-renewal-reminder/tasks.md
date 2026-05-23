# Tasks: add-membership-renewal-reminder

- [x] T1: 增加续费提醒展示判断
  - Spec: MEMBERSHIP-001, MEMBERSHIP-002, MEMBERSHIP-N1
  - Files: `src/membership/renewalReminder.ts`
  - Test: `src/membership/renewalReminder.test.ts`
  - Acceptance: 非会员不展示，到期前 7 天内会员展示，8 天后到期不展示。
  - Estimate: 30 min

- [x] T2: 增加关闭提醒状态处理
  - Spec: MEMBERSHIP-003, MEMBERSHIP-N2
  - Files: `src/membership/renewalReminder.ts`, `src/membership/MemberCenter.tsx`
  - Test: `src/membership/renewalReminder.test.ts`
  - Acceptance: 用户关闭本轮提醒后不再展示。
  - Estimate: 30 min

- [x] T3: 增加会员中心提醒入口
  - Spec: MEMBERSHIP-001, MEMBERSHIP-003
  - Files: `src/membership/MemberCenter.tsx`
  - Test: `src/membership/MemberCenter.test.tsx`
  - Acceptance: 符合条件时出现续费入口，点击关闭后入口消失。
  - Estimate: 45 min

- [x] T4: 增加展示和关闭事件
  - Spec: MEMBERSHIP-004
  - Files: `src/membership/MemberCenter.tsx`, `src/analytics/events.ts`
  - Test: `src/membership/MemberCenter.test.tsx`
  - Acceptance: 展示和关闭均触发对应事件。
  - Estimate: 30 min
