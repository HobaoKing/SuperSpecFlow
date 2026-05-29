# Spec to Code Map: visual-ui-qa-adapter

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SSF-QA-VISUAL-001 | 定义视觉 QA 执行计划 | `templates/visual-execution-plan.md`, `skills/ssf-qa/SKILL.md`, `commands/ssf-qa.md` | `tests/qa/test_visual_ui_qa_contract.bats` | Implemented |
| SSF-QA-VISUAL-002 | 支持 Web 和小程序平台声明 | `templates/visual-execution-plan.md`, `skills/ssf-qa/SKILL.md`, `agents/qa-gatekeeper.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md` | `tests/qa/test_visual_ui_qa_contract.bats` | Implemented |
| SSF-QA-VISUAL-003 | 记录截图可比性字段 | `templates/visual-execution-plan.md`, `templates/visual-comparison-report.md` | `tests/qa/test_visual_ui_qa_contract.bats` | Implemented |
| SSF-QA-VISUAL-004 | 定义视觉证据协议 | `templates/visual-comparison-report.md`, `templates/qa-signoff.md` | `tests/qa/test_visual_ui_qa_contract.bats` | Implemented |
| SSF-QA-VISUAL-005 | 定义视觉 QA 状态枚举和通过门禁 | `templates/qa-signoff.md`, `skills/ssf-qa/SKILL.md`, `agents/qa-gatekeeper.md` | `tests/qa/test_visual_ui_qa_contract.bats` | Implemented |
| SSF-QA-VISUAL-006 | 定义 baseline 生命周期 | `templates/visual-execution-plan.md`, `templates/visual-comparison-report.md`, `skills/ssf-qa/SKILL.md`, `agents/qa-gatekeeper.md` | `tests/qa/test_visual_ui_qa_contract.bats` | Implemented |
| SSF-QA-VISUAL-007 | 区分自动 diff 与人工视觉验收 | `templates/visual-comparison-report.md`, `templates/qa-signoff.md`, `skills/ssf-qa/SKILL.md` | `tests/qa/test_visual_ui_qa_contract.bats` | Implemented |
| SSF-QA-VISUAL-008 | 保持视觉 QA 与现有 QA 产物一致 | `skills/ssf-qa/SKILL.md`, `templates/qa-signoff.md` | `tests/qa/test_visual_ui_qa_contract.bats` | Implemented |
| SSF-QA-VISUAL-009 | 提供可复用视觉 QA 模板 | `templates/visual-execution-plan.md`, `templates/visual-comparison-report.md`, `templates/qa-signoff.md` | `tests/qa/test_visual_ui_qa_contract.bats` | Implemented |
| SSF-QA-VISUAL-010 | 接入 routing 和 pack validation | `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `scripts/validate-pack.sh`, `README.md` | `tests/qa/test_visual_ui_qa_contract.bats`, `rtk bash scripts/validate-pack.sh` | Implemented |

## MUST NOT 覆盖

| MUST NOT | Guardrail | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SSF-QA-VISUAL-N1 | 缺少 baseline 或 baseline 未确认时不得声明 `Visual Passed` | `templates/qa-signoff.md`, `skills/ssf-qa/SKILL.md` | `tests/qa/test_visual_ui_qa_contract.bats` | Implemented |
| SSF-QA-VISUAL-N2 | 缺少 actual screenshot 时不得声明视觉通过 | `templates/qa-signoff.md`, `skills/ssf-qa/SKILL.md` | `tests/qa/test_visual_ui_qa_contract.bats` | Implemented |
| SSF-QA-VISUAL-N3 | 视觉计划不得替代 acceptance matrix | `skills/ssf-qa/SKILL.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md` | `tests/qa/test_visual_ui_qa_contract.bats` | Implemented |
| SSF-QA-VISUAL-N4 | 聊天描述不得替代落盘 evidence | `skills/ssf-qa/SKILL.md`, `agents/qa-gatekeeper.md` | `tests/qa/test_visual_ui_qa_contract.bats` | Implemented |
| SSF-QA-VISUAL-N5 | diff 工具不可用时不得伪装自动通过 | `templates/qa-signoff.md`, `skills/ssf-qa/SKILL.md` | `tests/qa/test_visual_ui_qa_contract.bats` | Implemented |
| SSF-QA-VISUAL-N6 | actual screenshot 不得自动提升为 baseline | `templates/visual-comparison-report.md`, `skills/ssf-qa/SKILL.md` | `tests/qa/test_visual_ui_qa_contract.bats` | Implemented |
| SSF-QA-VISUAL-N7 | 视觉 evidence 不得包含敏感数据 | `templates/visual-comparison-report.md`, `skills/ssf-qa/SKILL.md`, `agents/qa-gatekeeper.md` | `tests/qa/test_visual_ui_qa_contract.bats` | Implemented |
| SSF-QA-VISUAL-N8 | 第一版不得绑定具体小程序 runner 或图片 diff 算法 | `openspec/changes/visual-ui-qa-adapter/specs/visual-ui.md`, `skills/ssf-qa/SKILL.md`, `agents/qa-gatekeeper.md` | `tests/qa/test_visual_ui_qa_contract.bats` | Implemented |
