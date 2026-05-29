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
- `.superspecflow/engineering/add-membership-renewal-reminder/`：宿主项目中的实现计划和 handoff 运行时路径。
- `.superspecflow/maps/add-membership-renewal-reminder/spec-to-code-map.md`：宿主项目中的 spec-to-code map 运行时路径。
- `.superspecflow/qa/add-membership-renewal-reminder/`：宿主项目中的验收、负向、风险、回归和 QA signoff 运行时路径。
- `.superspecflow/release/add-membership-renewal-reminder/`：宿主项目中的发布清单、回滚、监控、PR、ship decision 运行时路径。
- `.superspecflow/archive/add-membership-renewal-reminder/`：宿主项目中的归档摘要、决策记录、Git / PR 记录运行时路径。
- `.superspecflow/retro/add-membership-renewal-reminder/`：宿主项目中的复盘运行时路径。

本示例目录下保留的 `engineering/`、`qa/`、`release/`、`archive/` 和 `retro/` 是历史示例产物，用于展示完整流程内容；新宿主项目写入运行时产物时应使用 `.superspecflow/` 标准路径。
