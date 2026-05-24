# Tasks: artifact-path-migration

- [ ] T1: 更新阶段路径契约和命名说明
  - Spec: SSF-ARTIFACT-001, SSF-ARTIFACT-002, SSF-ARTIFACT-N1
  - Files: `skills/`, `agents/`, `commands/`, `templates/`
  - Test: 产物路径残留搜索。
  - Acceptance: 所有新写入说明均指向 `.superspecflow/` 目标路径，`openspec/` 保持为可提交 change contract。
  - Estimate: 45 min

- [ ] T2: 实现新路径优先、旧路径 fallback 的读取策略
  - Spec: SSF-ARTIFACT-003, SSF-ARTIFACT-004, SSF-ARTIFACT-N2
  - Files: `skills/`, `agents/`, `commands/`
  - Test: 新旧路径解析场景测试。
  - Acceptance: 新旧路径同时存在时读取新路径；只有旧路径存在时仍可读取历史产物。
  - Estimate: 60 min

- [ ] T3: 收敛新产物写入策略
  - Spec: SSF-ARTIFACT-005, SSF-ARTIFACT-N3
  - Files: `skills/`, `agents/`, `commands/`, `templates/`
  - Test: 阶段输出路径烟测。
  - Acceptance: 新生成的 engineering、QA、release、archive、retro、decision、map、review 和 karpathy 产物默认写入 `.superspecflow/`。
  - Estimate: 60 min

- [ ] T4: 更新 validation 与 Git 门禁
  - Spec: SSF-ARTIFACT-002, SSF-ARTIFACT-006, SSF-ARTIFACT-N1, SSF-ARTIFACT-N4
  - Files: `scripts/`, `tests/`, `.gitignore`, `templates/`
  - Test: pack validation、artifact policy tests、`git diff --check`。
  - Acceptance: `.superspecflow/` 被识别为本地运行产物；`openspec/` 不被误判为运行时产物；旧路径新写入引用被 validation 暴露。
  - Estimate: 75 min

- [ ] T5: 更新文档、发布说明和兼容期提示
  - Spec: SSF-ARTIFACT-003, SSF-ARTIFACT-004, SSF-ARTIFACT-005
  - Files: `README.md`, `docs/`, `templates/`
  - Test: 文档路径一致性搜索。
  - Acceptance: 用户能理解新路径、旧路径兼容读取、`openspec/` 不迁移和兼容期风险。
  - Estimate: 45 min

- [ ] T6: 补充迁移验收矩阵
  - Spec: SSF-ARTIFACT-001, SSF-ARTIFACT-002, SSF-ARTIFACT-003, SSF-ARTIFACT-004, SSF-ARTIFACT-005, SSF-ARTIFACT-006
  - Files: `tests/`, `templates/acceptance-matrix.md`, `templates/negative-test-matrix.md`, `templates/regression-checklist.md`
  - Test: acceptance matrix、negative test matrix、旧路径 fallback regression。
  - Acceptance: 每个 requirement 至少有一个验收项，每个 MUST NOT 至少有一个负向测试或人工 gate。
  - Estimate: 45 min
