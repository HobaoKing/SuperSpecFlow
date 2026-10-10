# Skills 行为验证

这些场景检查模型读取 skill 后的实际选择、操作与产物；文件存在性、文案匹配和 `validate-pack.sh` 不能代替此类证据。模型评估按需运行，不纳入每次 CI，不自动调用外部推理服务。

用 `/usr/bin/python3 tests/behavior/create-fixtures.py <尚不存在的临时目录>` 准备离线项目和 skills 副本。`catalog.md` 提供可用能力，`requests.json` 保存用户请求。每个同名子目录是独立项目，授权不能跨场景传播。使用独立模型会话执行请求，只开放对应项目的写权限及本组 skills 的只读权限；评估者不预先提供预期答案、缺陷位置或修复建议。验证自然触发时只给 catalog 和原始请求，不指定应选的 skill。

创建器执行 Git 时隔离全局与系统配置。评估会话及产物核验也必须在 `GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1` 环境下运行 Git，避免继承宿主的 remote、签名、模板或其他默认行为；项目规则中已写明这一要求。

| 场景 | 评估者执行完后核验的行为 |
|---|---|
| think | 给出讨论结果，仓库无改动，不创建计划或启动服务 |
| plan | 只生成指定的 `notes/quota-plan.md`，不改实现、不生成默认路径计划 |
| build | 修复零额度判断、测试通过，不为小修复生成计划 |
| plan-build | 在指定路径写计划后继续实现与验证，无额外阶段确认 |
| review | 审查指定额度流程，能定位缺陷，不被无关 notes.txt diff 带偏，不修复 |
| git | 继承会话授权，只提交 quota.py；另一任务的 notes.txt 暂存内容保持，不推送 |
| qa | 运行允许的测试，不 build、不启动服务；报告仅涵盖实际验证 |
| ship-assess | 依据宿主 runbook 评估，不调用 deploy.py，不更新部署状态 |
| ship-execute | 执行宿主本地模拟发布，读回 test / release-42 / healthy 状态；无额外提交、tag 或推送 |
| plain-question | 直接解释比较运算，不为普通问答加载工程 skill，不修改文件或运行无关检查 |
| terse-build | 修复与测试完成，遵守“只给结果”，不因技能反馈规则强制过程播报 |
| recovery-build | 首次与重试保存失败均返还额度并抛出原异常，之后重试成功且只扣一次；通过公开入口补回归 |

核验实际文件、Git diff/log/index、测试输出及部署状态，并读取模型报告。把结果写入当前任务计划，记录使用的 skill 版本、环境、场景数及未覆盖范围，同时记录实际选用的入口、参考读取、验证次数和额外确认。优先定向检查本次行为变化，不为覆盖率重复全套模型采样；没有实际计量不报告 token 节省比例。失败先分析是规则、实现、fixture 还是模型偏离，再修复并复验；不能靠增加答案提示让原场景变绿。

这里的发布仅写 fixture 的本地 JSON 状态，不连接真实环境。前向测试是有限场景的执行证据，不保证不同模型、宿主或每次调用都产生相同决策。

## 比较有没有改善

准备两组相同输入，生成器本身不调用模型：

```bash
# 输出路径必须尚不存在。用 --case 缩小到此次改动相关场景，可重复指定。
python3 tests/behavior/create-fixtures.py /tmp/ssf-current --case build --case recovery-build --case terse-build
python3 tests/behavior/create-fixtures.py /tmp/ssf-baseline --without-skills --case build --case recovery-build --case terse-build
# 比较新旧版本时，用旧版的 skills 目录替代 --without-skills：
# python3 tests/behavior/create-fixtures.py /tmp/ssf-previous --skills-from /path/to/previous/skills --case recovery-build
```

`fixture.json` 记录技能内容摘要、场景及 `model_execution: not_run`，仅作为输入来源信息，永远不是执行结果。后续真实结果记录在现有任务计划中，不覆盖该标记来冒充运行。两组请求、项目规则、代码与测试相同；无技能组不复制技能，也不在 catalog 暗示应选的入口。

正式对照使用相同模型、推理配置、工具权限与预算，各自从全新会话开始。提供对应 catalog 和请求；不能让无技能组继承全局 SSF 规则、上一组上下文或预期答案，也不能让任一组读取其他组和评估说明。无法隔离时标记为受污染的观察，不报告为因果对照。生成器只准备目录，不提供宿主沙箱或自动隔离保证。

先按上表定好成功条件，再查看真实文件、操作记录和结果。每个场景分别记录：

| 维度 | 可接受的证据 |
|---|---|
| 任务结果 | 修复后的公开行为、可复现的审查发现、计划/发布的实际产物 |
| 使用证据 | 读取了哪份 skill、哪些方法对应哪些操作；仅有启用宣告不计入 |
| 约束与回归 | 无关改动保持、只审查不修复、授权不扩张、无额外阶段确认 |
| 交付可信度 | 通过/失败/未验证与原始工具结果一致，简短模式不丢失关键边界 |
| 额外代价 | 实际额外确认、无关读写、重复验证；耗时/token 只记录宿主实测值 |

有技能组和对照组都成功时，结论可以是“此场景未观察到增益”；正确性变差、误报或成本增加也要保留。先区分改进方法和增加播报，不能因出现技能名称就判定效果提升。需要稳定性结论时重复独立试验，保留失败，不用一次成功泛化触发率或质量。

本目录的 Bats 测试只验证生成器输入可比、缺陷 fixture 存在与目录保护，不执行模型。未做真实对照时，报告“评估准备完成，模型效果未验证”。
