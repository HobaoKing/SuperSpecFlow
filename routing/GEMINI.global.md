# SuperSpecFlow 全局入口

全局安装默认全局开启轻量路由，无需在每个项目中单独执行 init，宿主规则优先。每个会话首次需要判断项目接入时，默认视为启用，仅在项目根存在 `.superspecflow/disabled` 文件时判定为已禁用。

- 默认启用：优先读取项目的 `.superspecflow/GEMINI.routing.md`；没有覆盖时读取 `<repo>/routing/GEMINI.routing.md`。
- 已禁用（存在 `.superspecflow/disabled`）：按默认方式处理自然语言，不读取包 routing。显式 `/ssf-*` 请求仍可独立执行。
- 恢复已禁用项目：执行 `bash <repo>/scripts/_ssf_init_apply.sh` 清除禁用标记；其他安装变更可重启会话加载。

按需入口：`/ssf-think`、`/ssf-plan`、`/ssf-build`、`/ssf-review`、`/ssf-qa`、`/ssf-ship`、`/ssf-git`（CLI 中 skill 自动成为同名斜杠命令，IDE 里在输入框用 `/<skill-name>` 手动调用；Antigravity 没有 `/ssf-init` 命令入口，恢复启用用上面的脚本）。
