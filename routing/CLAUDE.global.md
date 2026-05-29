# SuperSpecFlow Global Routing for Claude Code

本文件是 SuperSpecFlow 的全局薄壳源文件；安装脚本会把它渲染为 `~/.claude/superspecflow/CLAUDE.global.md`，再由用户家目录 `~/.claude/CLAUDE.md` 引用。它只做四件事：项目 opt-in 自检测、显式命令始终可用声明、项目级覆盖判定、条件读取主体 routing。

## 1. 项目 opt-in 自检测（必须在响应任何非问答类请求前完成）

判定 SSF 状态优先级：

1. 若对话上下文已包含 `<ssf-status>enabled</ssf-status>` 或 `<ssf-status>disabled</ssf-status>` 标签（由 Claude Code SessionStart hook 注入），直接采用其值，**不再**执行下面的 Bash 探测。
2. 否则在本会话内**只执行一次** Bash：

   ```bash
   test -f .superspecflow/enabled && echo enabled || echo disabled
   ```

   将结果作为本会话 SSF 状态使用，后续不重复探测。

## 2. 显式命令始终可用

无论 SSF 状态如何，下列 `/ssf-*` 显式命令都可被用户调用，按对应 skill 执行一次性动作：

```text
/ssf-think /ssf-spec /ssf-build /ssf-review /ssf-qa /ssf-ship
/ssf-archive /ssf-retro /ssf-decision /ssf-map /ssf-karpathy
/ssf-init /ssf-git /ssf-branch /ssf-commit /ssf-pr
```

## 3. 项目级覆盖判定

当 SSF 状态 = `enabled` 时，按下列顺序决定 routing 主体来源：

- 若当前项目存在 `.superspecflow/CLAUDE.routing.md`：**用 Read 工具读取该文件**，将其作为本会话 routing 主体，**不再**读取下一步的全局默认文件。
- 否则进入第 4 节。

## 4. 条件读取默认 routing 主体（不使用 @ 自动 include）

**重要**：本文件**故意不**使用 `@<repo>/routing/CLAUDE.routing.md` 自动展开写法。因为 `@` 在所有会话都会被无条件解析，会破坏 SSF 状态 = `disabled` 时"不接管自然语言"的承诺。

替代约束（必须遵守）：

- **当且仅当** SSF 状态 = `enabled` 且未命中第 3 节项目级覆盖时，你（LLM）须**主动用 Read 工具读取** `<repo>/routing/CLAUDE.routing.md`，并采用其内容作为本会话 routing 主体。
- 当 SSF 状态 = `disabled` 时，**不得**读取该文件，也不得应用其中的约束。
- 路径中的 `<repo>` 占位符会被 `install-global.sh` 替换为用户仓库绝对路径。

## 5. SSF 状态 = disabled 时的行为

- 不接管自然语言请求，按 Claude Code 默认行为响应。
- 仅当用户显式输入 `/ssf-*` 命令时执行对应 skill。
- 不强制 Intake Gate、不强制 change-id、不要求中文 commit。
- **不读取** `<repo>/routing/CLAUDE.routing.md`。

## 6. 安装说明

本文件由 `scripts/install-global.sh` 协助引入 `~/.claude/CLAUDE.md`。已有用户全局文件时脚本只打印应追加行，不擅自改写。
