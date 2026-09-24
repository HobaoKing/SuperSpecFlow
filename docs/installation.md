# 安装

安装同步本包能力，不安装 OpenSpec、Superpowers 或完整 mattpocock/skills。宿主已有规则优先。

## 全局能力

### 远端一句话安装（推荐）

```bash
# 默认开启（同时支持 Claude Code、Codex 与 Antigravity）
curl -fsSL https://raw.githubusercontent.com/HobaoKing/SuperSpecFlow/master/scripts/bootstrap.sh | bash

# 若已有全局指令文件，可直接追加 --append 自动注入 include 行（免手动编辑）
curl -fsSL https://raw.githubusercontent.com/HobaoKing/SuperSpecFlow/master/scripts/bootstrap.sh | bash -s -- --append

# 或指定单个客户端
curl -fsSL https://raw.githubusercontent.com/HobaoKing/SuperSpecFlow/master/scripts/bootstrap.sh | bash -s -- --claude-only
curl -fsSL https://raw.githubusercontent.com/HobaoKing/SuperSpecFlow/master/scripts/bootstrap.sh | bash -s -- --codex-only
curl -fsSL https://raw.githubusercontent.com/HobaoKing/SuperSpecFlow/master/scripts/bootstrap.sh | bash -s -- --antigravity-only
```

`scripts/bootstrap.sh` 是远端快捷安装入口，指向 master 分支；它会将仓库 clone/update 至 `~/.superspecflow`（可通过环境变量 `SUPERSPECFLOW_HOME` 自定义路径），并自动调用 `install-global.sh` 完成全局安装与默认配置。该路径只影响 bootstrap 的检出位置，本地源码安装（`bash scripts/install-global.sh`）不写入这个变量；`SUPERSPECFLOW_HOME` 仅在 bootstrap 安装路径中使用。另有两个仅 bootstrap 读取的变量：`SUPERSPECFLOW_REPO`（源仓库地址）与 `SUPERSPECFLOW_BRANCH`（源分支，默认 `master`）——master 尚未发布的能力需显式指定 `SUPERSPECFLOW_BRANCH=develop` 才能装上。

### 本地包安装

源码获取可使用 `git clone https://github.com/HobaoKing/SuperSpecFlow.git <pack>`。尚未发布的工作区修改应从当前本地目录安装：

```bash
bash scripts/install-global.sh --all
# 或 --claude-only / --codex-only / --antigravity-only（单客户端）
# --both 表示只装 Claude Code 与 Codex、不含 Antigravity
# 添加 --append 可自动向已有全局指令文件顶部追加 include
```

脚本向选定宿主同步 skills；Claude 另同步 commands。已存在但不归本包所有、或被用户修改的文件会跳过并提示。已有全局 AGENTS.md / CLAUDE.md / GEMINI.md 默认不擅自改写，缺少 include 时会提示手动追加，亦可传入 `--append`（或在交互终端中确认）自动将 include 行追加至文件顶部。settings.json 仅提供可选 hook 提示。

### Antigravity 写入位置

| 目标 | 路径 |
|---|---|
| 全局 rules | `~/.gemini/GEMINI.md`（写入 `@~/.gemini/superspecflow/GEMINI.global.md` include 行） |
| IDE 全局 skills | `~/.gemini/config/skills/ssf-*/` |
| CLI/IDE 全局 skills | `~/.gemini/antigravity-cli/skills/ssf-*/`、`~/.gemini/config/skills/ssf-*/` |
| wrapper 与安装记录 | `~/.gemini/superspecflow/` |

- Antigravity 没有用户自定义全局 slash 命令目录，因此只同步 skills：CLI 会自动把 skill 暴露为 `/ssf-*`，IDE 里可在输入框用 `/<skill-name>` 手动调用。
- `~/.gemini/GEMINI.md` 同时是 Gemini CLI 的全局指令文件；写入 include 行后 Gemini CLI 也会加载同一份路由，属预期行为，不需要时可改用 `--claude-only` / `--codex-only` 单独安装。
- 若 IDE 的 Customizations 面板之后重写了 `~/.gemini/GEMINI.md` 导致 include 行丢失，重新执行安装脚本即可（include 判定幂等，已安装的 skills 会被跳过）。

## 项目启用

全局安装后所有项目开箱即用，无需逐项目执行 init。

Claude 安装后重启会话即可加载全局指令并使 `/ssf-*` 进入命令补全。Codex-only 同步 skills 与 wrapper 后在新会话中自动生效。Antigravity 重启 IDE / CLI 会话后 skills 与全局 rules 生效。

不想在某宿主启用时，移除该宿主全局指令文件中的 include 行即可（卸载脚本也会做这件事）。项目也可以在自己的指令文件中显式 include 其他规则文件，由项目自己维护。

## 验证与卸载

检查安装输出中的 skipped 提示，确认目标 skill 可用和包引用正确。重复安装会保护用户修改。重复执行上面的任一安装命令即更新到 master 最新发布：bootstrap 会更新 `~/.superspecflow` 检出并重装，归本包所有但被你改过的文件会跳过并提示。

`bash scripts/uninstall-global.sh --all`（或 `--claude-only` / `--codex-only` / `--antigravity-only` / `--both`）按安装记录卸载并保护用户修改，不操作项目数据。

卸载按各宿主的 `install-manifest.tsv` 记录删除本包装入的文件。若该清单丢失，已安装的 skills 会成为孤儿目录，需手动删除对应宿主的 skills 目录（如 `~/.gemini/config/skills/ssf-*`）并移除指令文件中的 include 行；重复安装不会覆盖用户在清单丢失前改过的文件。
