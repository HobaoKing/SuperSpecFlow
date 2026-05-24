# Proposal: browser-mcp-qa-adapter

## Summary

增强 `ssf-qa`，让它可以把 OpenSpec acceptance matrix 中的 E2E / user journey 场景转成可执行 QA 计划，并在存在可运行目标和浏览器/MCP 工具时执行真实用户路径。执行过程和结果必须落盘为 browser run report、QA evidence 和 evidence-backed QA signoff。

本 change 是 `workflow-scale-architecture` 的第一阶段 implementation change。它只处理单个 change 的浏览器/MCP QA 证据，不实现 Spec cluster、worktree 并行或 parent integration gate。

## Problem

当前 `ssf-qa` 能生成 acceptance matrix、negative tests、risk matrix、regression checklist、exploratory notes 和 QA signoff，但缺少把用户路径真正跑起来的文件协议。Agent 可能写出 QA 结论，却没有目标 URL、执行步骤、截图、日志摘要、失败点或 blocked 原因可复查。

当没有可运行目标或浏览器/MCP 工具不可用时，当前流程也缺少统一的 blocked 状态语义，容易把“无法执行”误写成“已通过”。

## Goals

- 新增 `.superspecflow/qa/<change-id>/qa-execution-plan.md` 协议。
- 新增 `.superspecflow/qa/<change-id>/browser-run-report.md` 协议。
- 新增 `.superspecflow/qa/<change-id>/qa-evidence/` 证据目录规则。
- 扩展 `qa-signoff.md` 的浏览器/MCP QA 状态枚举。
- 规定目标不可运行或工具不可用时必须写 blocked signoff。
- 将 execution plan、browser run report 和 evidence 规则接入 `ssf-qa`、`qa-gatekeeper`、templates、routing 和 pack validation。

## Non-goals

- 不实现 Spec cluster、worktree 并行或 parent integration gate。
- 不绑定具体 MCP server vendor 或浏览器工具内部 API。
- 不要求所有项目都必须有浏览器可运行目标。
- 不自动启动未知服务，不执行生产环境真实世界动作。
- 不保存 secrets、tokens、生产客户数据或敏感日志。
- 不替代 acceptance matrix、negative tests、risk matrix 或 regression checklist。

## User Impact

用户执行 `/ssf-qa <change-id>` 时，agent 可以把可执行用户路径写入 `qa-execution-plan.md`。如果目标和工具可用，agent 运行浏览器/MCP QA 并生成 `browser-run-report.md` 与 `qa-evidence/` 引用。如果无法运行，agent 在 `qa-signoff.md` 中写明 `Blocked: No runnable target` 或 `Blocked: Tool unavailable`，并给出人工验证替代步骤。

## Affected Areas

- `openspec/changes/browser-mcp-qa-adapter/`
- `skills/ssf-qa/SKILL.md`
- `agents/qa-gatekeeper.md`
- `templates/qa-execution-plan.md`
- `templates/browser-run-report.md`
- `templates/qa-signoff.md`
- `routing/AGENTS.routing.md`
- `routing/CLAUDE.routing.md`
- `commands/ssf-qa.md`
- `scripts/validate-pack.sh`
- `tests/qa/`
- `README.md`
- `engineering/browser-mcp-qa-adapter/`

## Success Metrics

- `ssf-qa` 规则明确从 acceptance matrix 生成 executable journey plan。
- QA signoff 的浏览器/MCP 状态只使用受控枚举。
- 没有可运行目标或工具不可用时，QA signoff 不会声明 `Automated Browser Passed`。
- Browser run report 引用 Spec ID、目标、工具、步骤结果、失败点和 evidence 路径。
- Pack validation 或 contract tests 能发现模板、routing 或 `ssf-qa` 规则缺失。

## Risks

- 不同项目的启动命令和测试目标差异大，自动发现可能不稳定。
- 浏览器截图或日志摘要可能包含敏感信息，需要明确脱敏和保存边界。
- 工具不可用会让 QA 经常进入 blocked，需要 signoff 清楚区分 blocked 与 failed。
- 如果 execution plan 过细，agent 维护成本会过高；第一版应保持最小字段。

## Rollout Strategy

第一版只定义文件协议、模板和 agent 规则，并通过 pack validation / contract tests 检查关键术语。实际浏览器工具调用遵循宿主环境可用能力：可运行则执行，不能运行则写 blocked signoff。

本 change 必须先于 `parallel-worktree-spec-clusters` 实现，除非用户在后者 proposal 中明确记录豁免原因和风险。

## Open Questions

- QA evidence 第一版是否只要求截图路径和文本摘要，还是同时标准化 trace / console / network 摘要字段？
- 可运行目标应优先由用户传入、环境变量、README 脚本，还是 agent 自动探测？
- 浏览器工具不可用时，manual fallback 是否足以让 recommendation 进入 `Ship with monitoring`，需要由具体 change 风险决定。
