# Proposal: init-project-routing

## Summary

将项目级自然语言路由初始化命令统一为 `/ssf-init`，并让全局安装默认只安装能力文件，只有用户显式打开开关时才初始化某个项目的自然语言路由。

## Problem

原初始化命名容易被理解为运行时开关或可与其他命令并存的别名，不够准确。全局安装说明也缺少显式选项来区分“安装全局能力”和“启用某个项目的自然语言路由”。

## Goals

- 使用 `/ssf-init` 作为唯一项目初始化命令。
- 不保留旧初始化命令或文档入口。
- 全局安装默认不接管自然语言路由。
- 为全局安装提供显式自然语言路由初始化开关。

## Non-goals

- 不改变 `ssf-think`、`ssf-spec`、`ssf-build` 等阶段语义。
- 不覆盖宿主项目 `AGENTS.md` 或 `CLAUDE.md`。
- 不引入新的外部依赖。

## User Impact

用户可以通过 `/ssf-init` 初始化当前项目接入，也可以通过 `./update.sh --enable-natural-language <project>` 在全局安装后初始化指定项目。默认全局安装只提供 commands / skills / agents 能力，不自动接管所有项目自然语言。

## Affected Areas

- `commands/`
- `routing/`
- `README.md`
- `docs/`
- `scripts/install-project-symlinks.sh`
- `update.sh`

## Success Metrics

- 仓库中不再出现旧初始化命名。
- `commands/` 中存在 `ssf-init.md`。
- pack validation 通过。
- 安装脚本会软连 `ssf-init.md`，不会生成旧初始化命令文件。

## Risks

- 旧文档或用户记忆中仍使用旧初始化命令。
- 全局安装开关语义不清可能导致误以为默认启用自然语言路由。

## Rollout Strategy

作为流程包文档与命令元数据变更一次性发布。旧命名不保留别名，避免双入口造成长期混淆。

## Open Questions

无。
