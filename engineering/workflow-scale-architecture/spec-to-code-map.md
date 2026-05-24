# Spec to Code Map: workflow-scale-architecture

本 change 是父级架构 contract。实现文件映射分为两类：

- `Architecture contract`：由本 change 的 OpenSpec 文件定义。
- `Deferred to child change`：具体实现延后到 `browser-mcp-qa-adapter` 或 `parallel-worktree-spec-clusters`。

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SSF-WORKFLOW-001 | 定义两阶段能力架构 | `openspec/changes/workflow-scale-architecture/proposal.md`, `openspec/changes/workflow-scale-architecture/design.md`, `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md` | `rtk bash scripts/validate-pack.sh` | Architecture contract |
| SSF-WORKFLOW-002 | 先建立 QA evidence 再扩展并行开发 | `openspec/changes/workflow-scale-architecture/proposal.md`, `openspec/changes/workflow-scale-architecture/design.md`, `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md` | `rtk bash scripts/validate-pack.sh` | Architecture contract |
| SSF-WORKFLOW-003 | 定义 QA evidence 为可复查事实来源 | `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md`; 后续 `openspec/changes/browser-mcp-qa-adapter/`, `skills/ssf-qa/SKILL.md`, `agents/qa-gatekeeper.md`, `templates/` | `rtk bash scripts/validate-pack.sh`; 后续 child contract tests | Deferred to child change |
| SSF-WORKFLOW-004 | 定义浏览器 QA 执行状态 | `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md`; 后续 `openspec/changes/browser-mcp-qa-adapter/`, `skills/ssf-qa/SKILL.md`, `templates/qa-signoff.md` | `rtk bash scripts/validate-pack.sh`; 后续 child contract tests | Deferred to child change |
| SSF-WORKFLOW-005 | 定义可执行用户路径计划 | `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md`; 后续 `templates/qa-execution-plan.md`, `skills/ssf-qa/SKILL.md` | `rtk bash scripts/validate-pack.sh`; 后续 child contract tests | Deferred to child change |
| SSF-WORKFLOW-006 | 定义浏览器执行报告 | `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md`; 后续 `templates/browser-run-report.md`, `skills/ssf-qa/SKILL.md` | `rtk bash scripts/validate-pack.sh`; 后续 child contract tests | Deferred to child change |
| SSF-WORKFLOW-007 | 定义 QA evidence 目录 | `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md`; 后续 `skills/ssf-qa/SKILL.md`, `agents/qa-gatekeeper.md`, `scripts/validate-pack.sh` | `rtk bash scripts/validate-pack.sh`; 后续 child contract tests | Deferred to child change |
| SSF-WORKFLOW-008 | 定义 parent change 与 Spec cluster | `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md`; 后续 `openspec/changes/parallel-worktree-spec-clusters/`, `skills/ssf-spec/SKILL.md`, `skills/ssf-build/SKILL.md` | `rtk bash scripts/validate-pack.sh`; 后续 child contract tests | Deferred to child change |
| SSF-WORKFLOW-009 | 定义 worktree 为执行隔离机制 | `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md`; 后续 `skills/ssf-git/SKILL.md`, `docs/branching-strategy.md` | `rtk bash scripts/validate-pack.sh`; 后续 child contract tests | Deferred to child change |
| SSF-WORKFLOW-010 | 定义 cluster plan | `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md`; 后续 `templates/cluster-plan.md`, `skills/ssf-spec/SKILL.md` | `rtk bash scripts/validate-pack.sh`; 后续 child contract tests | Deferred to child change |
| SSF-WORKFLOW-011 | 定义 cluster status | `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md`; 后续 `templates/cluster-status.md`, `skills/ssf-build/SKILL.md`, `skills/ssf-git/SKILL.md` | `rtk bash scripts/validate-pack.sh`; 后续 child contract tests | Deferred to child change |
| SSF-WORKFLOW-012 | 定义 parent integration gate | `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md`; 后续 `templates/integration-gate.md`, `skills/ssf-ship/SKILL.md` | `rtk bash scripts/validate-pack.sh`; 后续 child contract tests | Deferred to child change |
| SSF-WORKFLOW-013 | 定义 child changes 独立可审计 | `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md`; 后续 `skills/ssf-build/SKILL.md`, `skills/ssf-git/SKILL.md`, `skills/ssf-review/SKILL.md`, `skills/ssf-qa/SKILL.md` | `rtk bash scripts/validate-pack.sh`; 后续 child contract tests | Deferred to child change |
| SSF-WORKFLOW-014 | 定义 parent 汇总 QA 规则 | `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md`; 后续 `skills/ssf-qa/SKILL.md`, `skills/ssf-ship/SKILL.md`, `templates/integration-gate.md` | `rtk bash scripts/validate-pack.sh`; 后续 child contract tests | Deferred to child change |

## MUST NOT 覆盖

| MUST NOT | 反向保护 | 测试 |
|---|---|---|
| SSF-WORKFLOW-N1 不得用没有落盘 evidence 的聊天结论替代 QA signoff | 父级 spec 固定 violation signal；后续 `browser-mcp-qa-adapter` 必须在 `ssf-qa` 和 templates 中要求 evidence 引用 | `rtk bash scripts/validate-pack.sh`; 后续 child contract tests |
| SSF-WORKFLOW-N2 不得在目标或工具不可用时声明 `Automated Browser Passed` | 父级 spec 固定 blocked 状态；后续 `browser-mcp-qa-adapter` 必须限制 QA signoff 状态语义 | `rtk bash scripts/validate-pack.sh`; 后续 child contract tests |
| SSF-WORKFLOW-N3 Worktree 不得被当作发布边界 | 父级 spec 固定 parent integration gate；后续 `parallel-worktree-spec-clusters` 必须接入 `ssf-ship` | `rtk bash scripts/validate-pack.sh`; 后续 child contract tests |
| SSF-WORKFLOW-N4 Cluster 通过不得自动等同于 parent change 可发布 | 父级 spec 固定 integration gate requirement；后续 `parallel-worktree-spec-clusters` 必须要求 parent QA 汇总 | `rtk bash scripts/validate-pack.sh`; 后续 child contract tests |
| SSF-WORKFLOW-N5 多 cluster 并行不得绕过 change-id、Spec ID、Review、QA、Ship 或 Git gate | 父级 spec 固定 child 独立可审计规则；后续 child change 必须接入 build/review/qa/git/ship skills | `rtk bash scripts/validate-pack.sh`; 后续 child contract tests |
| SSF-WORKFLOW-N6 第一版不得实现后台调度器、自动 merge 服务或跨 agent 编排服务 | 父级 proposal/design/spec 固定 non-goals；后续 child changes 必须保持文件协议和人工确认边界 | `rtk bash scripts/validate-pack.sh`; 后续 child contract tests |
