# Spec: membership

## ADDED Requirements

### Requirement: MEMBERSHIP-001 展示续费提醒入口

系统必须在会员中心向符合条件的用户展示续费提醒入口。

#### Scenario: 到期前会员看到提醒
- GIVEN 用户是有效会员
- AND 会员将在 7 天内到期
- AND 用户未关闭本轮提醒
- WHEN 用户打开会员中心
- THEN 系统展示续费提醒入口

### Requirement: MEMBERSHIP-002 只在到期前 7 天内提醒

系统必须只在会员到期前 7 天内展示续费提醒。

#### Scenario: 到期时间超过 7 天
- GIVEN 用户是有效会员
- AND 会员将在 8 天后到期
- WHEN 用户打开会员中心
- THEN 系统不展示续费提醒入口

### Requirement: MEMBERSHIP-003 尊重关闭提醒

系统必须在用户关闭本轮续费提醒后停止展示提醒。

#### Scenario: 用户关闭提醒
- GIVEN 用户符合续费提醒条件
- WHEN 用户点击关闭提醒
- THEN 系统记录关闭状态
- AND 下次打开会员中心时不再展示提醒

### Requirement: MEMBERSHIP-004 记录提醒事件

系统必须记录续费提醒展示和关闭事件。

#### Scenario: 提醒被展示
- GIVEN 用户符合续费提醒条件
- WHEN 系统展示续费提醒
- THEN 系统记录 `membership_renewal_reminder_shown`

#### Scenario: 提醒被关闭
- GIVEN 用户看到续费提醒
- WHEN 用户关闭提醒
- THEN 系统记录 `membership_renewal_reminder_dismissed`

## MODIFIED Requirements

无。

## REMOVED Requirements

无。

## MUST NOT

- MEMBERSHIP-N1 系统不得向非会员展示续费提醒。
- MEMBERSHIP-N2 系统不得向已关闭本轮提醒的用户重复展示续费提醒。
- MEMBERSHIP-N3 系统不得改变支付、订阅、退款或计费逻辑。
