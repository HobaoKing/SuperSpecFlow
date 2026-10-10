# 实现策略

用于新能力、接口改动、跨层实现、依赖选择或重构。先缩小需要改变的行为，再选择足够的工程手段。

## 先找已有能力

按领域词汇搜索现有入口、相似正常流程、公共工具和测试；确认看似可复用的代码是否确实承载相同规则。先考虑复用项目能力或已安装依赖，再考虑小范围扩展或自行实现。

检索围绕尚缺的事实收敛：先用入口或报错找候选，再用实际符号和调用关系补缺。没有命中先核对项目词汇，不立即断言能力不存在；已确认入口、规则归属、调用方和验证边界就进入实现，仅在新证据暴露缺口时扩展，不反复整仓扫描。

只有现有方案不足且外部能力会实质影响选择时才查官方文档或候选项目，核实安装版本的实际接口与限制。比较依赖成本、维护状态、兼容性和许可证要求；查到某库不等于已获安装、付费或外传授权。不要为了几个简单分支引入庞大依赖，也不要为每个小修复做全网调研。

## 把契约落实到调用链

改变接口或共享规则前，核对输入的空值、缺省值、单位、有效范围，输出的状态与错误语义，以及谁负责副作用和失败恢复。复用项目已有类型、错误模型、校验与事务边界，不自建第二套体系。

沿调用方检查兼容性：新枚举值是否影响存储、过滤、展示与历史数据；字段从可选改为必填是否破坏旧调用；错误改成空结果是否让调用方误判成功。仅类型检查通过不足以证明这些语义一致。

对会重试或异步完成的操作，明确一个业务意图怎样标识、何时算完成、哪些资源需要释放、过期响应属于哪次请求。服务端已完成但客户端超时属于结果未知，先查证状态；不能直接生成新意图再重试，也不能把重复完成当成第二次授权。

## 逐步形成完整行为

先贯通一个最小有效路径并验证，再增加必要负向路径和其他入口。每步覆盖当前承诺的行为，不积攒大量未验证改动。共享状态的更新应在同一契约下考虑成功、失败、取消和重复到达，不靠界面禁用按钮替代服务端约束。

重构前确认要保留的输出、错误语义与副作用顺序，用同一输入比较前后行为。删除看似冗余的分支或包装前，查调用方、兼容约束，必要时查提交历史：删掉后复杂性会消失，还是转移并重复到多个调用方？后者可能正在封装真实规则。局部未搜到调用不足以证明公开接口、动态入口或兼容分支可删。

只有真实复用、关键测试边界或复杂代码可读性需要时才抽取函数；让调用方少知道内部顺序和配置，不只把复杂性搬到新包装层，也不为了 mock 私有函数增加生产接口。遵循项目词汇，不移植上游术语或按行数判断抽象价值。

完成时将实际改动逐项对应目标。静态、测试与运行证据分别支持各自结论；验证后又改到相关路径，该部分证据需要更新。与改动无关且仍有效的结果继续复用。

方法参考：[ECC search-first](https://github.com/affaan-m/ECC/blob/4eb71d92a39cab44ad40ac9d8a6a5ccb4029d6c2/skills/search-first/SKILL.md)、[agent-skills incremental-implementation](https://github.com/addyosmani/agent-skills/blob/1be8e34187e34647bb83adc3a1323b26ae6f6abe/skills/incremental-implementation/SKILL.md) 与 [api-and-interface-design](https://github.com/addyosmani/agent-skills/blob/1be8e34187e34647bb83adc3a1323b26ae6f6abe/skills/api-and-interface-design/SKILL.md)。本文独立编写，保留选择与验证方法，不引入默认安装、自动提交或强制构建。

补充借鉴 [ECC iterative-retrieval](https://github.com/affaan-m/ECC/blob/4eb71d92a39cab44ad40ac9d8a6a5ccb4029d6c2/skills/iterative-retrieval/SKILL.md) 的按缺口收敛、[agent-skills code-simplification](https://github.com/addyosmani/agent-skills/blob/1be8e34187e34647bb83adc3a1323b26ae6f6abe/skills/code-simplification/SKILL.md) 的删除前理解与行为保持、[Matt Pocock codebase-design](https://github.com/mattpocock/skills/blob/49dd158d1076134a641b33efb035946536778336/skills/engineering/codebase-design/SKILL.md) 的调用方复杂性判断。不限固定检索轮数，不要求分拆 PR 或新建接口。
