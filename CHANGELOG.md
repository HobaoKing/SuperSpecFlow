# Changelog

All notable SuperSpecFlow package changes are recorded here.

版本定档规则、发布流程与回滚方式见 [版本与发布策略](docs/release-policy.md)。未发布条目先记在下面的 `[Unreleased]` 段，发布时整体归档为带日期的版本段。

## [3.0.6] - 2026-10-29

本补丁版本保留七个入口、安装位置、命令参数与按需流程，无新增运行时依赖或数据迁移。

### Changed

- think 将专家检查落实为遗漏审视、原始材料取证、专业方法实际执行及外部判据核验；build、QA 与公共规则同步证据要求，明确自写测试、其他 AI 与第三方验证的区别。
- 简化实现约束明确入口一次校验、内部传递约定类型、简单单次逻辑内联与窄范围异常处理；推测性低概率并发/安全加固须先说明故障、概率依据及维护成本，再取得针对方案的同意，复用既有同范围授权。

### Fixed

- 从另一个源码检出路径重装时，未修改且归属清单匹配的 skill 可迁移到新来源，避免规则已更新但技能被误判为用户内容而保留旧版；用户修改、软链及特殊文件继续受保护。
- 并发评估器允许合法快照读取等待刷新锁，不再因核验器自身延迟释放拉取而误报；增加锁内/锁外规范化正例和半发布、失败污染反例。
- 包校验增加入口、description、参考资料及入口总量预算和修复提示，核对技能资源链接；拒绝多行 description 绕过预算及缺少 frontmatter 结束分隔符的无效技能。

### Docs

- 补充状态类型审查、异步快照与对象共享回归场景，以及专家取证、授权续接和简短任务的实际评估记录；保留失败、追加观察和未证明部分，不将合成样本通过表述为普遍质量提升。

### Validation

- 3.0.6 候选在 macOS 本地完整测试 168/168 通过，带空格 `TMPDIR` 复跑 168/168 通过；包校验、CI 同参数 ShellCheck、七个技能格式检查与 `git diff --check` 通过。
- 上述为发布前本地验证；远端 CI 和发布后安装读回结果见本版 GitHub Release 的核验记录。历史定向行为验证只覆盖对应合成场景，不构成第三方认证或跨模型稳定收益证明。

## [3.0.5] - 2026-10-12

本次从 3.0.3 直接升级至 3.0.5，未发布 3.0.4；保留现有七个入口、安装位置与命令契约，无数据迁移。

### Added

- 为 ssf-build 增加按需性能参考：按症状选择证据、定位瓶颈、同条件比较收益与代价，并核对权限、租户及行为保持。
- 新增中文自然触发、连续意图切换、上下文压缩续接、复杂检索、跨会话交接和隔离浏览器行为场景，以及契约、支付幂等、队列、回填、可观测性与过载恢复专项项目。
- 新增独立专项核验与命令证据记录工具：完整检查项、严格布尔结果、固定输入保护、原始输出与失败/超时保留、陈旧证据检测。

### Changed

- think 与 build 对需求、术语及代码冲突增加业务含义辨析，用有效约定和边界场景核对状态、副作用与旧协议兼容，不默认新建术语文档或扩展重构。
- 澄清技能选择：事实解释直接回答，实现附带的基础自测沿用 build，专项测试与验收使用 QA。

### Fixed

- QA 续接明确保留最近授权边界；用户要求不改文件时，补充测试同样不写入项目，采用内存执行或报告缺口。

### Docs

- 完善 README 的更新亮点、自然语言示例、版本入口与评估边界，补齐方法来源和历史演练记录。
- 发布策略与清单加入正式 GitHub Release 创建及读回；Tag 固定源码，Release 说明新增、优化、升级方式和已知限制。

### Validation

- 按维护者本次要求不重跑发布验证；历史评估记录不代表当前候选已重新验证。推送触发的 CI 结果以 GitHub Actions 实际状态为准。
- 合成场景与本地演练不等于生产、真机、真实支付或跨模型稳定效果，不宣称未实测的质量提升及 token 收益。

## [3.0.3] - 2026-10-10

### Added

- 增加只读安装诊断 `scripts/doctor.sh`，区分安装/规则接入、来源差异、旧版副本和本地修改，明确安装状态不代表模型实际执行或效果提升。
- 行为评估输入支持指定旧版 skills、无技能对照与场景筛选；新增普通问答、简短输出、失败恢复场景，记录输入内容摘要并区分脚本测试与模型评估。

