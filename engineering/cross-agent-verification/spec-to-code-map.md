# Spec to Code Map: cross-agent-verification

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SSF-XAV-001 | 定义 cross-agent verification handoff 目录 | `templates/verification-request.md`, `skills/ssf-review/SKILL.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md` | `tests/verification/test_cross_agent_verification_contract.bats` | Implemented |
| SSF-XAV-002 | 主 agent 写入核验请求 | `templates/verification-request.md`, `skills/ssf-review/SKILL.md` | `tests/verification/test_cross_agent_verification_contract.bats` | Implemented |
| SSF-XAV-003 | 主 agent 写入可复查 evidence | `templates/verification-evidence.md`, `skills/ssf-review/SKILL.md` | `tests/verification/test_cross_agent_verification_contract.bats` | Implemented |
| SSF-XAV-004 | review agent 只基于落盘事实核验 | `skills/ssf-review/SKILL.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md` | `tests/verification/test_cross_agent_verification_contract.bats`, `scripts/validate-pack.sh` | Implemented |
| SSF-XAV-005 | review agent 写入 reviewer notes | `templates/verification-reviewer-notes.md`, `skills/ssf-review/SKILL.md` | `tests/verification/test_cross_agent_verification_contract.bats` | Implemented |
| SSF-XAV-006 | signoff 结果使用受限枚举 | `templates/verification-signoff.md`, `skills/ssf-review/SKILL.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md` | `tests/verification/test_cross_agent_verification_contract.bats`, `scripts/validate-pack.sh` | Implemented |
| SSF-XAV-007 | signoff 列出核验依据和残余风险 | `templates/verification-signoff.md`, `skills/ssf-review/SKILL.md` | `tests/verification/test_cross_agent_verification_contract.bats` | Implemented |
| SSF-XAV-008 | 读取 progress-tracking 事实底座 | `templates/verification-request.md`, `skills/ssf-review/SKILL.md` | `tests/verification/test_cross_agent_verification_contract.bats` | Implemented |
| SSF-XAV-009 | progress 不可用时记录风险 | `templates/verification-reviewer-notes.md`, `templates/verification-signoff.md`, `skills/ssf-review/SKILL.md` | `tests/verification/test_cross_agent_verification_contract.bats` | Implemented |
| SSF-XAV-010 | 保持轻量 handoff | `skills/ssf-review/SKILL.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md` | `tests/verification/test_cross_agent_verification_contract.bats` | Implemented |
| SSF-XAV-011 | 提供 verification handoff 文件模板 | `templates/verification-request.md`, `templates/verification-evidence.md`, `templates/verification-reviewer-notes.md`, `templates/verification-signoff.md`, `README.md` | `tests/verification/test_cross_agent_verification_contract.bats`, `scripts/validate-pack.sh` | Implemented |
| SSF-XAV-012 | 明确 verification 运行时实例提交边界 | `.gitignore`, `scripts/validate-pack.sh`, `tests/smoke/test_artifact_policy.bats` | `rtk bash scripts/validate-pack.sh`, `rtk bats tests/smoke/test_artifact_policy.bats` | Implemented |

## MUST NOT 覆盖

| MUST NOT | 反向保护 | 测试 |
|---|---|---|
| SSF-XAV-N1 缺少 evidence 或 evidence 不可复查时不得 signoff | `skills/ssf-review/SKILL.md` 规定 evidence 缺失时只写 reviewer notes；`templates/verification-signoff.md` 强制 `Evidence Reviewed` 段 | `tests/verification/test_cross_agent_verification_contract.bats` |
| SSF-XAV-N2 不得把聊天上下文或未落盘声明作为依据 | `skills/ssf-review/SKILL.md` 和 routing 只允许 OpenSpec、diff、progress、evidence 输入 | `tests/verification/test_cross_agent_verification_contract.bats`, `scripts/validate-pack.sh` |
| SSF-XAV-N3 review agent 不得修改主 agent 的 request/evidence | `skills/ssf-review/SKILL.md` 固定主 agent 与 review agent 文件责任边界 | `tests/verification/test_cross_agent_verification_contract.bats` |
| SSF-XAV-N4 signoff 结果不得使用非法枚举 | `templates/verification-signoff.md` 固定 `approve | changes-requested | blocked`；`scripts/validate-pack.sh` 检测运行时 signoff 枚举 | `tests/verification/test_cross_agent_verification_contract.bats`, `scripts/validate-pack.sh` |
| SSF-XAV-N5 不得定义或实现 progress 文件协议 | OpenSpec design/proposal 只读依赖 progress；实现只引用 progress 路径，不新增 progress schema | `tests/verification/test_cross_agent_verification_contract.bats` |
| SSF-XAV-N6 不得要求两个 agent 自动通信 | `skills/ssf-review/SKILL.md` 和 routing 明确第一版为文件化 handoff | `tests/verification/test_cross_agent_verification_contract.bats` |
| SSF-XAV-N7 不得引入抽象共识协议、双签门禁或多方投票 | `skills/ssf-review/SKILL.md` 和 routing 保持轻量 handoff 边界 | `tests/verification/test_cross_agent_verification_contract.bats` |
| SSF-XAV-N8 本仓库不得提交 verification 运行时实例 | `.gitignore` 忽略 `.superspecflow/`；`scripts/validate-pack.sh` 和 smoke test 检查 Git 跟踪文件 | `tests/smoke/test_artifact_policy.bats`, `scripts/validate-pack.sh` |
