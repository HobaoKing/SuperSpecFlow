# Tasks: artifact-path-migration

- [x] T1: 接入运行产物路径契约到 routing 和角色说明
  - Spec: SSF-ARTIFACT-001, SSF-ARTIFACT-003, SSF-ARTIFACT-004, SSF-ARTIFACT-005, SSF-ARTIFACT-007, SSF-ARTIFACT-N2, SSF-ARTIFACT-N3, SSF-ARTIFACT-N5, SSF-ARTIFACT-N6
  - Files: `routing/AGENTS.routing.md`, `routing/CLAUDE.routing.md`, `skills/`, `agents/`, `commands/`
  - Test: `rtk bats tests/artifacts/test_artifact_path_contract.bats`, `rtk bash scripts/validate-pack.sh`
  - Acceptance: routing 使用 `## Artifact Paths` 声明 9 个 `.superspecflow/` 运行时 namespace、new path first + fallback 读取策略、`openspec/` 可提交边界和本仓库 `engineering/<change-id>/` 工程交付边界；skills/agents/commands 不再推荐根目录旧路径作为新写入位置。
  - Estimate: 35 min

- [x] T2: 更新 runtime 模板路径提示
  - Spec: SSF-ARTIFACT-001, SSF-ARTIFACT-003, SSF-ARTIFACT-005, SSF-ARTIFACT-N3
  - Files: `templates/implementation-plan.md`, `templates/spec-readiness-review.md`, `templates/dev-handoff.md`, `templates/spec-to-code-map.md`, `templates/acceptance-matrix.md`, `templates/negative-test-matrix.md`, `templates/risk-matrix.md`, `templates/regression-checklist.md`, `templates/exploratory-test-notes.md`, `templates/qa-signoff.md`, `templates/release-checklist.md`, `templates/rollback-plan.md`, `templates/monitoring-plan.md`, `templates/pr-description.md`, `templates/ship-decision.md`, `templates/archive-summary.md`, `templates/documentation-coverage.md`, `templates/decision-record.md`, `templates/retro.md`, `templates/review-report.md`, `templates/sync-check.md`, `templates/karpathy-preflight.md`, `templates/karpathy-diff-audit.md`
  - Test: `rtk bats tests/artifacts/test_artifact_path_contract.bats`, `rtk bash scripts/validate-pack.sh`
  - Acceptance: 运行时模板包含 `.superspecflow/<stage>/...` Path 提示；spec-to-code map、QA、review 和 Karpathy 代表模板由自动化测试覆盖。
  - Estimate: 25 min

- [x] T3: 更新 `/ssf-init` 标准运行产物目录
  - Spec: SSF-ARTIFACT-001, SSF-ARTIFACT-003, SSF-ARTIFACT-005, SSF-ARTIFACT-N3, SSF-ARTIFACT-N5
  - Files: `scripts/_ssf_init_apply.sh`, `commands/ssf-init.md`, `docs/installation.md`, `tests/init/test_ssf_init_zero_touch.bats`
  - Test: `rtk bats tests/init/test_ssf_init_zero_touch.bats`, `rtk bash scripts/validate-pack.sh`
  - Acceptance: 新 opt-in 项目创建 `.superspecflow/{engineering,qa,release,archive,retro,decisions,maps,reviews,karpathy}/`；继续只为空目录创建 `.superspecflow/progress/` 占位，不定义 progress 文件协议，不创建旧 `ship/` 推荐目录。
  - Estimate: 20 min

- [x] T4: 增加 artifact path validation
  - Spec: SSF-ARTIFACT-002, SSF-ARTIFACT-006, SSF-ARTIFACT-007, SSF-ARTIFACT-N1, SSF-ARTIFACT-N3, SSF-ARTIFACT-N4, SSF-ARTIFACT-N6
  - Files: `scripts/validate-pack.sh`, `tests/artifacts/test_artifact_path_contract.bats`, `.gitignore`
  - Test: `rtk bats tests/artifacts/test_artifact_path_contract.bats`, `rtk bats tests/smoke/test_artifact_policy.bats`, `rtk bash scripts/validate-pack.sh`
  - Acceptance: validation 通过结构化 `## Artifact Paths` 章节检查和路径共现检查覆盖 routing/skills/commands/templates；`.superspecflow/` 已忽略；`openspec/` 未被忽略或阻断；本仓库已提交 `engineering/init-project-routing/`、`engineering/progress-tracking/`、`engineering/cross-agent-verification/` 不被判定为非法路径；根目录 `qa/<change-id>/` 等新运行时写入会被阻断。
  - Estimate: 35 min

- [x] T5: 更新 README 和安装文档路径总览
  - Spec: SSF-ARTIFACT-002, SSF-ARTIFACT-003, SSF-ARTIFACT-004, SSF-ARTIFACT-005, SSF-ARTIFACT-007, SSF-ARTIFACT-N1, SSF-ARTIFACT-N4, SSF-ARTIFACT-N6
  - Files: `README.md`, `docs/installation.md`, `docs/compatibility.md`
  - Test: `rtk bash scripts/validate-pack.sh`, `rtk bats tests/artifacts/test_artifact_path_contract.bats`
  - Acceptance: 文档明确 9 个宿主项目运行时 namespace、new path first + fallback 策略、`openspec/` 可提交契约，以及 SuperSpecFlow 本仓库 `engineering/<change-id>/` 工程交付目录不迁移。
  - Estimate: 20 min

- [x] T6: 记录实现映射和 MUST NOT 覆盖
  - Spec: SSF-ARTIFACT-001, SSF-ARTIFACT-002, SSF-ARTIFACT-003, SSF-ARTIFACT-004, SSF-ARTIFACT-005, SSF-ARTIFACT-006, SSF-ARTIFACT-007, SSF-ARTIFACT-N1, SSF-ARTIFACT-N2, SSF-ARTIFACT-N3, SSF-ARTIFACT-N4, SSF-ARTIFACT-N5, SSF-ARTIFACT-N6
  - Files: `engineering/artifact-path-migration/spec-to-code-map.md`, `openspec/changes/artifact-path-migration/tasks.md`
  - Test: `rtk bash scripts/validate-pack.sh`, `rtk bats tests/artifacts/test_artifact_path_contract.bats`
  - Acceptance: spec-to-code map 覆盖 SSF-ARTIFACT-001 ~ 007，并显式覆盖 SSF-ARTIFACT-007 的三个 Scenario；`## MUST NOT 覆盖` 表覆盖 N1 ~ N6；tasks.md 已重写为 implementation 阶段完成态任务且所有 Test 字段使用 `rtk bats` 或 `rtk bash` 命令。
  - Estimate: 20 min
