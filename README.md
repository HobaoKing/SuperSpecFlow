# SuperSpecFlow

[最新 Release](https://github.com/HobaoKing/SuperSpecFlow/releases/latest) · [3.0.6 更新说明](https://github.com/HobaoKing/SuperSpecFlow/releases/tag/v3.0.6) · [完整变更记录](CHANGELOG.md)

一个薄入口，加按需工程 skills。明确的小修复直接做；普通功能在会话里对齐目标后实现、验证；跨模块或跨会话工作只维护一份计划。

不依赖 OpenSpec 或 Superpowers，不要求 Spec ID、阶段签字、issue tracker、多 agent 或自动提交。

## 使用方式

| 场景 | 做法 |
|---|---|
| 问答、只读检查 | 直接处理，不创建流程文件 |
| 明确修复 | 定位 → 最小修改 → 针对性验证 |
| 普通功能 | 说明目标和验收点 → 实现 → 验证与 diff 检查 |
| 跨模块、跨会话 | 一份计划记录任务、验收、进度和必要风险 |
| 支付、权限、迁移、发布 | 根据实际影响补充负向验证、恢复和观测措施 |

会话授权持续有效，普通技术和测试选择由 agent 自主处理。提交、远端写入、发布、删除、权限、凭据和费用仍遵守实际授权范围。

## 3.0.6 更新亮点

- **专家方法落实到操作**：从任务相关的原始材料出发，检查遗漏、实际执行专业方法，并给出外部判据的结果或明确缺口。
- **简单实现与范围控制**：输入在入口校验，内部使用约定类型；简单单次逻辑内联，异常按实际处理需要捕获。推测性加固先说明故障、概率依据及代码和维护成本，由用户决定是否加入。
- **安装与门禁修复**：支持未修改技能跨源码路径重装，补齐技能体积预算、资源链接与 frontmatter 检查，修正并发评估器对合法持锁实现的误报。

仍使用原有七个入口与安装方式，无新增运行时依赖或数据迁移。专项参考按需读取，评估工具供维护者选择运行，不进入普通任务的默认流程。详细变更见 [变更记录](CHANGELOG.md)，实际评估与发布前检查见 [评估记录](docs/plans/skill-effectiveness.md)；有限合成场景不代表跨模型稳定收益、生产验收或第三方认证。

## 怎么知道 skill 有没有用

采用技能后，首次进度会简述技能名、具体方法和目标，例如：

> 使用 ssf-build：先复现下载失败后额度未返还的问题，再修复首次下载和重试入口，验证成功只扣一次。

结束看实际结果与证据：原问题是否复现、改动解决了什么、哪些验证通过、哪些仍未验证。审查看触发条件、定位和影响；计划看可执行任务与验收；发布看实际版本与状态读回。方法说明并入正常对话，同一任务不重复播报；要求“只给结果”时省略过程说明。普通问答不强行触发 skill。

安装、执行、效果是三件事：

| 要确认的事 | 看什么 |
|---|---|
| 已安装且与当前源码一致 | `bash scripts/doctor.sh --codex-only`（也支持 `--claude-only` / `--antigravity-only` / `--all`） |
| 本次确实使用 | 会话实际读取的 `SKILL.md`、采用的方法与对应工具操作；一句“已启用”本身不算执行证明 |
| 是否改善结果 | 相同输入下比较缺陷修复、回归、误报、授权越界及不必要操作，见 [行为验证](tests/behavior/README.md) |

诊断只读，不自动安装或修复，不发送遥测。源码改进不会自动同步到已安装副本；只有同步安装并被会话实际读取后才能采用新规则。没有真实对照数据，不宣称技能提高了多少质量或节省了多少 token。

## 接入

### 远端一句话安装（推荐）

```bash
# 默认开启（同时支持 Claude Code、Codex 与 Antigravity）
curl -fsSL https://raw.githubusercontent.com/HobaoKing/SuperSpecFlow/master/scripts/bootstrap.sh | bash

# 或指定单个客户端
curl -fsSL https://raw.githubusercontent.com/HobaoKing/SuperSpecFlow/master/scripts/bootstrap.sh | bash -s -- --claude-only
curl -fsSL https://raw.githubusercontent.com/HobaoKing/SuperSpecFlow/master/scripts/bootstrap.sh | bash -s -- --codex-only
curl -fsSL https://raw.githubusercontent.com/HobaoKing/SuperSpecFlow/master/scripts/bootstrap.sh | bash -s -- --antigravity-only
```

重复执行同一条命令即更新到 master 最新发布：脚本会更新 `~/.superspecflow` 检出并重装，归本包所有但被你改过的文件会跳过并提示。试用开发分支用 `SUPERSPECFLOW_BRANCH=develop`，见 [安装说明](docs/installation.md)。

### 本地源码安装

在包目录执行：

```bash
bash scripts/install-global.sh --all
# 或 --claude-only / --codex-only / --antigravity-only；--both 表示只装 Claude Code 与 Codex
# 带 --append 可自动向已有全局指令文件追加 include
```

全局安装后所有项目开箱即用：各宿主全局指令文件只多一行 include，指向包内轻量规则。Claude 重启会话后使 `/ssf-*` 进入命令补全。不想在某宿主启用时，移除对应全局指令文件中的 include 行即可（卸载脚本也会做这件事）。

见 [安装说明](docs/installation.md) 和 [运行环境](docs/compatibility.md)。卸载使用 `scripts/uninstall-global.sh`。

## 按需入口

| 入口 | 职责 |
|---|---|
| `/ssf-think` | 找到实际问题，核对能推翻方案的前提，比较可行选择并推荐 |
| `/ssf-plan` | 将目标拆成可验证的完整小步，安排依赖与高风险验证 |
| `/ssf-build` | 先复用再实现，核对契约；按需采用 TDD、根因定位与性能测量 |
| `/ssf-review` | 检查需求与正确性，按影响核查数据/权限/状态风险并排除误报 |
| `/ssf-qa` | 专项验收按风险验证旅程、边界、恢复和最终状态，遵守只读限制 |
| `/ssf-git` | 组织行为完整的提交，保护混合暂存区，核验合并和远端结果 |
| `/ssf-ship` | 核对候选证据、新旧兼容、恢复条件；按授权发布并读回 |

已接入项目可直接使用自然语言，按意图选最直接的 skill；明确修复无需先走讨论、计划、独立审查流程。复合任务按已有授权续接。只读适用参考，复用未变化的规则和有效证据，不自动刷新安装、重复评审或无依据重跑检查；简短报告不省略必要交付。

用户已经要求“计划后直接实现”或已授权后续操作时，继续完成同一范围内的任务；“只讨论”“只计划”“只评估”则停在相应交付。计划按用户指定路径或已有文件维护，普通修复不因有多个步骤就生成计划。

### 自然语言示例

直接描述目标和限制即可，不必记住命令或先走完全部入口：

| 你可以这样说 | 对应处理 |
|---|---|
| “保存失败后额度没返还，修好并验证重试。” | 定位首次与重试入口，修复并完成基础自测 |
| “列表越来越慢，找出原因并优化，权限逻辑保持。” | 测量查询与等待成本，定位瓶颈，同条件复测 |
| “取消订单和退款在这份需求里是什么关系？” | 已有约定明确时直接解释；存在业务取舍时再讨论 |
| “只验收下载流程，不修改任何项目文件。” | 只读核验并报告问题，新增测试也不写入项目 |
| “根据现有计划继续，保留我的其他改动。” | 核对当前状态，沿用唯一计划和既有授权续接 |
| “提交当前改动并发布版本，写清更新说明。” | 按宿主流程提交、发布并读回版本与 Release 状态 |

## 方法来源

采用 [mattpocock/skills](https://github.com/mattpocock/skills)（TDD、缺陷定位、代码审查）与 [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills)（编码前思考、简单优先、外科手术式修改、目标驱动执行）作为底层工程实践，随包提供精简适配版。取消逐项测试确认、强制双 agent、issue tracker 和自动提交。授权见 [NOTICE](NOTICE.md)。

工程方法进一步参考 Superpowers 的系统调试与计划自检、agent-skills 的渐进实现/接口设计/发布准备、gstack 的前提审视/风险审查/回归价值、ECC 的先查已有方案与分层验证，以及 Matt Pocock 的公开行为测试和需求/规范两个审查视角。每份方法参考携带固定修订来源，采用范围见 [NOTICE](NOTICE.md) 和 [设计记录](docs/plans/skill-effectiveness.md)。

这些方法融入现有七个入口：简单任务直接处理，复杂任务只加载相应参考；不增加新的角色链、必填流程文件、自动安装或上游整包依赖。使用反馈用于说明真实方法和证据，效果仍以任务结果检验。

## 维护

`routing/default.routing.md` 是规则源，公开的 AGENTS / CLAUDE / GEMINI routing 文件与它一致。`skills/` 负责工程方法，`commands/` 提供命令入口，`templates/` 提供可选模板。

本仓库 skill 的 `description` 使用单行无引号文本；包校验拒绝 YAML 块、多行续写及引用表示，再按字段值检查 1024 字节预算。该约定不依赖额外的 YAML 解析库。

计划生成脚本与计划、QA、发布模板随所属 skill 安装，资源路径相对于该 skill 的 `SKILL.md`；单独调用不依赖宿主项目存在 `templates/` 或已接入全局规则。计划、QA 公共模板与 skill 的 assets 副本由包校验保持一致。`skills/ssf-ship/assets/release-checklist.md` 是遵循宿主机制的通用模板；`templates/release-checklist.md` 保留本项目固定发布步骤，与 `docs/release-policy.md` 共同约束本项目发布。

行为评估的场景准备、专项核验与命令证据工具位于 `tests/behavior/`；fixture 生成成功不等于模型执行通过，合成场景也不代表生产或真机验收。

脚本与结构测试之外，按需使用 [Skills 行为验证](tests/behavior/README.md) 检查真实任务中的选择、续接、授权和证据边界；其结果与确定性测试分开记录。

## 参与开发与发布

功能提交在 `develop` 上累积，`master` 只通过发布合并提交前进（远端一句话安装拉取 master）。commit / PR 标题使用 `<英文类型>(<英文范围>): <中文摘要>`。版本档位判定树、发布顺序（Unreleased 归档 → VERSION bump → 发布提交 → 合入 master → tag → 推送 → 回合并 develop）、回滚方式见 [版本与发布策略](docs/release-policy.md)；分支与提交约定见 [分支与提交](docs/branching-strategy.md)。`major` 只在破坏既有契约时使用，`minor` 用于新增一类能力面（新宿主、新 skill、改变默认行为的 flag），`patch` 用于修复、文档和内部调整；发布提交只改 `CHANGELOG.md` 与 `VERSION`，`--no-ff` 合入 `master` 后按 `v<x.y.z>` 打 tag。随后基于该 tag 创建正式 [GitHub Release](https://github.com/HobaoKing/SuperSpecFlow/releases)，说明新增、优化、修复、升级方式与已知限制。Tag 固定源码提交，Release 提供版本说明和源码下载入口；两者共同构成可追溯的发布。各版本变更记录见 [CHANGELOG](CHANGELOG.md)。

提交忽略由具体仓库的 `.gitignore` 和仓库级校验负责，不放进可复用 skill、路由或 hook。

```bash
bash scripts/validate-pack.sh
bash scripts/test.sh
```

需要生成计划骨架时，可执行 `bash <pack>/scripts/new-plan.sh <topic> [project-dir]`，默认当前项目，生成 `docs/plans/<topic>.md`，不覆盖已有文件。

## 可运行示例

[会员续费提醒](examples/add-membership-renewal-reminder/README.md) 用一份计划、一个纯函数和一个单测文件展示完整的小改动；说明中附有提交消息示例。无需阶段表单或角色切换。
