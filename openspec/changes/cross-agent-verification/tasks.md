# Tasks: cross-agent-verification

- [ ] T1: 增加 cross-agent verification handoff 文件契约
  - Spec: SSF-XAV-001, SSF-XAV-002, SSF-XAV-006
  - Files: review / routing / command guidance files to be selected during implementation
  - Test: 固定路径和文件名的文档或脚本检查。
  - Acceptance: 流程说明统一使用 `.superspecflow/verification/<change-id>/request.md`、`evidence.md`、`reviewer-notes.md` 和 `signoff.md`。
  - Estimate: 25 min

- [ ] T2: 约束主 agent 的 request 和 evidence 写入责任
  - Spec: SSF-XAV-002, SSF-XAV-003, SSF-XAV-N1
  - Files: review / build handoff guidance files to be selected during implementation
  - Test: 样例 handoff 检查 evidence 是否包含命令、路径、摘要或引用。
  - Acceptance: 主 agent 写入 `request.md` 和 `evidence.md`，且 evidence 能被 review agent 独立复查。
  - Estimate: 30 min

- [ ] T3: 约束 review agent 的独立核验输入
  - Spec: SSF-XAV-004, SSF-XAV-008, SSF-XAV-N2, SSF-XAV-N3
  - Files: review guidance files to be selected during implementation
  - Test: 构造含聊天声明但缺少 evidence 的场景，确认 review 不引用未落盘事实。
  - Acceptance: review agent 只基于 OpenSpec、diff、progress 和 evidence 写 `reviewer-notes.md` / `signoff.md`。
  - Estimate: 30 min

- [ ] T4: 实现 signoff 结果枚举与必填字段检查
  - Spec: SSF-XAV-005, SSF-XAV-006, SSF-XAV-007, SSF-XAV-N4
  - Files: validation / checklist files to be selected during implementation
  - Test: 对 `approve`、`changes-requested`、`blocked` 以外的结果进行负向检查。
  - Acceptance: `signoff.md` 只能使用允许结果，并列出已检查 Spec ID、证据引用和残余风险。
  - Estimate: 35 min

- [ ] T5: 处理缺少 evidence 和 progress 不可用的失败模式
  - Spec: SSF-XAV-003, SSF-XAV-009, SSF-XAV-N1, SSF-XAV-N5
  - Files: review guidance / validation files to be selected during implementation
  - Test: 缺少 `evidence.md`、空 evidence、缺少 progress 目录的场景测试。
  - Acceptance: 缺少可复查 evidence 时不生成 `signoff.md`；progress 不可用时记录残余风险但不定义 progress 协议。
  - Estimate: 30 min

- [ ] T6: 增加示例或模板并验证第一版不引入重型协作协议
  - Spec: SSF-XAV-001, SSF-XAV-010, SSF-XAV-N6, SSF-XAV-N7
  - Files: template / documentation files to be selected during implementation
  - Test: 搜索确认未引入双签、共识协议、多方投票或自动 agent 通信要求。
  - Acceptance: 第一版只提供轻量 handoff，后续门禁仍由现有 Review / QA / Ship / Git 流程承担。
  - Estimate: 20 min
