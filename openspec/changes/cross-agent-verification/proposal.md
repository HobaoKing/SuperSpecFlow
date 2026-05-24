# Proposal: cross-agent-verification

## Summary

为 SuperSpecFlow 增加轻量 cross-agent review handoff 契约，让主 agent 能把某个 OpenSpec change 的核验请求、事实证据和残余风险交给 Claude、Codex 或另一个独立 agent 复核，并产出受限状态的 signoff。

## Problem

当前流程依赖单个 agent 自述完成情况和验证结果。即使仓库中已有 OpenSpec、diff 和进度记录，另一个 agent 也缺少稳定入口来知道应该核验什么、能信任哪些事实、signoff 应该写在哪里，以及哪些结果是允许的。

需要先建立轻量、文件化的交接协议，避免第一版直接引入双签、共识协议或多方投票等重型机制。

## Goals

- 定义 `.superspecflow/verification/<change-id>/` 下的核验交接文件。
- 规定主 agent 负责写 `request.md` 和 `evidence.md`。
- 规定 review agent 只能基于 OpenSpec、diff、progress 和 evidence 做独立核验。
- 限定 `signoff.md` 第一版结果为 `approve`、`changes-requested` 或 `blocked`。
- 要求 signoff 列出检查过的 Spec ID、验证命令或证据引用、残余风险。
- 明确没有 evidence 时不得产出 signoff。
- 说明本 change 读取 `progress-tracking` 的 `.superspecflow/progress/<change-id>/` 事实底座，但不实现 progress 文件协议。
- 在 SuperSpecFlow 包源码中提供 `templates/verification-*` 作为 cross-agent verification handoff 文件模板。
- 将 cross-agent verification handoff 规则接入 `ssf-review`、routing 和 pack validation。
- 明确 SuperSpecFlow 本仓库不提交 `.superspecflow/verification/` 运行时实例，宿主项目是否提交由宿主项目策略决定。

## Non-goals

- 不实现两个 agent 之间的自动通信。
- 不设计抽象共识协议、双签门禁或多方投票。
- 不定义 `progress-tracking` 的文件格式、生命周期或写入规则。
- 不替代 OpenSpec tasks、QA signoff、release gate 或 Git gate。
- 不要求 review agent 执行生产发布、回滚或真实世界动作。

## User Impact

主 agent 可以在完成某个 change 的阶段性工作后，把可核验事实写入 `.superspecflow/verification/<change-id>/`。review agent 接手时无需读取聊天上下文，只需查看 OpenSpec、diff、progress 和 evidence，即可给出结构化结论。主控流程可以据此决定继续修改、阻塞整合或进入后续 QA / Ship / Git 门禁。

## Affected Areas

- `.superspecflow/verification/<change-id>/`
- `.superspecflow/progress/<change-id>/`，只读依赖
- `templates/`
- `skills/ssf-review/SKILL.md`
- `routing/AGENTS.routing.md`
- `routing/CLAUDE.routing.md`
- `scripts/validate-pack.sh`
- `tests/verification/`
- `engineering/cross-agent-verification/`
- `README.md`
- OpenSpec change documents
- Review / QA / Ship handoff guidance

## Success Metrics

- 每个 cross-agent review handoff 都有稳定路径和固定文件名。
- `signoff.md` 不会在缺少 `evidence.md` 或 evidence 内容为空时生成。
- review agent 的结论只引用 OpenSpec、diff、progress 和 evidence 中可复查的事实。
- signoff 结果只使用 `approve`、`changes-requested` 或 `blocked`。
- signoff 明确列出已检查 Spec ID、验证命令或证据引用、残余风险。
- 包源码提供 verification handoff 模板，且 pack validation 能检查模板与 review / routing 规则是否存在。
- SuperSpecFlow 本仓库的 Git 跟踪文件不包含 `.superspecflow/verification/` 运行时实例。

## Risks

- progress-tracking 尚未落地时，review agent 只能依赖接口假设和现有 OpenSpec / diff / evidence。
- evidence 质量不足会导致 review agent 频繁返回 `blocked`。
- 主 agent 可能把聊天结论写进 request，但 review agent 仍不能把未落盘事实作为核验依据。
- 轻量 handoff 容易被误解为完整 QA 或发布许可，需要在规格中明确它只是独立复核入口。

## Rollout Strategy

第一版发布 OpenSpec 协议、verification handoff 模板，并把 evidence-based cross-agent verification 规则接入 `ssf-review`、routing 和 pack validation。后续 change 再扩展命令自动化或更强的 QA / Ship 门禁。第一版不引入跨 agent 自动编排。

## Open Questions

- diff 的标准来源应由后续实现选择 `git diff`、PR diff，还是二者都允许。
- progress-tracking 最小可读字段需要由 `progress-tracking` change 最终规格确认。
