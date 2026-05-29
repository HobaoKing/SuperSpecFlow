# Proposal: visual-ui-qa-adapter

## Summary

新增 `visual-ui-qa-adapter`，让 `ssf-qa` 可以记录跨 Web 和小程序的视觉验收协议。第一版聚焦协议和门禁：从 acceptance matrix 中识别需要 UI 视觉还原或截图对比的场景，生成视觉执行计划，记录 baseline / actual / diff 证据和 comparison report，并在 QA signoff 中使用受控视觉状态。

本 change 是 `browser-mcp-qa-adapter` 之后的 QA 能力增强。它不替代浏览器/MCP 用户路径执行，也不内置截图或图片 diff 工具。

## Problem

当前 `browser-mcp-qa-adapter` 能让 QA 记录浏览器/MCP 用户路径证据，但它没有定义 UI 视觉验收的独立协议。Web 和小程序场景经常需要截图对比、历史基线回归、设计稿或参考图校验，以及 UI 1:1 还原判断。如果这些证据只停留在聊天记录里，Review、Ship 和 Git gate 无法复查视觉结论。

同时，小程序端工具链差异较大。如果第一版直接绑定微信开发者工具、某个模拟器或某个 diff 算法，会让 SuperSpecFlow 从流程包膨胀成具体执行器，后续难以兼容其它小程序环境。

## Goals

- 新增 `.superspecflow/qa/<change-id>/visual-execution-plan.md` 协议。
- 新增 `.superspecflow/qa/<change-id>/visual-comparison-report.md` 协议。
- 规定 `.superspecflow/qa/<change-id>/qa-evidence/visual/` 存放视觉证据引用。
- 支持 `web` 和 `mini-program` 平台声明。
- 记录 baseline、actual、diff 或人工对比证据。
- 规定截图可比性字段：route/page、viewport/device、DPR、主题、语言、环境、数据前置条件、截图来源和时间。
- 定义 baseline 建立、确认和更新规则。
- 区分自动 diff 通过、人工视觉验收、失败和 blocked 状态。
- 将视觉 QA 协议接入 `ssf-qa`、`qa-gatekeeper`、templates、routing 和 pack validation。

## Non-goals

- 不内置真实图片 diff 算法。
- 不实现 Playwright 截图执行器。
- 不绑定微信开发者工具、小程序 CLI、模拟器或具体 runner。
- 不接入 Figma、蓝湖、即时设计或其它设计工具 API。
- 不要求所有项目都必须执行自动视觉 diff。
- 不替代 acceptance matrix、browser run report、negative tests、risk matrix 或 regression checklist。
- 不把 actual 截图自动提升为 baseline。
- 不保存 secrets、tokens、生产客户数据、未脱敏个人信息或敏感日志。

## User Impact

用户执行 `/ssf-qa <change-id>` 时，agent 可以把需要 UI 1:1 还原、截图对比或视觉回归的场景写入 `visual-execution-plan.md`。如果项目提供 baseline 和 actual 截图，以及外部 diff 或人工对比结果，agent 将视觉结论写入 `visual-comparison-report.md` 并在 QA signoff 中引用证据。

如果缺少 baseline、actual 截图或声明需要自动 diff 但工具不可用，agent 必须使用明确 blocked 状态或人工视觉验收状态，不得伪装成自动通过。

## Affected Areas

- `openspec/changes/visual-ui-qa-adapter/`
- `skills/ssf-qa/SKILL.md`
- `agents/qa-gatekeeper.md`
- `commands/ssf-qa.md`
- `templates/visual-execution-plan.md`
- `templates/visual-comparison-report.md`
- `templates/qa-signoff.md`
- `routing/AGENTS.routing.md`
- `routing/CLAUDE.routing.md`
- `scripts/validate-pack.sh`
- `tests/qa/`
- `README.md`
- `engineering/visual-ui-qa-adapter/`

## Success Metrics

- `ssf-qa` 明确支持视觉 QA plan 和 visual comparison report。
- Web 和小程序截图都使用同一套 platform / screenshot / baseline / actual / diff 证据协议。
- 视觉计划和对比报告显式支持 optional reference image/design source 字段，但第一版不接入设计工具 API。
- `Visual Passed` 只能在 baseline、actual、comparison report 和阈值结果齐全时使用。
- `Manual Visual Verified` 必须记录人工验收人、基准、差异判断和残余风险。
- 缺少 baseline、actual 截图或 diff 工具时不会声明自动视觉通过。
- Pack validation 或 contract tests 能发现模板、routing 或 `ssf-qa` 视觉门禁规则缺失。

## Risks

- 不同工具生成的截图可能因 DPR、字体、主题、语言或数据状态不同而不可比。
- 小程序截图来源不统一，第一版只能定义协议和 blocked / manual 边界。
- 视觉 evidence 可能包含敏感业务数据，需要继承 QA evidence 的脱敏约束。
- 不内置 diff 工具会让第一版依赖外部工具或人工验收；必须用状态枚举清楚表达自动化覆盖程度。
- Baseline 更新如果没有确认规则，可能把视觉回归固化为新基线。

## Rollout Strategy

第一版只定义 OpenSpec、模板、agent 规则、routing 说明和 contract tests。执行层由宿主项目选择：Web 可以用 Playwright 或其它工具截图，小程序可以由外部 runner 或人工导出截图，图片 diff 可以由任意外部工具或人工对比提供。

实现顺序应在 `browser-mcp-qa-adapter` 门禁收尾之后进行。该 change 不需要拆成 parent / child，也不需要 Spec cluster；只有当后续同时实现具体截图执行器、小程序 runner 和图片 diff 算法时，才应拆分为独立 implementation changes。

## Open Questions

- 已决策：视觉阈值第一版记录外部工具输出，并要求 report 至少包含 threshold、actual difference summary、ignored regions 和 result；不定义具体算法。
- 已决策：`Manual Visual Verified` 的 reviewer 使用自由文本标识，必须足以让宿主项目追溯人工验收来源。
- 已决策：第一版保留 optional reference image/design source 字段，但不接入 Figma、蓝湖、即时设计或其它设计工具 API。
