# 版本与发布策略

本文件规定 SuperSpecFlow 的版本号定档规则、发布流程和回滚方式。提交与分支约定见 [分支与提交](branching-strategy.md)。

版本号形如 `x.y.z`，不带 `v` 前缀写在 `VERSION`；git tag 带前缀，形如 `v2.1.0`。

## 版本档位

### 判定树

按顺序问三个问题，命中即定档：

1. 是否删除、重命名或搬迁既有公开契约？（安装位置、`routing/` 文件名、CLI flag 语义、`/ssf-*` 入口、`.superspecflow/disabled` 机制）→ **major**
2. 是否新增一类用户可感知的能力面，或改变了默认行为？（新宿主目标、新 skill、新 command、改变默认安装内容的 flag、新安装目录）→ **minor**
3. 其余（修缺陷、文档勘误、脚本兼容性、CI、内部结构调整）→ **patch**

判断依据是**对用户的契约影响**，不是 diff 行数或工作量。一次发布可以包含多档改动，取其中的最高档。

### 边界表

| 变更 | 档位 | 说明 |
|---|---|---|
| 修复错误行为（误写文件、错误提示、回归） | patch | 例：`--claude-only` 误装 Antigravity |
| 文档、README、注释勘误 | patch | 纯文档不为 minor |
| 新增不影响默认行为的可选 flag | patch | 例：假设新增 `--dry-run` |
| 新增模板、非入口参考资料 | patch | 不产生新的调用面 |
| 新增 flag 且改变默认安装内容 | minor | 例：`--antigravity-only` / `--all` 使默认安装多一个宿主 |
| 支持新宿主 / 新客户端 | minor | 例：Antigravity |
| 新增 skill 或 command 入口 | minor | 用户多一个 `/ssf-*` |
| 删除、重命名入口或改变 flag 语义 | major | 老用户必须改用法 |
| 变更安装位置或 routing 文件名 | major | 老用户的 include 行失效 |

major 在 2.x 期间没有计划；真要做时必须在 CHANGELOG 写明手动迁移步骤。

## 发布流程

功能提交只在 `develop` 上累积；`master` 只通过发布合并提交前进，因为远端一句话安装（`scripts/bootstrap.sh`）拉取的是 `master`。

1. **门禁**：目标提交已在 `develop`，`scripts/validate-pack.sh`、`scripts/test.sh`（含一次带空格 `TMPDIR` 复跑）、`git diff --check`、`shellcheck -x`（CI 同参数）全部通过，工作区 clean。
2. **定版本号**：按判定树读当前 `VERSION`，写下新 `x.y.z`。
3. **改 `CHANGELOG.md`**：在顶部新增唯一一段 `## [<x.y.z>] - <YYYY-MM-DD>`。条目按 `Added` / `Changed` / `Fixed` / `Docs` 分组，中文，写清用户影响和实际风险；不留空段，不写未验证为通过的结论。
4. **改 `VERSION`**：单行 `x.y.z`，无 `v` 前缀。
5. **develop 发布提交**：`chore(meta): 发布 <x.y.z>`，只含 `CHANGELOG.md` 与 `VERSION`；正文写变更摘要、验证命令与结果、风险与回滚方式。
6. **合并到 master**：`git checkout master && git merge --no-ff develop -m "chore(meta): 发布 <x.y.z>"`。保留发布合并提交，不用 fast-forward 直推 master。
7. **推送**：`git push origin develop master`。
8. **打 tag**：`git tag -a v<x.y.z> -m "发布 <x.y.z>"`，tag 指向 **master 上的发布合并提交**，随后 `git push origin v<x.y.z>`。
9. **发布后核验**：tag 解引用落在 master 的合并提交上；`tests/version/test_version_contract.bats` 通过（`VERSION` 与 CHANGELOG 唯一当前版本段一致）；远端一句话安装可用。

## 回滚

- 上一个 tag 即回滚点，发布时不要删旧 tag。
- 代码回滚：优先 `git revert <发布合并提交>` 再走一遍上面的推送与打 tag；确需重置 master 到上一 tag 时，必须在授权下进行，并同步 `develop`。
- 用户侧：安装脚本对每个文件做归属校验，重装不会覆盖用户改过的 skills 或指令文件；回滚后用户重跑一句话安装即回到旧版本。
- 影响面观测信号：安装输出中的 `skipped` 警告数量、`~/.superspecflow` 更新是否成功、issue 回报。

## 已知不一致

以下为历史事实，按本文件统一执行，不改写已发布历史：

- `v2.0.0` 的 tag 指向 `16bbc04`（一个 fix 提交），而不是该次发布的合并提交 `6d6dc82`；`v2.0.1`、`v2.1.0` 的 tag 指向各自的发布合并提交。之后一律指向发布合并提交。
- 2.0 之前的发布用了 `准备 <ver> 发布` / `同步 <ver> 发布` 一类不同措辞的提交与合并标题。2.x 起统一为 `chore(meta): 发布 <ver>`。

## 示例

撰写本文件时，`develop` 领先 `master` 一个提交 `feat(install): 支持 Antigravity 目标安装`，包含新宿主目标、两个新安装目录、新 flag，且让默认安装多写一个宿主——按判定树第 2 条定 **minor**：

- 当前 `VERSION` 为 `2.1.0` → 发布 **`2.2.0`**。
- CHANGELOG 顶部新增 `## [2.2.0] - <发布日期>`：`Added` 段写 Antigravity 目标、写入位置（`~/.gemini/GEMINI.md` 与两个全局 skills 目录）和 `--antigravity-only` / `--all`，并说明默认安装范围由两家变为三家。
- 之后纯修复走 `2.2.1`，新 skill 或新 flag 走 `2.3.0`，二者不混发。
