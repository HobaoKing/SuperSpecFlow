# SuperSpecFlow Routing Snippet for AGENTS.md

本片段用于合并到宿主项目已有 `AGENTS.md`。不要用 SuperSpecFlow 的根 `AGENTS.md` 覆盖宿主项目文件。

## SuperSpecFlow Workflow

SuperSpecFlow 是通用 AI 软件研发工作流包。宿主项目的业务规则、架构事实和本地约束优先；SuperSpecFlow 负责把 AI coding agent 的协作流程路由为：

```text
Think → Spec → Build → Review → QA → Ship → Git/PR → Archive → Retro
```

## Strict Intake Gate

自然语言请求必须先分类，不是所有任务都适合走完整工作流。

| 类别 | 处理方式 |
|---|---|
| 纯问答 / 解释 | 直接回答，不启动完整 SuperSpecFlow |
| 轻量任务 | 说明目标、影响范围、验证方式；不强制完整 Think → Retro |
| 非平凡行为变更 | 进入 `ssf-think` 或 `ssf-spec`，形成 change-id / Spec ID |
| 已有规格的实现 | 进入 `ssf-build` |
| Review / QA / Ship / Git | 进入对应 `ssf-*` 阶段 |
| 高风险变更 | 强制完整 Spec、QA、Ship、Git/PR 门禁 |

当用户用自然语言提出非平凡功能、产品方向、MVP、用户流程或需求边界时，默认进入 `ssf-think`，不要直接写代码。

当用户要求写规格、acceptance criteria、OpenSpec 或拆任务时，默认进入 `ssf-spec`。

当用户要求实现、修 bug、重构、加 API 或补测试时，如果没有可用 change-id / Spec ID，先进入 `ssf-spec` 或暂停确认；如果已有规格，进入 `ssf-build`。

当用户要求 review、测试、验收、发布、提交、PR、回滚或复盘时，分别进入 `ssf-review`、`ssf-qa`、`ssf-ship`、`ssf-git`、`ssf-archive`、`ssf-retro`。

## Explicit Commands

```text
/ssf-think <idea>
/ssf-spec <change-id>
/ssf-build [all|N]
/ssf-review
/ssf-qa <change-id>
/ssf-ship <change-id>
/ssf-archive <change-id>
/ssf-retro <change-id>
/ssf-decision <topic>
/ssf-map <change-id>
/ssf-karpathy <target>
/ssf-git
/ssf-branch <change-id> <topic>
/ssf-commit <change-id>
/ssf-pr <change-id>
```

## Gates

- 行为变更必须关联 change-id 和 Spec ID。
- Intake Gate 判定为轻量任务时，可以使用轻量流程，但必须说明验证方式。
- 每个 requirement 至少映射一个测试。
- 每个 MUST NOT 至少映射一个负向测试。
- QA 不只覆盖 happy path。
- 发布必须包含 rollback、monitoring、risk matrix 和 negative tests。
- commit 和 PR 必须使用中文。
- 不使用旧冒号格式命令，也不引入 `hw` 旧前缀。
