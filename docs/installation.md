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

Claude 安装后重启会话，使 `/ssf-init` 进入补全，然后在目标项目调用。Codex-only 不安装 Claude commands，在目标目录执行：

```bash
bash <pack>/scripts/_ssf_init_apply.sh
```

只创建 `.superspecflow/enabled`，不预建阶段目录或改写宿主 AGENTS.md / CLAUDE.md。显式 init 后更新本会话状态；宿主未重新读取时新开会话。

全局安装只提供能力，未 opt-in 项目按宿主默认方式工作。项目可用显式 routing include 接入，或通过自己的 `.superspecflow/AGENTS.routing.md` / `CLAUDE.routing.md` 定义规则；这些项目文件由项目自己维护。

## 验证与卸载

检查安装输出中的 skipped 提示，确认目标 skill 可用和包引用正确。重复安装会保护用户修改。

`bash scripts/uninstall-global.sh --codex-only`（或 `--claude-only` / `--both`）按安装记录卸载并保护用户修改，不操作项目数据。
