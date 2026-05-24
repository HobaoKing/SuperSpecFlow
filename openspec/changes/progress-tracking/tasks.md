# Tasks: progress-tracking

- [ ] T1: 定义 progress 目录和文件协议
  - Spec: SSF-PROGRESS-001, SSF-PROGRESS-002, SSF-PROGRESS-003, SSF-PROGRESS-004, SSF-PROGRESS-005
  - Files: `openspec/changes/progress-tracking/design.md`, `openspec/changes/progress-tracking/specs/progress.md`
  - Test: 人工检查四个文件职责、最小字段和示例格式完整。
  - Acceptance: 规格定义 `.superspecflow/progress/<change-id>/state.json`、`timeline.md`、`verification.md`、`handoff.md` 的职责与最小内容。
  - Estimate: 30 min

- [ ] T2: 定义恢复流程和 agent 读写规则
  - Spec: SSF-PROGRESS-006, SSF-PROGRESS-007, SSF-PROGRESS-008, SSF-PROGRESS-N1, SSF-PROGRESS-N2
  - Files: `openspec/changes/progress-tracking/design.md`, `openspec/changes/progress-tracking/specs/progress.md`
  - Test: 人工检查中断、上下文压缩和换 agent 场景。
  - Acceptance: 规格要求恢复时先读 `state.json` 和 `handoff.md`，再读 OpenSpec，并规定 progress 与 OpenSpec 冲突时的处理方式。
  - Estimate: 25 min

- [ ] T3: 定义 fresh verification 记录规则
  - Spec: SSF-PROGRESS-009, SSF-PROGRESS-010, SSF-PROGRESS-N3, SSF-PROGRESS-N4
  - Files: `openspec/changes/progress-tracking/design.md`, `openspec/changes/progress-tracking/specs/progress.md`
  - Test: 人工检查完成声明前验证记录场景和过期验证负向场景。
  - Acceptance: 规格要求每次声称完成前必须有 latest relevant change 之后写入或引用的验证记录。
  - Estimate: 20 min

- [ ] T4: 明确仓库边界和非目标
  - Spec: SSF-PROGRESS-011, SSF-PROGRESS-N5, SSF-PROGRESS-N6, SSF-PROGRESS-N7
  - Files: `openspec/changes/progress-tracking/proposal.md`, `openspec/changes/progress-tracking/design.md`, `openspec/changes/progress-tracking/specs/progress.md`
  - Test: 人工检查 Non-goals、Repository Boundary 和 MUST NOT。
  - Acceptance: 规格明确 SuperSpecFlow 本仓库不提交运行时 progress 实例，宿主项目是否提交由宿主策略决定，并排除自动调度、UI、跨 agent 签核和代码实现。
  - Estimate: 15 min

- [ ] T5: 验证 OpenSpec 草案格式和范围
  - Spec: SSF-PROGRESS-001, SSF-PROGRESS-011
  - Files: `openspec/changes/progress-tracking/proposal.md`, `openspec/changes/progress-tracking/design.md`, `openspec/changes/progress-tracking/tasks.md`, `openspec/changes/progress-tracking/specs/progress.md`
  - Test: `rtk git diff --check -- openspec/changes/progress-tracking`
  - Acceptance: 只创建 `openspec/changes/progress-tracking/` 下的 OpenSpec 文件，未触碰代码、README、routing、skills、commands、scripts、tests 或其他 change 目录。
  - Estimate: 10 min
