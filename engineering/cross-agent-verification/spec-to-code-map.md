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
