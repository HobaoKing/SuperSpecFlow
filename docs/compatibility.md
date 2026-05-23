# Claude Code / Codex Compatibility

SuperSpecFlow 是工作流包，不是应用运行时。它通过项目指令、skills、agents、commands 和 templates 约束 AI coding agent 的研发流程。

## Claude Code

推荐项目级安装：

```bash
cp AGENTS.md CLAUDE.md <project>/
mkdir -p <project>/.claude
cp -R agents commands skills <project>/.claude/
```

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

Codex 侧重点是读取项目指令和 skills。推荐：

```bash
cp AGENTS.md <project>/
mkdir -p ~/.codex/skills
cp -R skills/* ~/.codex/skills/
```

如果 Codex 环境支持项目内技能或命令发现，也可以把 `skills/`、`commands/` 和 `templates/` 放在项目根目录，由 `AGENTS.md` 负责路由说明。

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
- Claude Code 使用 `commands/` 和 `.claude/commands/` 暴露显式命令。
- Codex CLI 至少应读取 `AGENTS.md` 和 `skills/`；显式命令是否可注册取决于当前 Codex 版本和运行环境。
- 两端都必须保留 OpenSpec / Superpowers / gstack / Karpathy / GitOps 五层门禁。
- 所有 commit message 和 PR 描述必须使用中文。
- 行为变更必须关联 change-id 和 Spec ID。

## Pack Validation

发布或同步前运行：

```bash
./scripts/validate-pack.sh
```

该脚本检查命名、skill frontmatter、旧前缀残留、冒号文件名，以及 README / AGENTS / CLAUDE 与 `commands/` 的命令集合一致性。
