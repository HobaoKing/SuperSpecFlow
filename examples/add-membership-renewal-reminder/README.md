# 示例：会员续费提醒

一个小功能只需要明确目标、实现和有效验证。本示例包含四个文件：

- [一份计划](docs/plans/add-membership-renewal-reminder.md)：目标、边界、任务、验收和实际验证结果。
- [最小实现](reminder.py)：判断当前会员是否应该看到提醒。
- [单测文件](tests/test_reminder.py)：直接测试公开行为和时间边界。
- 本说明：运行方式和提交消息示例。

无需第三方库，Python 3.8+ 即可。从仓库根目录运行：

```bash
cd examples/add-membership-renewal-reminder
python3 -B -m unittest discover -s tests -v
```

开发时先选一个行为写失败测试，再做最小实现并验证，随后补充下一个边界；结束时检查 diff。普通任务可直接在会话对齐，本例的计划文件用于展示需要留存时如何保持简短。

提交消息示例（仅示例，不会自动提交）：

```text
feat(membership): 增加到期前七天的续费提醒判断

支持会员期限、本轮关闭状态和带时区的到期边界判断。
验证：5 个单测方法通过，覆盖时间边界及不应展示的场景。
范围：仅展示判断，未接入 UI、存储、埋点或推送。
```

这里没有模拟 UI 通过、发布成功或完整会员能力已交付。