### Changed

- 七个 skills 与 routing 增加一次性的具体方法说明和交付证据，遵守简短输出偏好；实现、审查与验收补充相关入口及失败恢复链检查，不引入固定阶段或额外审批。
- 将五个上游项目的具体工程方法融入七个 skills：前提审视、可验证任务拆分、先查复用能力、接口契约、边界取证、测试价值、风险审查与误报反证、旅程复验和发布恢复推演。新增五份按需参考，增强三份现有参考，同步计划/QA/发布资源并记录固定来源。
- 复审收紧入口与参考的重复内容，将 Git 的完整改动检查限定到相关写操作；补充按缺口收敛检索、删除前核对兼容与调用方复杂性、review 反馈反证，以及异步终态和拒绝后无副作用的验证。

## [3.0.2] - 2026-09-28

### Fixed

- 修复 Linux CI 旧版 ShellCheck 对未加引号的 EXIT trap 和组合条件判断的诊断：明确引用 trap 命令、局部标注回调间接调用并使用 if 分支，不改变安装校验、失败恢复或退役清理行为；CI 将静态检查前移并输出检查器版本，提前发现环境差异。

## [3.0.1] - 2026-09-28

### Fixed

- 安装先暂存校验再替换，完成后读回能力、清单和接入信息；验证通过后才清理可证明归属且未修改的退役项，部分安装单独提示。
- 对齐自然语言触发、会话授权与按需读取，消除重复澄清、自动隔离及重复验证的歧义；保留安全边界，限定临时本地测试进程例外和函数注释豁免。
- 补齐本项目发布文档独立提交、回合并后的远端同步与读回步骤。
- 修复独立 skill 调用的资源依赖：计划生成器、计划/QA/发布模板随 skill 安装，公共入口保持兼容并校验计划、QA 模板副本一致性。
- 为 ship 提供遵循宿主机制的通用发布模板，保留本项目原有发布清单和 tag 规则；统一计划触发、用户路径优先和已有授权续接，功能审查不被无关 diff 带偏。
- 增加独立 skill 资源回归及离线模型行为场景，区分脚本验证与实际模型执行证据。
- bootstrap 在切换版本前拒绝与本地未跟踪、被忽略文件冲突的同名或父子路径，保留不冲突的本地文件。
- 安装和卸载共用归属判定，仅匹配每个目标最近一次安装记录；兼容旧版追加式 manifest，保护用户手动回退、软链及特殊文件。
- 升级清理未修改的退役能力，保留用户修改或无归属记录的内容；包含 Antigravity 的双宿主更新不再扩展安装范围。
- 卸载正确清空仅含 include 的软链目标并保持权限；purge 在卸载前检查当前目录和其他宿主对共享包的引用。
- 安装汇总区分能力同步与 rules 接入；CI 按 push / PR 的真实提交范围检查空白错误。

### Docs

- 更新安装、迁移与 purge 说明，修复 CHANGELOG 发布策略链接和合并提交回滚命令。

## [3.0.0] - 2026-09-24

**手动迁移（major）**：

- 升级方式不变：重跑一句话安装或 `bash <pack>/scripts/install-global.sh`；全局 wrapper 会被重写为自包含规则全文，宿主全局指令文件中的 include 行路径不变，无需手动处理。
- 曾用 `.superspecflow/disabled` 禁用或 `/ssf-init` 恢复项目的：机制已删除，遗留的标记文件无影响；不想在某宿主启用时，移除对应全局指令文件中的 include 行即可。
- `update.sh --enable-natural-language` 现以退出码 2 报错：从自动化脚本中去掉该参数即可，其余参数语义不变。
- 2.x 安装曾建议手动向 Claude `settings.json` 合并 SessionStart hook 片段（指向 `scripts/hooks/session-start-detect.sh`）：该脚本已删除，合并过该片段的请从 `settings.json` 移除，避免会话启动报"脚本不存在"。

### Removed

- 删除 `.superspecflow/disabled` 开关、`/ssf-init` 命令、`scripts/_ssf_init_apply.sh`、Claude SessionStart hook（`scripts/hooks/session-start-detect.sh`）与 `update.sh --enable-natural-language`：不再用标记文件或 hook 判定启用状态，不想启用时移除宿主全局指令文件中的 include 行即可。`install-global.sh --no-hook` 保留为兼容 no-op。按发布策略属公开契约删除，本版定档 major。
- 全局 wrapper 从入口话术瘦身为安装时内联渲染的规则全文（自包含，不依赖宿主嵌套 include，也不再受包路径特殊字符影响）；`routing/*.routing.md` 删除自我描述的启用/禁用/恢复流程文本，完整保留会话纪律（Karpathy/mattpocock 方法、测试与验证纪律、提交纪律），按需入口改为自然语言自动触发。
- 删除 `tests/hooks/`、`tests/init/`、`tests/e2e/test_zero_touch_flow.bats`；安装测试改为断言输出不再包含 hook 配置与 init 引导，能力文件保护用例改用 `ssf-review.md`。

