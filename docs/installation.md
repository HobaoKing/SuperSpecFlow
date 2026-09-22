# 安装

安装同步本包能力，不安装 OpenSpec、Superpowers 或完整 mattpocock/skills。宿主已有规则优先。

## 全局能力

在本地包目录执行：

```bash
bash scripts/install-global.sh --codex-only
# 或 --claude-only / --both
```

脚本向选定宿主同步 skills；Claude 另同步 commands。已存在但不归本包所有、或被用户修改的文件会跳过并提示。已有全局 AGENTS.md / CLAUDE.md 不自动改写，缺少 include 时按输出追加。settings.json 仅提供可选 hook 提示。

源码获取可使用 `git clone https://github.com/HobaoKing/SuperSpecFlow.git <pack>`。`scripts/bootstrap.sh` 是远端快捷安装入口，指向 master；现有逻辑会 reset 安装 checkout，有本地修改时不要使用。尚未发布的工作区修改应从当前本地目录安装。

## 项目启用

全局安装默认已开启轻量自然语言路由，所有项目开箱即用，无需在每个项目中自己执行 init。

Claude 安装后重启会话即可加载全局指令并使 `/ssf-*` 进入命令补全。Codex-only 同步 skills 与 wrapper 后在新会话中自动生效。

若某个项目需要单独禁用 SuperSpecFlow，可在该项目根目录下放置 `.superspecflow/disabled` 文件。需要恢复或显式确认启用时，可在 Claude 中运行 `/ssf-init`，或在终端执行：

```bash
bash <pack>/scripts/_ssf_init_apply.sh
```

该命令仅确保 `.superspecflow/enabled` 存在并清除 `.superspecflow/disabled`，不预建阶段目录或改写宿主 AGENTS.md / CLAUDE.md。

项目可通过自己的 `.superspecflow/AGENTS.routing.md` / `CLAUDE.routing.md` 定义规则覆盖默认路由；显式 routing include 也可接入；这些项目文件由项目自己维护。

## 验证与卸载

检查安装输出中的 skipped 提示，确认目标 skill 可用和包引用正确。重复安装会保护用户修改。

`bash scripts/uninstall-global.sh --codex-only`（或 `--claude-only` / `--both`）按安装记录卸载并保护用户修改，不操作项目数据。
