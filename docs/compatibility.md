# Claude Code / Codex Compatibility

SuperSpecFlow 是工作流包，不是应用运行时。它通过集中 routing、skills、agents、commands 和 templates 约束 AI coding agent 的研发流程。

它不应该覆盖宿主项目已有的 `AGENTS.md` 或 `CLAUDE.md`。正确接入方式是通过软连安装能力文件和 `.superspecflow/*.routing.md`，宿主项目指令文件只保留极薄入口。

完整用户安装流程见 `docs/installation.md`。

## Claude Code

推荐项目级软连安装：

```bash
./scripts/install-project-symlinks.sh <project>
```

然后在宿主项目 `CLAUDE.md` 或 `AGENTS.md` 中加入极薄入口：

```markdown
本项目接入 SuperSpecFlow。请读取 `.superspecflow/CLAUDE.routing.md` 或 `.superspecflow/AGENTS.routing.md`，并按其中 Intake Gate 和 `ssf-*` 流程路由自然语言请求。
```

如果宿主项目已有 `CLAUDE.md` 或 `AGENTS.md`，只追加这类入口，并保留宿主项目原有规则。若规则冲突，宿主项目业务事实优先，SuperSpecFlow 负责流程门禁。

推荐全局安装：

```bash
mkdir -p ~/.claude/agents ~/.claude/commands ~/.claude/skills
cp -R agents/* ~/.claude/agents/
cp -R commands/* ~/.claude/commands/
cp -R skills/* ~/.claude/skills/
```

Claude Code 中可显式调用：

```text
/ssf-think 会员续费提醒
/ssf-spec add-membership-renewal-reminder
/ssf-build all
/ssf-review
/ssf-qa add-membership-renewal-reminder
/ssf-ship add-membership-renewal-reminder
/ssf-archive add-membership-renewal-reminder
/ssf-retro add-membership-renewal-reminder
```

Git 相关命令：

```text
/ssf-branch add-membership-renewal-reminder 会员续费提醒
/ssf-commit add-membership-renewal-reminder
/ssf-pr add-membership-renewal-reminder
```

## Codex CLI

Codex 侧重点是读取项目指令和 skills。推荐安装 skills：

```bash
mkdir -p ~/.codex/skills
cp -R skills/* ~/.codex/skills/
```

然后把 `.superspecflow/AGENTS.routing.md` 软连到宿主项目，并在宿主项目已有 `AGENTS.md` 中加入极薄入口。如果 Codex 环境支持项目内技能或命令发现，也可以软连 `skills/`、`commands/` 和 `templates/`，但仍不覆盖宿主项目已有指令文件。

Codex 中可以直接自然语言触发：

```text
我要做一个会员续费提醒功能
```

也可以显式输入同一组 `/ssf-xxx` 命令。若当前 Codex 运行环境不支持 slash command 注册，仍应按 `AGENTS.md` 的路由规则执行对应阶段。

## Installation Helper

仓库提供 `update.sh` 用于同步到 Claude Code 和 Codex 的常见目录：

```bash
./update.sh
```

运行后需要重启会话，让 agent 重新加载项目指令和 skills。

## Compatibility Notes

- 命令统一使用 `/ssf-xxx`，不要使用旧冒号格式。
- 不覆盖宿主项目已有 `AGENTS.md` 或 `CLAUDE.md`，只加入指向 `.superspecflow/*.routing.md` 的极薄入口。
- Claude Code 使用 `commands/` 和 `.claude/commands/` 暴露显式命令。
- Codex CLI 至少应读取宿主项目 `AGENTS.md` 中的极薄入口、`.superspecflow/AGENTS.routing.md` 和 `skills/`；显式命令是否可注册取决于当前 Codex 版本和运行环境。
- 两端都必须保留 OpenSpec / Superpowers / gstack / Karpathy / GitOps 五层门禁。
- 所有 commit message 和 PR 描述必须使用中文。
- 行为变更必须关联 change-id 和 Spec ID。

## Pack Validation

发布或同步前运行：

```bash
./scripts/validate-pack.sh
```

该脚本检查命名、skill frontmatter、旧前缀残留、冒号文件名，以及 README / AGENTS / CLAUDE 与 `commands/` 的命令集合一致性。