## [2.2.2] - 2026-09-23

### Fixed

- 修复 2.2.0 引入的 Linux 回归：读取指令文件权限位时 `stat -f '%Lp' … || stat -c '%a' …` 串联在 GNU/Linux 上失效——GNU `stat -f` 是“文件系统”模式，会先把文件系统信息打印到 stdout 再非零退出，变量捕获到多行脏输出，随后 `chmod` 失败并中断脚本。表现为 GNU/Linux 上 `--append` 追加、卸载移除 include 后的权限恢复全部失败（macOS 的 BSD `stat` 行为不同，不受影响）。现在统一走 `file_mode()`：先试 GNU `-c '%a'`，失败才退回 BSD `-f '%Lp'`；测试断言改用可移植的 `ssf_file_mode()`。

## [2.2.1] - 2026-09-23

### Docs

- 回补 README 与 `docs/installation.md` 的 Antigravity 一句话安装示例，删除等待 2.2.0 落地的「未发布 / 需 `SUPERSPECFLOW_BRANCH=develop`」临时门控说明——2.2.0 发布后该说明在 master 上已属错误信息；README 补充更新方式（重复执行一句话安装即更新到 master 最新发布）与 CHANGELOG 链接。
- 发布策略与发布检查清单增加「文档回补」要求：发布前检查 README 与 `docs/` 中等待发布的临时说明，能兑现的改为正式表述、不能兑现的删除。

## [2.2.0] - 2026-09-23

### Added

- 支持 Antigravity 目标：`install-global.sh` 新增 `--antigravity-only` / `--all`，默认同时安装 Claude Code、Codex 与 Antigravity，`--both` 保持原有语义（仅 Claude Code 与 Codex）。skills 同步到 IDE `~/.gemini/config/skills/` 与 CLI `~/.gemini/antigravity-cli/skills/` 两个全局目录，include 行写入 `~/.gemini/GEMINI.md`，wrapper 与安装记录落在 `~/.gemini/superspecflow/`。
- `routing/GEMINI.routing.md` 与 `routing/GEMINI.global.md`：Antigravity 使用同一份默认路由，项目覆盖写 `.superspecflow/GEMINI.routing.md`；Antigravity 没有 `/ssf-init` 命令入口，恢复已禁用项目执行 `bash <pack>/scripts/_ssf_init_apply.sh`。
- 仓库根新增 `GEMINI.md` 入口，与 `AGENTS.md` / `CLAUDE.md` 同构并纳入 thin 与正文一致性校验。
- `docs/release-policy.md`：版本档位判定树、边界表、发布流程、回滚与历史不一致记录。
- `templates/release-checklist.md`：固定发布顺序（Unreleased 归档 → VERSION bump → develop 发布提交 → 合入 master → tag → 推送 → 回合并 develop）。
- `bootstrap.sh` 支持 `SUPERSPECFLOW_REPO` / `SUPERSPECFLOW_BRANCH` 注入并新增 `--help`；`update.sh` 按各宿主 `pack-root` 探测已安装范围，不再无条件扩容到全部宿主，其余参数透传。

### Fixed

- `install-global.sh` 的 include 已接入判定改为整行精确匹配，注释掉或含尾随空行的同一路径不再被误判为已接入。
- `install-global.sh` 渲染 wrapper 时对包路径做 sed 替换串转义，路径含 `&` 或 `#` 不再导致路径被破坏或安装中断。
- 追加/移除 include 后保持目标文件原权限；目标为符号链接时改写其指向的真实文件并保留软链，卸载不再删除用户 dotfiles 仓库中的真实文件。
- `uninstall-global.sh --purge` 改用物理路径比较与删除，经软链调用时不再只删软链却报告“已删除”。
- `bootstrap.sh` 更新前中止脏工作区（已跟踪文件有未提交改动时），不再静默 `reset --hard`；未跟踪文件（如 `.DS_Store`）不阻断更新。
- `_ssf_init_apply.sh` 对 `.superspecflow/disabled` 是目录等情况给出可读错误，不再暴露裸系统错误。
- `install-global.sh` 同步 skills 时跳过非目录项，包内混入杂项文件不再中断安装。
- `update.sh` 不再拒绝 `install-global.sh` 支持的参数。

