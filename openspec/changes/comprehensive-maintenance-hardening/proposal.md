# Proposal: comprehensive-maintenance-hardening

## Summary

将本轮维护审查结论收敛为一个 parent hardening program，并拆成四个 child changes：测试基础设施、routing/docs 漂移治理、validator/developer tooling、模板与 skill 可用性。

## Problem

当前仓库契约测试和验证脚本总体健康，但存在三类维护风险：

- 测试基础设施在自定义 `TMPDIR` 和并发/中断场景下会假红或污染真实仓库。
- routing、README、installation 文档和 workflow-scale evidence 存在重复或状态漂移。
- validator 诊断、开发脚手架、模板和 skill 文本对维护者与 agent 的可操作性不足。

## Goals

- 用 parent / child change 边界承接全部修复，避免单个未拆分 change 跨过多子系统。
- 每个实际改动批次在编辑前保留 3 个子 agent review 的一致性记录。
- 先修测试可信度，再降低文档和 routing 漂移，最后提升开发者与 agent 可用性。
- 保持 Bash 3.2+ 兼容，保持 existing runtime behavior，除明确新增 developer tooling 外不改变用户工作流语义。

## Non-goals

- 不把 routing public 文件改成 raw symlink。
- 不引入后台调度器、自动 merge 服务或跨 agent 通信协议。
- 不实现 security 专用 agent 或多技术栈自动探测。
- 不并行化 `validate-pack.sh`。

## Child Changes

1. `test-infra-portability-hardening`
2. `routing-docs-drift-reduction`
3. `validator-developer-tooling`
4. `template-skill-usability-polish`

## User Impact

维护者在更多本地环境中能稳定运行测试，CI 失败信息更可定位，README 更聚焦，agent 使用模板和 skills 时更少遗漏关键信息。

## Success Metrics

- 默认环境和非默认 `TMPDIR` 环境下 `scripts/test.sh` 均通过。
- root-mutating 测试不再写入真实 `$REPO_ROOT` runtime 目录。
- routing 两个 public 文件由 canonical source 或等价同步机制防漂移，不依赖 raw symlink。
- README 安装段显著收敛，详细安装说明仍在 `docs/installation.md`。
- `validate-pack.sh` 关键长链诊断拆成独立失败项。
- `scripts/new-change.sh` 和 `scripts/test.sh` 筛选能力有契约测试。

## Risks

- 范围较大，必须按 child change 独立验证。
- validator refactor 容易削弱现有门禁，必须保留负向测试。
- 文档精简可能误删安全安装提示，必须保留 canonical docs。
- test fixture repo copies 必须仍能覆盖 `git check-ignore`、`git ls-files` 和 `validate-pack.sh`。

## Rollout Strategy

按 child change 顺序落地：测试基础设施 → routing/docs → validator/developer tooling → template/skill polish。每批先做 3-agent review，再写失败测试，再实现，再运行局部和全量验证。

## Open Questions

- 无。Reviewer A/B/C 已收敛为 parent + child split、禁止 raw symlink、每批三方 review 记录。
