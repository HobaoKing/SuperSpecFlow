# SuperSpecFlow Global Routing for Codex / Generic Agents

本文件是 SuperSpecFlow 的全局薄壳源文件；安装脚本会把它渲染为 `~/.codex/superspecflow/AGENTS.global.md`，再由用户家目录 `~/.codex/AGENTS.md` 引用。

## 1. 项目 opt-in 自检测（必须在响应任何非问答类请求前完成）

在本会话内**只执行一次** Bash：

```bash
test -f .superspecflow/enabled && echo enabled || echo disabled
```

将结果作为本会话 SSF 状态使用，后续不重复探测。

## 2. 显式命令始终可用

无论 SSF 状态如何，下列 `/ssf-*` 显式命令都可被用户调用：

```text
/ssf-think /ssf-spec /ssf-build /ssf-review /ssf-qa /ssf-ship
/ssf-archive /ssf-retro /ssf-decision /ssf-map /ssf-karpathy
/ssf-init /ssf-git /ssf-branch /ssf-commit /ssf-pr
```

## 3. 项目级覆盖判定

当 SSF 状态 = `enabled` 时，按下列顺序决定 routing 主体来源：

- 若当前项目存在 `.superspecflow/AGENTS.routing.md`：用工具读取该文件，作为本会话 routing 主体，不再进入第 4 节。
- 否则进入第 4 节。

## 4. 条件读取默认 routing 主体（不使用 @ 自动 include）

**重要**：本文件**故意不**使用 `@<repo>/routing/AGENTS.routing.md` 自动展开写法，理由与 CLAUDE.global.md 相同。

替代约束：

- **当且仅当** SSF 状态 = `enabled` 且未命中第 3 节项目级覆盖时，主动读取 `<repo>/routing/AGENTS.routing.md`，并采用其内容作为本会话 routing 主体。
- 当 SSF 状态 = `disabled` 时，不得读取该文件，也不得应用其中的约束。

## 5. SSF 状态 = disabled 时的行为

不接管自然语言；仅响应 `/ssf-*` 显式命令；按 agent 默认行为处理其他请求；不读取 `<repo>/routing/AGENTS.routing.md`。

## 6. 安装说明

由 `scripts/install-global.sh` 协助引入 `~/.codex/AGENTS.md`。
