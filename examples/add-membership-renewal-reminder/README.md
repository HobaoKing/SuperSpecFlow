# 示例：会员续费提醒

本示例展示一次完整 SuperSpecFlow 循环：

```text
/ssf-think 会员续费提醒
/ssf-spec add-membership-renewal-reminder
/ssf-build all
/ssf-review
/ssf-qa add-membership-renewal-reminder
/ssf-ship add-membership-renewal-reminder
/ssf-commit add-membership-renewal-reminder
/ssf-pr add-membership-renewal-reminder
/ssf-archive add-membership-renewal-reminder
/ssf-retro add-membership-renewal-reminder
```

## Change ID

`add-membership-renewal-reminder`

## Spec IDs

- `MEMBERSHIP-001`：展示续费提醒入口。
- `MEMBERSHIP-002`：只在会员到期前 7 天内提醒。
- `MEMBERSHIP-003`：已关闭提醒的用户不再收到提醒。
- `MEMBERSHIP-004`：记录提醒展示和关闭事件。
- `MEMBERSHIP-N1`：不得向非会员展示续费提醒。
- `MEMBERSHIP-N2`：不得重复打扰已关闭提醒的用户。

## 目录

- `openspec/changes/add-membership-renewal-reminder/`：OpenSpec 风格变更合同。
- `engineering/add-membership-renewal-reminder/`：实现计划、spec-to-code-map、handoff。
- `qa/add-membership-renewal-reminder/`：验收、负向、风险、回归和 QA signoff。
- `release/add-membership-renewal-reminder/`：发布清单、回滚、监控、PR、ship decision。
- `archive/add-membership-renewal-reminder/`：归档摘要、决策记录、Git / PR 记录。
- `retro/`：复盘。
