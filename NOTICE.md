# 来源与授权

SuperSpecFlow 使用 MIT License，见 `LICENSE`。

当前实现与审查方法适配自 [mattpocock/skills](https://github.com/mattpocock/skills)，固定修订 `c55ee46073ed923f86ce59a5eb3b6d895095d1b7`：

- `skills/engineering/tdd/SKILL.md` → `skills/ssf-build/references/tdd.md`
- `skills/engineering/diagnosing-bugs/SKILL.md` → `skills/ssf-build/references/diagnosing-bugs.md`
- `skills/engineering/code-review/SKILL.md` → `skills/ssf-review/references/code-review.md`

Copyright (c) 2026 Matt Pocock。完整上游 MIT 授权随两个参考目录的 `mattpocock-LICENSE.txt` 分发。本地版为中文精简适配，保留方法，取消逐项测试审批、强制双 agent、issue tracker 和自动提交；不是完整上游安装或自动更新。

底层编码行为与工程纪律适配自 [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills)：

- Think Before Coding（编码前思考）
- Simplicity First（简单优先）
- Surgical Changes（外科手术式修改）
- Goal-Driven Execution（目标驱动执行）

对应参考见 `skills/ssf-build/references/karpathy.md`，来源固定为修订 `2c606141936f1eeef17fa3043a72095b4765b9c2` 的 README。本地为原则的中文概括，允许必要的测试边界与可读性提取，不是逐字复制，不要求独立命令。

上游该仓库未随附 LICENSE 文件，仅在 README 的 License 一节声明 MIT；本包据该声明进行适配与再分发，并在本文件保留来源、固定修订与改动说明。若上游后续补充或变更许可，请以更严格的条款为准并更新本文件。

## 工程方法补充参考（2026-10-10）

以下是本次独立编写方法指导时阅读的固定版本。新增指导基于本项目的领域与授权约定重新组织，未复制上游脚本、正文或整包工作流；原有 Matt Pocock 适配参考和随附授权继续保留。各参考文件末尾提供所用具体技能的固定链接，便于核对来源与本地取舍。

| 上游与固定修订 | 阅读的具体技能 | 本地采用位置与方法 |
|---|---|---|
| [obra/superpowers](https://github.com/obra/superpowers/tree/bb92a77741419a4ab5f06e711a283343f1ada0c3) | brainstorming、writing-plans、systematic-debugging、verification-before-completion、receiving-code-review | think 的场景澄清；plan 的任务完整性自检；build 的边界取证与假设检验；QA/ship 的证据对应；review 的反馈核实 |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills/tree/1be8e34187e34647bb83adc3a1323b26ae6f6abe) | incremental-implementation、api-and-interface-design、shipping-and-launch、code-simplification | plan/build 的可验证小步与契约追踪；git 的行为完整提交；ship 的兼容、恢复与观测；删除前查兼容动机与副作用顺序 |
| [garrytan/gstack](https://github.com/garrytan/gstack/tree/20eb6202fa8ea83a882e7c0463b722cd8a31af1e) | office-hours、plan-eng-review、review/checklist、qa、qa/sections/system-functional | think 的前提审视与方案比较；review 的高影响风险及误报反证；build/QA 的回归价值、原始旅程、持久终态与无副作用核验 |
| [affaan-m/ECC](https://github.com/affaan-m/ECC/tree/4eb71d92a39cab44ad40ac9d8a6a5ccb4029d6c2) | search-first、verification-loop、iterative-retrieval | build 的先复用再自建、按实际证据缺口收敛检索；QA 的分层检查与证据边界 |
| [mattpocock/skills](https://github.com/mattpocock/skills/tree/49dd158d1076134a641b33efb035946536778336) | skills/engineering/tdd、skills/engineering/code-review、skills/engineering/codebase-design | 公开行为测试、逐项红绿与需求/规范两个审查视角；删除抽象前判断复杂性是否转嫁调用方 |

未采用上游的固定阶段审批、逐项测试确认、强制多 agent、默认自动提交、强制全量构建、遥测或跨会话自动学习。方法参考不会扩大用户授权，也不覆盖宿主构建和运行限制。
