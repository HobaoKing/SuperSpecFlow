# Spec to Code Map: progress-tracking

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SSF-PROGRESS-001 | 定义 change 级进度目录 | `skills/ssf-build/SKILL.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md` | `tests/progress/test_progress_contract.bats` | Implemented |
| SSF-PROGRESS-002 | 定义 `state.json` 当前状态协议 | `templates/progress-state.json`, `skills/ssf-build/SKILL.md` | `tests/progress/test_progress_contract.bats` | Implemented |
| SSF-PROGRESS-003 | 定义 `timeline.md` 事件记录 | `templates/progress-timeline.md`, `skills/ssf-build/SKILL.md` | `tests/progress/test_progress_contract.bats` | Implemented |
| SSF-PROGRESS-004 | 定义 `verification.md` 验证证据记录 | `templates/progress-verification.md`, `skills/ssf-build/SKILL.md` | `tests/progress/test_progress_contract.bats`, `scripts/validate-pack.sh` | Implemented |
| SSF-PROGRESS-005 | 定义 `handoff.md` 交接恢复摘要 | `templates/progress-handoff.md`, `skills/ssf-build/SKILL.md` | `tests/progress/test_progress_contract.bats` | Implemented |
| SSF-PROGRESS-006 | 恢复时先读 progress 状态 | `skills/ssf-build/SKILL.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md` | `tests/progress/test_progress_contract.bats`, `scripts/validate-pack.sh` | Implemented |
| SSF-PROGRESS-007 | 恢复时识别 progress 与 OpenSpec 差异 | `skills/ssf-build/SKILL.md` | `tests/progress/test_progress_contract.bats` | Implemented |
| SSF-PROGRESS-008 | 更新 progress 时保持状态时间戳 | `templates/progress-state.json`, `skills/ssf-build/SKILL.md` | `tests/progress/test_progress_contract.bats` | Implemented |
| SSF-PROGRESS-009 | 完成声明必须引用 fresh verification | `skills/ssf-build/SKILL.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md` | `tests/progress/test_progress_contract.bats`, `scripts/validate-pack.sh` | Implemented |
| SSF-PROGRESS-010 | 验证记录必须限定适用范围 | `templates/progress-verification.md`, `skills/ssf-build/SKILL.md` | `tests/progress/test_progress_contract.bats` | Implemented |
| SSF-PROGRESS-011 | 明确运行时实例提交边界 | `scripts/validate-pack.sh`, `tests/smoke/test_artifact_policy.bats` | `rtk bash scripts/validate-pack.sh`, `rtk bats tests/smoke/test_artifact_policy.bats` | Implemented |
| SSF-PROGRESS-012 | 提供 progress 文件模板 | `templates/progress-state.json`, `templates/progress-timeline.md`, `templates/progress-verification.md`, `templates/progress-handoff.md`, `README.md` | `tests/progress/test_progress_contract.bats`, `scripts/validate-pack.sh` | Implemented |

## MUST NOT 覆盖

| MUST NOT | 反向保护 | 测试 |
|---|---|---|
| SSF-PROGRESS-N1 progress 不得替代 OpenSpec 需求契约 | `skills/ssf-build/SKILL.md` 要求先读取 OpenSpec change，并把 progress 作为执行事实来源 | `tests/progress/test_progress_contract.bats` |
| SSF-PROGRESS-N2 恢复时不得跳过 `state.json` 和 `handoff.md` | `skills/ssf-build/SKILL.md` 与 routing 规定恢复时先读 progress，再读 OpenSpec | `tests/progress/test_progress_contract.bats`, `scripts/validate-pack.sh` |
| SSF-PROGRESS-N3 不得使用过期 verification 声明完成 | `skills/ssf-build/SKILL.md` 要求 fresh verification 晚于相关变更 | `tests/progress/test_progress_contract.bats`, `scripts/validate-pack.sh` |
| SSF-PROGRESS-N4 不得用窄范围验证声明宽范围完成 | `templates/progress-verification.md` 记录 Scope/Freshness；`skills/ssf-build/SKILL.md` 要求验证范围匹配完成声明 | `tests/progress/test_progress_contract.bats` |
| SSF-PROGRESS-N5 本仓库不得提交 progress 运行时实例 | `.gitignore` 忽略 `.superspecflow/`；`scripts/validate-pack.sh` 和 smoke test 检查 Git 跟踪文件 | `tests/smoke/test_artifact_policy.bats`, `scripts/validate-pack.sh` |
| SSF-PROGRESS-N6 第一版不得实现自动调度、UI 或跨 agent 签核 | 实现仅提供模板、routing/skill 规则和 validation，不引入调度器、UI 或签核运行时 | `tests/progress/test_progress_contract.bats`, `scripts/validate-pack.sh` |
