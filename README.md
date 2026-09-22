# SuperSpecFlow

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

## 接入

在包目录执行：

```bash
bash scripts/install-global.sh --codex-only
# 或 --claude-only / --both
```

Claude 安装后重启会话，使 `/ssf-*` 进入命令补全，在目标项目运行 `/ssf-init`。Codex-only 在目标目录运行 `bash <pack>/scripts/_ssf_init_apply.sh`。仅创建 `.superspecflow/enabled`。

见 [安装说明](docs/installation.md) 和 [运行环境](docs/compatibility.md)。卸载使用 `scripts/uninstall-global.sh`。

## 按需入口

| 入口 | 职责 |
|---|---|
| `/ssf-think` | 讨论需求和方案，只澄清关键问题 |
| `/ssf-plan` | 按需写一份计划 |
| `/ssf-build` | 实现、修复；按需使用 TDD / 调试方法 |
| `/ssf-review` | 检查代码正确性和需求符合度 |
| `/ssf-qa` | 测试、浏览器或视觉验收，明确证据边界 |
| `/ssf-git` | 按请求处理分支、提交、PR 等 Git 操作 |
| `/ssf-ship` | 发布评估与已授权发布 |
| `/ssf-init` | 启用当前项目 |

已接入项目可直接使用自然语言。各能力独立执行，不自动串联阶段。

## 方法来源

采用 [mattpocock/skills](https://github.com/mattpocock/skills) 的 TDD、调试和代码审查方法，随包提供精简适配版，固定来源修订，不自动拉取整个上游。取消逐项测试确认、强制双 agent、issue tracker 和自动提交。授权见 [NOTICE](NOTICE.md)。

## 维护

`routing/default.routing.md` 是规则源，公开的 AGENTS / CLAUDE routing 文件与它一致。`skills/` 负责工程方法，`commands/` 提供命令入口，`templates/` 提供可选模板。

提交忽略由具体仓库的 `.gitignore` 和仓库级校验负责，不放进可复用 skill、路由或 hook。

```bash
bash scripts/validate-pack.sh
bash scripts/test.sh
```

需要生成计划骨架时，可执行 `bash <pack>/scripts/new-plan.sh <topic> [project-dir]`，默认当前项目，生成 `docs/plans/<topic>.md`，不覆盖已有文件。

## 可运行示例

[会员续费提醒](examples/add-membership-renewal-reminder/README.md) 用一份计划、一个纯函数和一个单测文件展示完整的小改动；说明中附有提交消息示例。无需阶段表单或角色切换。
