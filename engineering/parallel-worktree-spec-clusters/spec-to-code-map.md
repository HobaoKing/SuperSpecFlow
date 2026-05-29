# Spec to Code Map: parallel-worktree-spec-clusters

| Spec ID | Requirement | Implementation Files | Tests | Status |
|---|---|---|---|---|
| SSF-CLUSTER-001 | 定义 parent change | `openspec/changes/parallel-worktree-spec-clusters/`, `skills/ssf-spec/SKILL.md` | `tests/clusters/test_spec_clusters_contract.bats` | Implemented |
| SSF-CLUSTER-002 | 定义 Spec cluster | `skills/ssf-spec/SKILL.md`, `templates/cluster-plan.md` | `tests/clusters/test_spec_clusters_contract.bats` | Implemented |
| SSF-CLUSTER-003 | 定义拆分评估阈值 | `skills/ssf-spec/SKILL.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md` | `tests/clusters/test_spec_clusters_contract.bats`, `rtk bash scripts/validate-pack.sh` | Implemented |
| SSF-CLUSTER-004 | 定义 cluster plan | `templates/cluster-plan.md`, `skills/ssf-build/SKILL.md` | `tests/clusters/test_spec_clusters_contract.bats` | Implemented |
| SSF-CLUSTER-005 | 定义 cluster status | `templates/cluster-status.md`, `skills/ssf-build/SKILL.md` | `tests/clusters/test_spec_clusters_contract.bats` | Implemented |
| SSF-CLUSTER-006 | 定义 integration gate | `templates/integration-gate.md`, `skills/ssf-ship/SKILL.md`, `commands/ssf-ship.md` | `tests/clusters/test_spec_clusters_contract.bats` | Implemented |
| SSF-CLUSTER-007 | 定义 worktree 命名规则 | `skills/ssf-git/SKILL.md`, `commands/ssf-branch.md` | `tests/clusters/test_spec_clusters_contract.bats` | Implemented |
| SSF-CLUSTER-008 | 定义 cluster 分支命名规则 | `skills/ssf-git/SKILL.md`, `commands/ssf-branch.md` | `tests/clusters/test_spec_clusters_contract.bats` | Implemented |
| SSF-CLUSTER-009 | 保持 cluster 独立可审计 | `skills/ssf-build/SKILL.md`, `skills/ssf-git/SKILL.md`, `templates/cluster-status.md` | `tests/clusters/test_spec_clusters_contract.bats` | Implemented |
| SSF-CLUSTER-010 | 定义 parent QA 汇总 | `skills/ssf-qa/SKILL.md`, `commands/ssf-qa.md` | `tests/clusters/test_spec_clusters_contract.bats` | Implemented |
| SSF-CLUSTER-011 | 定义 parent ship gate | `skills/ssf-ship/SKILL.md`, `commands/ssf-ship.md`, `templates/integration-gate.md` | `tests/clusters/test_spec_clusters_contract.bats` | Implemented |
| SSF-CLUSTER-012 | 接入 routing 和 pack validation | `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `scripts/validate-pack.sh`, `README.md` | `rtk bash scripts/validate-pack.sh` | Implemented |

## MUST NOT Coverage

| MUST NOT | Guard | Tests |
|---|---|---|
| SSF-CLUSTER-N1 | `ssf-ship` states worktree is not release boundary. | `tests/clusters/test_spec_clusters_contract.bats` |
| SSF-CLUSTER-N2 | Integration gate required before parent ship. | `templates/integration-gate.md`, `skills/ssf-ship/SKILL.md` |
| SSF-CLUSTER-N3 | Cluster evidence still requires Spec ID, QA, review, and Git evidence. | `templates/cluster-status.md`, `templates/integration-gate.md` |
| SSF-CLUSTER-N4 | Missing integration gate blocks parent ship. | `skills/ssf-ship/SKILL.md` |
| SSF-CLUSTER-N5 | No background scheduler or auto merge service is introduced. | `scripts/validate-pack.sh` |
| SSF-CLUSTER-N6 | First version remains same-repository only. | `openspec/changes/parallel-worktree-spec-clusters/specs/spec-clusters.md` |
| SSF-CLUSTER-N7 | Worktree cleanup requires user approval. | `skills/ssf-git/SKILL.md` |
