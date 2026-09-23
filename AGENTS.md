@./routing/AGENTS.routing.md

# SuperSpecFlow 仓库入口

规则以 `routing/default.routing.md` 为源，三个公开 routing 文件保持相同内容。默认直接执行明确任务；大任务按需使用一份计划，不依赖 OpenSpec 或 Superpowers。

- `.superspecflow/`、`.claude/`、`.codex/`、`.gemini/`、`superpowers/`、`docs/superpowers/`、`.DS_Store` 是本地运行时、安装或缓存产物，不得提交。
- 修改后运行 `scripts/validate-pack.sh`、受影响测试和 `git diff --check`。
- 本次新增或行为、契约发生变化的函数必须在实现定义处写简体中文函数级注释，说明功能及实际适用的输入输出语义、约束；仅格式调整不补注释，不补写无关历史代码。
