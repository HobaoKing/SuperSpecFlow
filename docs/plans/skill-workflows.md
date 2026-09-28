# Skills 执行流程修复与验证

## 目标与边界

为 skill 提供独立通用发布模板，保留本项目发布清单及 tag 规则；修复独立 skill 依赖不完整、指定计划路径冲突和计划触发不一致；同时明确审查范围、已有授权续接和验证边界。保持七个按需入口，不引入阶段审批或自动串行流水线。

## 任务与验收

- [x] plan、qa、ship 的必要资源随 skill 安装；build 不依赖未定位的包资源。
- [x] 通用发布模板遵循宿主发布机制，本包发版步骤保留在原有 `templates/release-checklist.md` 与 `docs/release-policy.md`。
- [x] 用户指定或已有计划优先；小修复不因多步骤生成计划；只讨论、只计划的边界明确。
- [x] 功能审查不被无关 diff 带偏；同范围会话授权续用；测试限制及发布评估边界明确。
- [x] 定向脚本测试、完整测试、包校验、ShellCheck、skill 结构校验与 diff 检查。
- [x] 独立模型在隔离项目执行场景，核验实际产物、命令与最终报告，记录失败和修复结果。

## 验证与进度

2026-09-28 完成。环境为本地 macOS；仓库基线 `d34ff52`。执行结果：

- 完整 `bash scripts/test.sh`：133/133 通过。新增独立 skill 资源测试先复现 3 项缺失，再修复至通过。
- 含空格且带尾部斜杠的 TMPDIR 下，计划、资源、校验器相关测试：17/17 通过。
- `bash scripts/validate-pack.sh`、ShellCheck（包脚本、skill 脚本和测试 helper）、7 个 skill 的 `quick_validate.py`、Python AST 语法检查及 `git diff --check` 通过。
- 3 个不继承主任务历史的执行 agent 分组运行 9 个场景；各场景使用独立临时仓库，仅提供请求、skill 目录和项目事实，不提供预期答案。主 agent 读取执行报告并核对文件、diff、index、commit 和发布状态，9/9 满足本轮验收。

| 场景 | 实际结果 |
|---|---|
| think | 只讨论，项目无修改 |
| plan | 只写 `notes/quota-plan.md`，没有实现或额外默认计划 |
| build | 复现零额度失败，最小修复后 3/3 测试通过，没有生成计划 |
| plan-build | 先写指定计划，直接实现并验证，再更新同一计划，无阶段确认 |
| review | 沿指定功能找到并复现缺陷；保留原有无关 diff，不修改实现 |
| git | 只提交授权的 quota.py，另一任务的 notes.txt 内容和暂存 blob 保持不变，无推送 |
| qa | 3/3 单测通过，无 build、服务启停或实现修改 |
| ship-assess | 只评估，版本仍为 release-41，没有调用发布脚本 |
| ship-execute | 按宿主 runbook 执行一次本地模拟发布，读回 test / release-42 状态，无额外 Git 操作 |

评估输入与详细报告在本次临时目录 `/tmp/ssf-skill-evaluation-20260928/`，报告为 `reports/planning.md`、`reports/review-git.md`、`reports/qa-ship.md`。所用 skills 副本与本轮源码逐文件一致；按相对路径排序，对「路径 + NUL + 内容 + NUL」计算的 SHA-256 为 `df92ead9b5c9c8d2b2c32e0f1895b14b86f87f4e756d576d5332fe726b2a92b6`。临时目录不作为长期 CI 产物；可用 `tests/behavior/create-fixtures.py` 重新生成输入。

核验时发现宿主全局 `remote.origin.proxy` 使 `git remote` 显示 origin，但无 remote URL；该夹具问题未造成远端操作。创建器与后续评估说明已补上全局/系统 Git 配置隔离；使用冲突的宿主签名、模板和远端配置重新生成九个项目并验证成功，旧场景产物也已在隔离配置下重新核对。此次未重新执行模型场景，因为修复仅涉及夹具环境，skills 内容未变。

证据边界：本轮完成本地脚本回归和有限场景的模型执行验证，没有实测三个宿主 UI 的自动发现/加载，也未进行模型重复采样。模拟发布的 healthy 字段只证明状态落盘，不代表真实服务健康。真实全局安装未刷新；未提交、推送或发布本仓库。

同日按用户纠正恢复本项目发布清单与发布策略文档的原始内容，两份文件相对基线均无 diff；通用模板仅保留在 ship skill 内，校验器不再要求两种发布模板相同。本次调整后资源与校验器测试 11/11、包校验、ShellCheck 与 diff 检查通过；skills 内容未变。