### Docs

- `docs/installation.md`、`docs/compatibility.md`、`README.md` 补充 Antigravity 写入位置、目标选项语义、`~/.gemini/GEMINI.md` 与 Gemini CLI 共享说明，以及 `SUPERSPECFLOW_HOME` 仅用于 bootstrap 安装路径。
- `docs/release-policy.md` 记录 `v2.0.0` tag 指向 fix 提交、2.0 前发布措辞不同两处历史不一致。
- `NOTICE.md` 补充 karpathy 上游许可尽调：上游仓库未随附 LICENSE 文件，仅在 README 声明 MIT。
- `skills/ssf-plan`、`skills/ssf-build` 补充 `scripts/new-plan.sh` 与 `templates/implementation-plan.md`。
- Claude Code SessionStart hook 提示的 matcher 由 `startup` 扩展为 `startup|resume|clear|compact`（正则交替写法），并声明 Codex / Antigravity 无 hook 等价物的残余风险。

## [2.1.0] - 2026-09-22

### Added

- `scripts/install-global.sh` 新增 `--append`：目标全局指令文件已存在但缺少 include 行时，自动把 include 行插入文件顶部并保留原有全部内容与排版。卸载时由 `uninstall-global.sh` 的 `remove_include` 以整行精确匹配移除该行，不影响用户其他内容。

### Changed

- `--yes` 从占位参数变为实际生效：接受默认值且不弹出追加确认。
- 交互终端下未传 `--yes` 时会询问是否追加；非交互环境或 `--yes` 仍保持"不改写已有指令文件"的原有安全默认。
- README 与安装文档补充远端一句话安装与本地安装的传参示例。

## [2.0.1] - 2026-09-22

### Changed

- README 与安装文档把 `curl -fsSL .../scripts/bootstrap.sh | bash` 作为推荐的远端一句话安装方式清晰呈现，并与本地源码安装区分。
- 文档说明全局安装后默认对所有项目开启轻量自然语言路由，无需逐项目执行 init；需要单独禁用某项目时在其根目录放置 `.superspecflow/disabled`，恢复时运行 `/ssf-init`。该禁用与恢复机制在本版之前已由 `session-start-detect.sh` 和 `_ssf_init_apply.sh` 实现，本版补齐文档。

## [2.0.0] - 2026-09-22

破坏性变更：本版移除 OpenSpec / Superpowers 强依赖、旧命令别名、角色转接层和大部分模板，安装接入方式随之改变。升级前请确认没有依赖已移除的 `/ssf-*` 命令或模板路径。

### Removed

- 取消 OpenSpec 合同层与 Superpowers 执行纪律层强依赖：不再要求 change-id、Spec ID、规格映射、阶段签字、issue tracker、多 agent 或计划评审循环。
- 移除旧命令别名与角色转接层：`ssf-spec`、`ssf-karpathy`、`ssf-archive`、`ssf-retro`、`ssf-branch`、`ssf-commit`、`ssf-pr`、`ssf-map`、`ssf-decision` 及整个 `agents/` 目录。
- 模板从 56 个精简到 5 个：移除 `intake-gate`、`proposal`、`design`、`tasks`、`spec-to-code-map`、`acceptance-matrix`、`risk-matrix`、`qa-execution-plan`、`visual-comparison-report`、`git-hooks/commit-msg` 等旧流程产物。
- 移除 `validate-change-ledger.sh`、`validate-commit-message.sh`、`validate-qa-signoff.sh`、`install-project-symlinks.sh` 与 `new-change.sh`；commit 格式改由 routing 规则约束，不再随包分发机器校验 hook。
- 删除仓库内 `openspec/`、`engineering/`、`docs/research/` 历史记录，Git 历史仍可查阅。

### Added

- 新增 `/ssf-plan` 与 `scripts/new-plan.sh`：跨模块或跨会话工作只维护一份 `docs/plans/<topic>.md`；不覆盖已有文件，拒绝目录穿越与非法主题。
- 新增 `skills/ssf-build/references/karpathy.md`：编码前思考、简单优先、外科手术式修改、目标驱动执行；来源固定修订并在 NOTICE 记录。
- 新增可运行示例 `examples/add-membership-renewal-reminder`，含单文件计划与公开行为测试。
- 新增 `docs/branching-strategy.md`。

