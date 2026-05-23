# PR：功能(会员): 增加续费提醒入口

## 变更编号

add-membership-renewal-reminder

## 关联规格

MEMBERSHIP-001, MEMBERSHIP-002, MEMBERSHIP-003, MEMBERSHIP-004, MEMBERSHIP-N1, MEMBERSHIP-N2, MEMBERSHIP-N3

## 变更摘要

在会员中心为到期前 7 天内的会员展示续费提醒，并允许关闭本轮提醒。

## 用户影响

即将到期会员可以提前看到续费入口。非会员和已关闭提醒用户不会被打扰。

## 主要改动

- 新增续费提醒展示判断。
- 新增会员中心提醒入口。
- 新增关闭提醒状态处理。
- 新增展示和关闭埋点。

## 验证方式

- `pnpm test src/membership/renewalReminder.test.ts`
- `pnpm test src/membership/MemberCenter.test.tsx`
- QA signoff：Ship with monitoring

## 风险

- 到期边界计算错误。
- 关闭提醒状态未正确生效。

## 回滚方案

回滚该 PR，移除会员中心提醒入口和展示判断。

## QA 结果

已覆盖验收、负向和回归路径，无 release blocker。

## 截图 / 录屏

不适用。

## 发布备注

上线后观察首日展示、点击、关闭和错误率。
