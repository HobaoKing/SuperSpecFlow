# Decision: 会员续费提醒先放在会员中心

## Context

用户容易在会员到期后才发现权益中断，但本轮不希望扩大到站外通知或计费链路。

## Options

1. 会员中心提醒入口。
2. 全站 banner。
3. 邮件或短信提醒。

## Decision

先做会员中心提醒入口。

## Why

该方案影响面最小，可验证续费入口点击和用户反馈，同时避开通知退订、营销触达和支付链路风险。

## Consequences

- 曝光范围有限，但足够验证核心假设。
- 后续如果需要扩大触达，应新建 change-id 和 Spec ID。

## Follow-ups

- 评估实验分组。
- 评估是否扩展到邮件提醒。

## Linked Specs / PRs

- `openspec/changes/add-membership-renewal-reminder`
- PR：功能(会员): 增加续费提醒入口
