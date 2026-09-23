# 运行环境

脚本支持 macOS Bash 3.2+ 和 Linux，依赖 `git` 及常见 POSIX 工具。远端 bootstrap 需要 `curl`；开发测试需要 `bats`，静态检查需要 `shellcheck`。可运行示例及其 CI 测试需要 `python3` 命令（Python 3.8+），不依赖第三方 Python 包。文本检索优先 `rg`，包校验不依赖它。

Claude 使用 commands 和 skills；Codex 使用 skills 和项目指令，不假定支持 Claude 的 slash 注册；Antigravity 使用 skills 与全局 `GEMINI.md` rules，没有用户自定义全局 slash 命令目录，skill 由 CLI 暴露为 `/ssf-*`、IDE 中按 `<skill-name>` 手动调用。方法参考文件随 skill 目录安装，运行时无需访问上游或 issue tracker。

全局 wrapper 默认开启轻量自然语言路由，仅在项目根目录存在 `.superspecflow/disabled` 时禁用。在本包内部，项目 `.superspecflow/<宿主>.routing.md` 存在时替代包内默认 routing；普通初始化只创建启用标记，不生成项目覆盖文件。显式 include 也可接入。

Claude、Codex 与 Antigravity 的全局指令文件都支持按绝对路径 include 另一个 Markdown 文件，因此三个宿主都不需要 `templates/integration/` snippet；Antigravity 的 include 行写在 `~/.gemini/GEMINI.md` 中，且该文件同时被 Gemini CLI 读取。

不支持 include 的宿主可手动将 `templates/integration/` 对应 snippet 追加到已有项目指令中，将 `<pack>` 替换为实际安装目录的绝对路径；不要覆盖宿主文件。snippet 先读取存在的项目覆盖文件，否则回退到包内 routing，不自动复制或同步整份规则。

宿主业务、构建和运行约束优先。SuperSpecFlow 不依赖或自动调用 Superpowers；两者共存时按宿主实际指令层级及用户指定的方法执行，本包不声明对其他插件的全局覆盖权。

技能负责方法，不管理宿主的 `.gitignore` 或特定文件的提交策略。

安装见 [安装说明](installation.md)。
