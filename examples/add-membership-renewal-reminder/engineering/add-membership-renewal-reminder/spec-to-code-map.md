# Spec to Code Map: add-membership-renewal-reminder

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| MEMBERSHIP-001 | 展示续费提醒入口 | `src/membership/renewalReminder.ts`, `src/membership/MemberCenter.tsx` | `src/membership/renewalReminder.test.ts`, `src/membership/MemberCenter.test.tsx` | Done |
| MEMBERSHIP-002 | 只在到期前 7 天内提醒 | `src/membership/renewalReminder.ts` | `src/membership/renewalReminder.test.ts` | Done |
| MEMBERSHIP-003 | 尊重关闭提醒 | `src/membership/renewalReminder.ts`, `src/membership/MemberCenter.tsx` | `src/membership/renewalReminder.test.ts`, `src/membership/MemberCenter.test.tsx` | Done |
| MEMBERSHIP-004 | 记录提醒事件 | `src/membership/MemberCenter.tsx`, `src/analytics/events.ts` | `src/membership/MemberCenter.test.tsx` | Done |
| MEMBERSHIP-N1 | 不向非会员展示 | `src/membership/renewalReminder.ts` | `src/membership/renewalReminder.test.ts` | Done |
| MEMBERSHIP-N2 | 不重复打扰已关闭用户 | `src/membership/renewalReminder.ts` | `src/membership/renewalReminder.test.ts` | Done |
| MEMBERSHIP-N3 | 不改变计费逻辑 | 无计费文件改动 | `git diff --stat` 人工检查 | Done |
