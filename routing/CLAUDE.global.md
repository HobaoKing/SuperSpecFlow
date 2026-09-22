# SuperSpecFlow 全局入口

全局安装提供可选能力，宿主规则优先。优先采用 SessionStart 注入的 `<ssf-status>` 标签，否则每个会话首次需要判断项目接入时，检查 `.superspecflow/enabled` 是否为文件。

- 未启用：按默认方式处理自然语言，不读取包 routing。显式 `/ssf-*` 请求仍可独立执行，不隐式启用项目。
- 已启用：优先读取项目的 `.superspecflow/CLAUDE.routing.md`；没有覆盖时读取 `<repo>/routing/CLAUDE.routing.md`。只有启用后才读取，不使用无条件 include。
- 在本会话显式运行 `/ssf-init` 后采用新的启用状态；其他安装变更可重启会话加载。

按需入口：`/ssf-think`、`/ssf-plan`、`/ssf-build`、`/ssf-review`、`/ssf-qa`、`/ssf-ship`、`/ssf-git`、`/ssf-init`。命令注册取决于宿主能力，可直接使用相应 skill 或自然语言请求。
