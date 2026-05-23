# SuperSpecFlow Routing Snippet for CLAUDE.md

本片段用于合并到宿主项目已有 `CLAUDE.md`。不要用 SuperSpecFlow 的根 `CLAUDE.md` 覆盖宿主项目文件。

## SuperSpecFlow Workflow

宿主项目的业务规则、架构事实和本地约束优先。SuperSpecFlow 负责提供默认研发流程：

```text
Think → Spec → Build → Review → QA → Ship → Git/PR → Archive → Retro
```

自然语言默认路由：

先执行 Strict Intake Gate，不是所有自然语言请求都适合走完整工作流。

| 类别 | 处理方式 |
|---|---|
| 纯问答 / 解释 | 直接回答，不启动完整 SuperSpecFlow |
| 轻量任务 | 说明目标、影响范围、验证方式；不强制完整 Think → Retro |
| 非平凡行为变更 | 进入 `ssf-think` 或 `ssf-spec`，形成 change-id / Spec ID |
| 已有规格的实现 | 进入 `ssf-build` |
| Review / QA / Ship / Git | 进入对应 `ssf-*` 阶段 |
| 高风险变更 | 强制完整 Spec、QA、Ship、Git/PR 门禁 |

- 非平凡新想法、新功能、MVP、用户路径、需求边界：进入 `ssf-think`。
- OpenSpec、规格、acceptance criteria、任务拆分：进入 `ssf-spec`。
- 实现、修 bug、重构、加 API、补测试：进入 `ssf-build`，但必须先有 change-id 和 Spec ID。
- review、测试、验收、发布、提交、PR、归档、复盘：分别进入对应 `ssf-*` skill。

显式命令：

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

硬规则：

- 不把一句话需求直接当成写代码许可。
- 行为变更必须关联 change-id 和 Spec ID。
- 高风险变更不能跳过 Spec、QA、Ship、Git/PR。
- QA 必须包含负向测试和回归路径。
- 发布必须包含 rollback 和 monitoring。
- commit 标题和正文必须使用中文。
