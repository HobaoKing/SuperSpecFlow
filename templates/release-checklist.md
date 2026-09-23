# 发布检查：<主题>

仅在发布请求中使用，可合并到已有计划或发布记录。

## 发布顺序（本包固定，按序执行）

1. **Unreleased 归档**：把 `CHANGELOG.md` 顶部 `## [Unreleased]` 的条目并入新的 `## [<x.y.z>] - <YYYY-MM-DD>` 段；没有未发布条目就不要发版。同一步回补等待本版落地的文档：README 与 `docs/` 中「未发布 / 尚未发布」一类临时说明要么兑现成正式表述，要么删除。
2. **VERSION bump**：`VERSION` 改为同一个 `x.y.z`（单行、无 `v` 前缀）。
3. **develop 发布提交**：`chore(meta): 发布 <x.y.z>`，只含 `CHANGELOG.md` 与 `VERSION`。
4. **合并 master**：`git checkout master && git merge --no-ff develop -m "chore(meta): 发布 <x.y.z>"`（远端一句话安装拉取 master）。
5. **打 tag**：`git tag -a v<x.y.z> -m "发布 <x.y.z>"`，指向 master 上的发布合并提交。
6. **推送**：`git push origin develop master`，再 `git push origin v<x.y.z>`。
7. **回合并 develop**：`git checkout develop && git merge --no-ff master`，让 master 侧提交（含 tag 指向的合并提交）成为 develop 祖先，保证 `git describe --tags` 在 develop 上也能得到正确版本号。

版本档位判定见 [版本与发布策略](../docs/release-policy.md)。

## 变更与风险

- 目标环境、变更范围和实际授权：
- 相关测试、失败路径和未解决问题：
- 数据或配置影响、迁移顺序（适用时）：

## 回滚与观测

- 回滚或恢复方法、触发条件和不可逆限制：
- 上线后观测信号、责任人（适用时）：

## 执行结果

- 实际执行结果、读回证据或具体阻塞：

检查通过只是发布建议，不能代替实际操作授权或执行结果。
