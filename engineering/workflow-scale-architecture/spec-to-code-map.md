# Spec to Code Map: workflow-scale-architecture

本 change 是父级架构 contract。实现文件映射分为三类：

- `Architecture contract`：由本 change 的 OpenSpec 文件定义。
- `Child OpenSpec implemented`：已由 child change contract 和对应契约测试承接实现。
- `Routing documented`：已同步到 README、AGENTS 或 routing，用作执行入口说明。

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SSF-WORKFLOW-001 | 定义两阶段能力架构 | `openspec/changes/workflow-scale-architecture/`, `openspec/changes/browser-mcp-qa-adapter/`, `openspec/changes/parallel-worktree-spec-clusters/`, `README.md`, `AGENTS.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `REVIEW_NOTES.md` | `rtk bash scripts/validate-pack.sh` | Routing documented |
| SSF-WORKFLOW-002 | 先建立 QA evidence 再扩展并行开发 | `openspec/changes/workflow-scale-architecture/`, `openspec/changes/browser-mcp-qa-adapter/`, `openspec/changes/parallel-worktree-spec-clusters/`, `README.md`, `AGENTS.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md` | `rtk bash scripts/validate-pack.sh` | Routing documented |
| SSF-WORKFLOW-003 | 定义 QA evidence 为可复查事实来源 | `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md`, `openspec/changes/browser-mcp-qa-adapter/`, `README.md`, `AGENTS.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md` | `rtk bash scripts/validate-pack.sh`; child contract tests | Child OpenSpec implemented |
| SSF-WORKFLOW-004 | 定义浏览器 QA 执行状态 | `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md`, `openspec/changes/browser-mcp-qa-adapter/`, `AGENTS.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md` | `rtk bash scripts/validate-pack.sh`; child contract tests | Child OpenSpec implemented |
| SSF-WORKFLOW-005 | 定义可执行用户路径计划 | `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md`, `openspec/changes/browser-mcp-qa-adapter/`, `README.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md` | `rtk bash scripts/validate-pack.sh`; child contract tests | Child OpenSpec implemented |
| SSF-WORKFLOW-006 | 定义浏览器执行报告 | `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md`, `openspec/changes/browser-mcp-qa-adapter/`, `README.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md` | `rtk bash scripts/validate-pack.sh`; child contract tests | Child OpenSpec implemented |
| SSF-WORKFLOW-007 | 定义 QA evidence 目录 | `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md`, `openspec/changes/browser-mcp-qa-adapter/`, `README.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md` | `rtk bash scripts/validate-pack.sh`; child contract tests | Child OpenSpec implemented |
| SSF-WORKFLOW-008 | 定义 parent change 与 Spec cluster | `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md`, `openspec/changes/parallel-worktree-spec-clusters/`, `README.md`, `AGENTS.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md` | `rtk bash scripts/validate-pack.sh`; child contract tests | Child OpenSpec implemented |
| SSF-WORKFLOW-009 | 定义 worktree 为执行隔离机制 | `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md`, `openspec/changes/parallel-worktree-spec-clusters/`, `README.md`, `AGENTS.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md` | `rtk bash scripts/validate-pack.sh`; child contract tests | Child OpenSpec implemented |
| SSF-WORKFLOW-010 | 定义 cluster plan | `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md`, `openspec/changes/parallel-worktree-spec-clusters/`, `README.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md` | `rtk bash scripts/validate-pack.sh`; child contract tests | Child OpenSpec implemented |
| SSF-WORKFLOW-011 | 定义 cluster status | `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md`, `openspec/changes/parallel-worktree-spec-clusters/`, `README.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md` | `rtk bash scripts/validate-pack.sh`; child contract tests | Child OpenSpec implemented |
| SSF-WORKFLOW-012 | 定义 parent integration gate | `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md`, `openspec/changes/parallel-worktree-spec-clusters/`, `README.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md` | `rtk bash scripts/validate-pack.sh`; child contract tests | Child OpenSpec implemented |
| SSF-WORKFLOW-013 | 定义 child changes 独立可审计 | `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md`, `openspec/changes/browser-mcp-qa-adapter/`, `openspec/changes/parallel-worktree-spec-clusters/` | `rtk bash scripts/validate-pack.sh`; child contract tests | Child OpenSpec implemented |
| SSF-WORKFLOW-014 | 定义 parent 汇总 QA 规则 | `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md`, `openspec/changes/parallel-worktree-spec-clusters/`, `README.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md` | `rtk bash scripts/validate-pack.sh`; child contract tests | Child OpenSpec implemented |

## MUST NOT 覆盖

| MUST NOT | 反向保护 | 测试 |
|---|---|---|
| SSF-WORKFLOW-N1 不得用没有落盘 evidence 的聊天结论替代 QA signoff | 父级 spec 固定 violation signal；`browser-mcp-qa-adapter` child OpenSpec 定义 evidence-backed signoff；routing/README/AGENTS 记录 browser QA blocked 边界 | `rtk bash scripts/validate-pack.sh`; child contract tests |
| SSF-WORKFLOW-N2 不得在目标或工具不可用时声明 `Automated Browser Passed` | 父级 spec 固定 blocked 状态；`browser-mcp-qa-adapter` child OpenSpec 和 routing 记录 `Blocked: No runnable target` / `Blocked: Tool unavailable` | `rtk bash scripts/validate-pack.sh`; child contract tests |
| SSF-WORKFLOW-N3 Worktree 不得被当作发布边界 | 父级 spec 固定 parent integration gate；`parallel-worktree-spec-clusters` child OpenSpec 和 routing 记录 worktree 只是执行隔离机制 | `rtk bash scripts/validate-pack.sh`; child contract tests |
| SSF-WORKFLOW-N4 Cluster 通过不得自动等同于 parent change 可发布 | 父级 spec 固定 integration gate requirement；`parallel-worktree-spec-clusters` child OpenSpec 和 routing 记录 parent QA / ship gate | `rtk bash scripts/validate-pack.sh`; child contract tests |
| SSF-WORKFLOW-N5 多 cluster 并行不得绕过 change-id、Spec ID、Review、QA、Ship 或 Git gate | 父级 spec 固定 child 独立可审计规则；两个 child OpenSpec 保持独立 proposal/spec/design/tasks/readiness review | `rtk bash scripts/validate-pack.sh`; child contract tests |
| SSF-WORKFLOW-N6 第一版不得实现后台调度器、自动 merge 服务或跨 agent 编排服务 | 父级 proposal/design/spec 固定 non-goals；`parallel-worktree-spec-clusters` child OpenSpec 明确不实现后台调度器、自动 merge 或跨 agent 编排 | `rtk bash scripts/validate-pack.sh`; child contract tests |
