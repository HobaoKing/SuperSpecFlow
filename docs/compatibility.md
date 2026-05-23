# Claude Code / Codex Compatibility

SuperSpecFlow 是工作流包，不是应用运行时。它通过项目指令片段、skills、agents、commands 和 templates 约束 AI coding agent 的研发流程。

它不应该覆盖宿主项目已有的 `AGENTS.md` 或 `CLAUDE.md`。正确接入方式是安装能力文件，并把 SuperSpecFlow 路由片段合并到宿主项目自己的指令文件中。

完整用户安装流程见 `docs/installation.md`。

## Claude Code

推荐项目级安装能力文件：

```bash
mkdir -p <project>/.claude
cp -R agents commands skills <project>/.claude/
```

然后手动合并路由片段：

```text
templates/integration/CLAUDE.snippet.md
templates/integration/AGENTS.snippet.md
```

如果宿主项目已有 `CLAUDE.md` 或 `AGENTS.md`，把片段追加到合适章节，并保留宿主项目原有规则。若规则冲突，宿主项目业务事实优先，SuperSpecFlow 负责流程门禁。

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

然后把 `templates/integration/AGENTS.snippet.md` 合并到宿主项目已有 `AGENTS.md`。如果 Codex 环境支持项目内技能或命令发现，也可以把 `skills/`、`commands/` 和 `templates/` 放在项目根目录，但仍不覆盖宿主项目已有指令文件。

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
- 不覆盖宿主项目已有 `AGENTS.md` 或 `CLAUDE.md`，只合并路由片段。
- Claude Code 使用 `commands/` 和 `.claude/commands/` 暴露显式命令。
- Codex CLI 至少应读取宿主项目 `AGENTS.md` 中合并后的路由片段和 `skills/`；显式命令是否可注册取决于当前 Codex 版本和运行环境。
- 两端都必须保留 OpenSpec / Superpowers / gstack / Karpathy / GitOps 五层门禁。
- 所有 commit message 和 PR 描述必须使用中文。
- 行为变更必须关联 change-id 和 Spec ID。

## Pack Validation

发布或同步前运行：

```bash
./scripts/validate-pack.sh
```

该脚本检查命名、skill frontmatter、旧前缀残留、冒号文件名，以及 README / AGENTS / CLAUDE 与 `commands/` 的命令集合一致性。
