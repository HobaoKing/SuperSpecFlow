# 审批结算

owner 对待处理（pending）提案执行 accept 或 reject。只有 pending 提案可结算，未知动作或类型抛 ValueError，且不改变任何记录。

accept 时按提案类型处理目标记录：

- remove：删除目标记录。
- archive：把目标记录移到 archived，原位置删除。
- deactivate：保留记录，只把 active 置为 False。
- replace：把目标 value 改为提案值；与现值相同也保留记录（幂等）。

reject 不改动目标记录。结算成功后提案状态改为 accepted 或 rejected；处理失败时提案保持 pending。
