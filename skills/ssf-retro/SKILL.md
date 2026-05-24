---
name: ssf-retro
description: 复盘。用户输入 /ssf-retro 时触发。复盘本轮 SuperSpecFlow，检查产品、规格、开发、测试、发布各阶段的流程质量，输出可执行改进。
---

# ssf-retro — 复盘

## 目标

复盘的重点不是“总结做了什么”，而是改进下一轮 AI 协作质量。

## 触发

`/ssf-retro [change-id]`

## 产物路径

宿主项目 retro 运行时产物默认写入 `.superspecflow/retro/<change-id>/retro.md`。读取历史 retro 产物时先读 `.superspecflow/retro/<change-id>/`，缺失时 fallback 到兼容期旧路径；新写入不得推荐根目录 `retro/<change-id>/`。

## Step 1 — Cycle Review

```markdown
# Retro: [change-id]

## What Went Well

## What Got Stuck

## Product Quality
- Pain clear:
- Scope controlled:
- Non-goals clear:

## Spec Quality
- Requirements testable:
- MUST NOT complete:
- Tasks sized well:

## Engineering Quality
- TDD followed:
- Spec-to-code map accurate:
- Review blockers:

## QA Quality
- Acceptance matrix complete:
- Negative tests complete:
- Regression coverage:

## Release Quality
- Rollback clear:
- Monitoring clear:
- Residual risk:
```

## Step 2 — 3-5 条改进建议

每条必须具体到一个阶段：

```markdown
1. In ssf-think: ...
2. In ssf-spec: ...
3. In ssf-build: ...
4. In ssf-qa: ...
5. In ssf-ship: ...
```

## Step 3 — Process Patch

如果某个阶段反复出问题，给出可复制到对应 `SKILL.md` 的补丁文本。

## Step 4 — Git / Karpathy Process Review

补充检查：

```markdown
## Karpathy Quality
- Assumptions surfaced:
- Simplicity maintained:
- Surgical diff:
- Verifiable goals:

## Git Quality
- Branch naming:
- Commit language Chinese:
- Commit-to-Spec traceability:
- PR quality:
- Rollback clarity:
```

如果出现无关改动、英文 commit、过度设计、缺失验证，将其转成下一轮流程改进项。