### Changed

- 默认流程改为明确任务直接执行，在会话内说明目标、边界和验收点；会话授权在同范围内持续有效。
- 入口规模：`commands/` 16 → 8，`skills/` 10 → 7，模板 56 → 5，测试 34 → 14。
- 体量：`routing/default.routing.md` 522 → 47 行，README 434 → 66 行，`scripts/validate-pack.sh` 1381 → 104 行。
- 按需适配 mattpocock/skills 的 TDD、缺陷定位和代码审查方法，固定修订 `c55ee46` 并按包分发上游 MIT 授权。
- commit / PR 标题改为 `<英文类型>(<英文范围>): <中文摘要>`，不再强制编号字段。
- 函数级注释要求收窄为"本次新增或行为、契约发生变化的函数"，仅格式调整不补注释。
- `check_commands` 同时校验反引号能力名与斜杠命令文件；`test.sh` 缺少 bats 时给出安装提示；`docs/compatibility.md` 补充 `python3` 依赖与 Superpowers 共存说明。

### Fixed

- 修复 `check_commands` 只覆盖 `/ssf-init` 的门禁退化，并为全部 8 个命令补充诊断测试。
- 删除孤儿模板、与模板字段不匹配的 QA signoff 校验器，以及失效的安装金丝雀。

## [1.2.2] - 2026-05-31

### Added

- Added install discoverability onboarding guidance: global install now tells users to restart Claude Code, run `/ssf-init` after commands are discoverable, and use terminal opt-in paths when slash commands are unavailable.
- Added onboarding contract tests for install output, `_ssf_init_apply.sh` output, README, installation docs, and `commands/ssf-init.md`.

### Changed

- Clarified Codex-only install guidance so it no longer implies Claude `/ssf-init` is available when Claude commands were not installed.
- Completed the comprehensive maintenance hardening batch: canonical routing source, README/install docs drift reduction, template usability guidance, test filtering, new-change scaffolding, validator diagnostics, and workflow evidence cleanup.

### Fixed

- Fixed test infrastructure portability under non-default `TMPDIR` and isolated artifact-path tests from the real repository root.
- Fixed the `scripts/test.sh` ShellCheck SC2295 warning in ROOT_DIR prefix removal and added a regression guard.

## [1.2.1] - 2026-05-30

### Changed

- Clarified the layer boundary: OpenSpec 合同层, Superpowers 执行纪律层, and SuperSpecFlow 路由与适配层.
- Replaced proprietary role-gate framing in runtime guidance with routing and stage-check language.
- Added routing input/output and Superpowers discipline traceability requirements.

### Fixed

- Fixed DeepSeek review hardening gaps: isolated `validate-pack` command diff temp files, removed user-specific root includes, added command contract tests, documented dependencies, moved PoC notes under `docs/research/`, added GitHub Actions validation with shellcheck, and refreshed change ledger status hygiene.
- Fixed CI commit-message validation under Linux locale by replacing locale-dependent CJK grep ranges with an `LC_ALL=C` non-ASCII text check.
- Prevented pack validation from requiring the superseded `SuperSpecFlow 角色门禁` wording.
- Preserved gstack source attribution while keeping runtime guidance free of gstack execution-style recommendations.

## [1.2.0] - 2026-05-30

### Added

- Added Visual UI QA protocol for Web and mini-program screenshot comparison, baseline lifecycle, visual comparison reports, and evidence paths.
- Added `visual-execution-plan.md` and `visual-comparison-report.md` templates.
- Added Visual UI QA contract tests and pack validation.

### Changed

- Updated `/ssf-qa`, `qa-gatekeeper`, routing, and README to describe visual QA states and protocol-only boundaries.
- Documented installation prerequisites, platform differences, documentation map, runtime path guidance, and license notes.

## [1.1.0] - 2026-05-30

### Added

- Added package version tracking with `VERSION` and `update.sh --version`.
- Added Browser/MCP QA execution plan, browser run report, evidence, and blocked signoff contracts.
- Added Spec cluster planning, status, integration gate templates, and parent ship gate rules.
- Added recursive bats test runner via `scripts/test.sh`.

### Changed

- Hardened global install and uninstall with generated wrappers, install manifests, and checksum ownership checks.
- Updated Git gates to reject local runtime artifacts including `docs/superpowers/`.

### Removed

- Removed tracked `docs/superpowers/` runtime documents from the package repository.
