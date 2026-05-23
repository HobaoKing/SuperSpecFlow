# SuperSpecFlow Routing for CLAUDE.md

本文件是 SuperSpecFlow 的集中路由说明。推荐在宿主项目中通过软连引用本文件，不要复制或覆盖宿主项目已有 `CLAUDE.md`。

## SuperSpecFlow Workflow

宿主项目的业务规则、架构事实和本地约束优先。SuperSpecFlow 负责提供默认研发流程：

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

自然语言默认路由：

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
/ssf-init
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
- 普通 `/ssf-*` 显式命令只执行一次性动作，不自动创建 `.superspecflow/`。
- 只有 `/ssf-init` 或明确安装动作可以创建 `.superspecflow/`，使项目 opt-in 自然语言 Intake Gate。
- 全局安装只提供能力；若当前项目没有 `.superspecflow/` 或显式 routing include，不默认接管自然语言。

## Karpathy 编码纪律

任何写代码、修 bug、重构、review、提交前，都要遵守：

### 1. 编码前思考

- 明确目标。
- 显式写出假设。
- 有歧义时列出多个解释。
- 发现更简单方案时主动指出。
- 困惑时暂停并说明困惑点。

### 2. 简单优先

- 只写满足 spec 的最小实现。
- 不为未来需求加抽象。
- 不加未要求的配置、扩展点、框架。
- 发现 200 行可以写成 50 行时，优先简化。

### 3. 外科手术式修改

- 只改必要文件和必要行。
- 不顺手重构邻近代码。
- 不顺手改注释、格式、命名。
- 遵循现有风格。
- 只清理本次改动造成的无用代码。

### 4. 目标驱动验证

- “修 bug”要转成“写复现测试，再修到通过”。
- “加校验”要转成“写无效输入测试，再修到通过”。
- “重构”要转成“重构前后测试均通过”。
