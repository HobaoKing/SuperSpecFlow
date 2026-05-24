# Tasks: workflow-scale-architecture

- [x] T1: 锁定 workflow scale 父级架构 contract
  - Spec: SSF-WORKFLOW-001, SSF-WORKFLOW-002, SSF-WORKFLOW-003, SSF-WORKFLOW-004, SSF-WORKFLOW-005, SSF-WORKFLOW-006, SSF-WORKFLOW-007, SSF-WORKFLOW-008, SSF-WORKFLOW-009, SSF-WORKFLOW-010, SSF-WORKFLOW-011, SSF-WORKFLOW-012, SSF-WORKFLOW-013, SSF-WORKFLOW-014, SSF-WORKFLOW-N1, SSF-WORKFLOW-N2, SSF-WORKFLOW-N3, SSF-WORKFLOW-N4, SSF-WORKFLOW-N5, SSF-WORKFLOW-N6
  - Files: `openspec/changes/workflow-scale-architecture/proposal.md`, `openspec/changes/workflow-scale-architecture/design.md`, `openspec/changes/workflow-scale-architecture/specs/workflow-scale.md`, `openspec/changes/workflow-scale-architecture/tasks.md`
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: 父级规格只定义总架构、阶段顺序、产物协议和门禁关系，不实现 `browser-mcp-qa-adapter` 或 `parallel-worktree-spec-clusters` 的具体行为。
  - Estimate: 30 min

- [ ] T2: 创建 browser MCP QA adapter child OpenSpec 骨架
  - Spec: SSF-WORKFLOW-001, SSF-WORKFLOW-002, SSF-WORKFLOW-003, SSF-WORKFLOW-004, SSF-WORKFLOW-005, SSF-WORKFLOW-006, SSF-WORKFLOW-007, SSF-WORKFLOW-N1, SSF-WORKFLOW-N2
  - Files: `openspec/changes/browser-mcp-qa-adapter/proposal.md`, `openspec/changes/browser-mcp-qa-adapter/design.md`, `openspec/changes/browser-mcp-qa-adapter/tasks.md`, `openspec/changes/browser-mcp-qa-adapter/specs/qa-browser.md`, `engineering/browser-mcp-qa-adapter/spec-readiness-review.md`
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: 子级 OpenSpec 明确 QA 执行计划、浏览器运行报告、QA evidence 路径、blocked 状态和 rollout 边界，但不包含 worktree cluster 行为。
  - Estimate: 45 min

- [ ] T3: 创建 parallel worktree Spec clusters child OpenSpec 骨架
  - Spec: SSF-WORKFLOW-001, SSF-WORKFLOW-002, SSF-WORKFLOW-008, SSF-WORKFLOW-009, SSF-WORKFLOW-010, SSF-WORKFLOW-011, SSF-WORKFLOW-012, SSF-WORKFLOW-013, SSF-WORKFLOW-014, SSF-WORKFLOW-N3, SSF-WORKFLOW-N4, SSF-WORKFLOW-N5, SSF-WORKFLOW-N6
  - Files: `openspec/changes/parallel-worktree-spec-clusters/proposal.md`, `openspec/changes/parallel-worktree-spec-clusters/design.md`, `openspec/changes/parallel-worktree-spec-clusters/tasks.md`, `openspec/changes/parallel-worktree-spec-clusters/specs/spec-clusters.md`, `engineering/parallel-worktree-spec-clusters/spec-readiness-review.md`
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: 子级 OpenSpec 明确 parent / cluster 契约、worktree 命名、cluster plan、cluster status、integration gate 和 parent QA 汇总规则，但不实现 browser QA 内部执行逻辑。
  - Estimate: 45 min

- [ ] T4: 同步顶层路线图和路由说明
  - Spec: SSF-WORKFLOW-001, SSF-WORKFLOW-002, SSF-WORKFLOW-003, SSF-WORKFLOW-008, SSF-WORKFLOW-014
  - Files: `README.md`, `AGENTS.md`, `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `REVIEW_NOTES.md`
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: 顶层文档记录 `workflow-scale-architecture`、两个 child changes 的阶段顺序、QA evidence 优先原则和 parent integration gate 边界。
  - Estimate: 30 min

- [ ] T5: 维护父级架构 spec-to-code map
  - Spec: SSF-WORKFLOW-001, SSF-WORKFLOW-002, SSF-WORKFLOW-003, SSF-WORKFLOW-004, SSF-WORKFLOW-005, SSF-WORKFLOW-006, SSF-WORKFLOW-007, SSF-WORKFLOW-008, SSF-WORKFLOW-009, SSF-WORKFLOW-010, SSF-WORKFLOW-011, SSF-WORKFLOW-012, SSF-WORKFLOW-013, SSF-WORKFLOW-014, SSF-WORKFLOW-N1, SSF-WORKFLOW-N2, SSF-WORKFLOW-N3, SSF-WORKFLOW-N4, SSF-WORKFLOW-N5, SSF-WORKFLOW-N6
  - Files: `engineering/workflow-scale-architecture/spec-to-code-map.md`
  - Test: `rtk bash scripts/validate-pack.sh`
  - Acceptance: spec-to-code map 覆盖父级 requirements 和 MUST NOT，明确哪些约束已由父级 contract 定义，哪些实现映射延后到 child change。
  - Estimate: 20 min
