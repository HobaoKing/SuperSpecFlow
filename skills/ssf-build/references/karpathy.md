# Karpathy 编码纪律

适配自 [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) 的核心思想，作为 AI 编码行为的底层工程约束：

1. **Think Before Coding（编码前先想清楚）**
   - 暴露假设与困惑，不擅自脑补或掩盖歧义；遇到可推断问题自主推进，不可推断的业务语义取舍向用户明确。
   - 思考是否存在更简单的方案，寻找最小阻力路径。

2. **Simplicity First（简单优先）**
   - 追求满足当前需求的最小实现。
   - 不为假想复用或未来场景增加抽象、配置和扩展点。单次使用通常内联；为建立必要测试边界或显著改善复杂逻辑可读性，可以提取函数。
   - 根据职责和实际复杂度判断方案，不把行数作为质量门禁。

3. **Surgical Changes（外科手术式修改）**
   - 只修改与当前任务直接相关的代码行。
   - 不顺手重构无关代码，不改动无关文件的格式或命名。
   - 严格遵循项目现有代码风格和架构约定。

4. **Goal-Driven Execution（目标驱动执行）**
   - 把任务改写为可验证的结果（如先写失败用例，再实现并跑通验证）。
   - 根据任务选择测试、静态检查或实际运行验证，并检查真实 diff；低风险文档或格式修改不强制新增测试。环境受限时说明验证缺口，不把未运行写成通过。

来源：[multica-ai/andrej-karpathy-skills README](https://github.com/multica-ai/andrej-karpathy-skills/blob/2c606141936f1eeef17fa3043a72095b4765b9c2/README.md)，修订 `2c606141936f1eeef17fa3043a72095b4765b9c2`。本地为原则的中文概括，按项目约定允许必要的测试和可读性提取，不是上游规则的逐字翻译。
