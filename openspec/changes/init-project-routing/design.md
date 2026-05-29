# Technical Design: init-project-routing

## Architecture Summary

保留现有命令文件发现模型：每个 slash command 对应 `commands/ssf-*.md`。将项目级初始化入口从旧初始化命令收敛为 `ssf-init.md`，并同步 README、routing、AGENTS、CLAUDE 和安装文档中的命令集合。

全局安装由 `scripts/install-global.sh` 承担，`update.sh` 只作为兼容入口委托它。默认路径同步全局能力文件和 generated global wrappers；当用户传入 `--enable-natural-language <project>` 时，脚本再调用 `scripts/_ssf_init_apply.sh` 为该项目创建 `.superspecflow/enabled`。

## Data Flow

1. 用户执行 `/ssf-init`。
2. Agent 按 `commands/ssf-init.md` 在当前项目创建 `.superspecflow/` 软链。
3. Agent 提示用户在宿主项目指令文件中加入 `@./.superspecflow/*.routing.md`。

全局安装路径：

1. 用户执行 `./update.sh`。
2. 脚本复制全局能力文件。
3. 默认输出未启用自然语言路由的提示。
4. 用户执行 `./update.sh --enable-natural-language <project>` 时，脚本完成全局安装后初始化指定项目 zero-touch sentinel。

## API / Interface Changes

- 新增 slash command：`/ssf-init`。
- 移除旧初始化 slash command。
- 新增脚本选项：`./update.sh --enable-natural-language <project>`。

## Data Model Changes

无。

## Security / Permission Considerations

脚本仍不覆盖宿主项目 `AGENTS.md` 或 `CLAUDE.md`。项目自然语言路由必须通过 `/ssf-init`、显式安装动作，或用户手动添加 include 才启用。

## Failure Modes

- 用户传入不存在的 `<project>`：`scripts/_ssf_init_apply.sh` 继续报错并退出。
- 用户误用旧初始化命令：不提供该命令，文档也不再列出。
- 用户全局安装后未启用项目路由：`update.sh` 输出下一步提示。

## Observability

通过 `scripts/validate-pack.sh` 检查命令集合一致性，通过旧命名残留搜索检查仓库。

## Migration Plan

将所有公开引用迁移到 `/ssf-init`，不保留兼容别名。

## Rollback Plan

回滚本提交即可恢复旧命名与旧 `update.sh` 行为。

## Alternatives Considered

- 保留旧初始化命令作为别名：拒绝，双入口会让用户长期不确定推荐命名。
- 只改文档不改 `update.sh`：拒绝，无法满足全局安装时显式选择是否启用自然语言路由的需求。
