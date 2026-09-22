# 运行环境

脚本支持 macOS Bash 3.2+ 和 Linux，依赖 `git` 及常见 POSIX 工具。远端 bootstrap 需要 `curl`；开发测试需要 `bats`，静态检查需要 `shellcheck`。可运行示例及其 CI 测试需要 Python 3.8+，不依赖第三方 Python 包。文本检索优先 `rg`，包校验不依赖它。

Claude 使用 commands 和 skills；Codex 使用 skills 和项目指令，不假定支持 Claude 的 slash 注册。方法参考文件随 skill 目录安装，运行时无需访问上游或 issue tracker。

全局 wrapper 只在 `.superspecflow/enabled` 存在时读取 routing，项目自定义规则优先。显式 include 也可接入，不支持 include 的宿主使用 `templates/integration/` 的文字入口。宿主业务、构建和运行约束优先。

技能负责方法，不管理宿主的 `.gitignore` 或特定文件的提交策略。

安装见 [安装说明](installation.md)。
