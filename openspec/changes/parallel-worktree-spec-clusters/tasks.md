# Tasks: parallel-worktree-spec-clusters

- [x] T1: 提供 cluster runtime 文件模板
  - Spec: SSF-CLUSTER-004, SSF-CLUSTER-005, SSF-CLUSTER-006, SSF-CLUSTER-012, SSF-CLUSTER-N4
  - Files: `templates/cluster-plan.md`, `templates/cluster-status.md`, `templates/integration-gate.md`
  - Test: `rtk bash scripts/validate-pack.sh`, `rtk bats tests/clusters/test_spec_clusters_contract.bats`
  - Acceptance: 模板包含 `.superspecflow/clusters/<parent-change>/cluster-plan.md`、`cluster-status.md`、`integration-gate.md` 路径和最小字段。
  - Estimate: 35 min

- [x] T2: 接入 ssf-spec 和 ssf-build cluster 规则
  - Spec: SSF-CLUSTER-001, SSF-CLUSTER-002, SSF-CLUSTER-003, SSF-CLUSTER-004, SSF-CLUSTER-005, SSF-CLUSTER-009, SSF-CLUSTER-N2, SSF-CLUSTER-N3
  - Files: `skills/ssf-spec/SKILL.md`, `skills/ssf-build/SKILL.md`, `commands/ssf-build.md`
  - Test: `rtk bash scripts/validate-pack.sh`, `rtk bats tests/clusters/test_spec_clusters_contract.bats`
  - Acceptance: `ssf-spec` 能提示 cluster 拆分阈值，`ssf-build` 能在 cluster 场景读取 plan、维护 status，并保持 cluster 独立可审计。
  - Estimate: 50 min

- [x] T3: 接入 ssf-git worktree 和分支规则
  - Spec: SSF-CLUSTER-007, SSF-CLUSTER-008, SSF-CLUSTER-009, SSF-CLUSTER-N1, SSF-CLUSTER-N3, SSF-CLUSTER-N7
  - Files: `skills/ssf-git/SKILL.md`, `commands/ssf-branch.md`, `docs/branching-strategy.md`
  - Test: `rtk bash scripts/validate-pack.sh`, `rtk bats tests/clusters/test_spec_clusters_contract.bats`
  - Acceptance: Git 规则说明 cluster 分支命名、worktree 只是执行隔离机制、清理 worktree 前必须检查未提交改动并获得用户批准。
  - Estimate: 40 min

- [x] T4: 接入 parent QA 和 ship integration gate
  - Spec: SSF-CLUSTER-006, SSF-CLUSTER-010, SSF-CLUSTER-011, SSF-CLUSTER-N1, SSF-CLUSTER-N2, SSF-CLUSTER-N4
  - Files: `skills/ssf-qa/SKILL.md`, `skills/ssf-ship/SKILL.md`, `commands/ssf-qa.md`, `commands/ssf-ship.md`
  - Test: `rtk bash scripts/validate-pack.sh`, `rtk bats tests/clusters/test_spec_clusters_contract.bats`
  - Acceptance: Parent `/ssf-qa` 汇总 cluster QA evidence；`ssf-ship` 缺少 integration gate 或 cluster evidence 时必须 no-ship 或 blocked。
  - Estimate: 45 min

- [x] T5: 接入 routing、README 和契约验证
  - Spec: SSF-CLUSTER-001, SSF-CLUSTER-004, SSF-CLUSTER-005, SSF-CLUSTER-006, SSF-CLUSTER-012, SSF-CLUSTER-N5, SSF-CLUSTER-N6
  - Files: `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `README.md`, `scripts/validate-pack.sh`, `tests/clusters/test_spec_clusters_contract.bats`, `engineering/parallel-worktree-spec-clusters/spec-to-code-map.md`
  - Test: `rtk bats tests/clusters/test_spec_clusters_contract.bats`, `rtk bash scripts/validate-pack.sh`
  - Acceptance: 自动化测试和 pack validation 能发现 cluster 模板缺失、routing 规则缺失、skill gate 缺失、越界跨仓库 cluster 或后台调度器规则。
  - Estimate: 50 min
