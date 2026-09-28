@./routing/CLAUDE.routing.md

# SuperSpecFlow 仓库入口

规则以 `routing/default.routing.md` 为源，三个公开 routing 文件保持相同内容。默认直接执行明确任务；大任务按需使用一份计划，不依赖 OpenSpec 或 Superpowers。

- `.superspecflow/`、`.claude/`、`.codex/`、`.gemini/`、`superpowers/`、`docs/superpowers/`、`.DS_Store` 是本地运行时、安装或缓存产物，不得提交。
- 修改后运行 `scripts/validate-pack.sh`、受影响测试和 `git diff --check`。
- 本次新增或行为、契约变化的非平凡函数，在实现定义处写简体中文注释，说明功能与实际适用的输入输出语义、约束。涉及业务分支、状态、异步、失败处理或副作用不能豁免；无额外规则的简单 getter/setter、透传、初始化及纯格式调整可豁免，不补写无关历史、生成或第三方代码。
