功能(会员): 增加续费提醒入口

变更编号：add-membership-renewal-reminder
关联规格：MEMBERSHIP-001, MEMBERSHIP-002, MEMBERSHIP-003, MEMBERSHIP-004, MEMBERSHIP-N1, MEMBERSHIP-N2, MEMBERSHIP-N3

变更内容：
- 在会员中心为到期前 7 天内的会员展示续费提醒。
- 支持用户关闭本轮续费提醒。
- 记录提醒展示和关闭事件。

验证方式：
- 已运行 `pnpm test src/membership/renewalReminder.test.ts`。
- 已运行 `pnpm test src/membership/MemberCenter.test.tsx`。
- 已完成 QA signoff，结论为 Ship with monitoring。

风险与回滚：
- 主要风险是到期边界计算或关闭状态异常。
- 可回滚该提交移除会员中心提醒入口和展示判断。
