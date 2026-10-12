# 账目回填

公开入口 `backfill.run(connection, tenant, batch_size=50, interrupt_after=None)`，无网络。
source 的 id 全局递增，不复用，金额为整数分（可为负数），eligible=1 才入 target。
本租户 target 最终必须恰好包含每个合格 source_id 一次，并保持 amount；其他租户不变。
目标库可能存在旧版的重复或遗漏（即使总行数等于源行数），修复也应收敛到上述关系。
checkpoint 是已完整处理的源 id 水位，不能把分页偏移量当作 id；后续新增源记录要能继续补入。
每次从 source 读取不得超过 batch_size，不允许一次读全源表；可以使用数据库集合操作对账，不能因提速忽略权限筛选。
interrupt_after 表示完成指定数量的批次写入后抛出 InterruptedError，模拟中断；之后相同连接或重新连接同一数据库再次运行应可恢复，无重复/漏项。
store.py 定义 schema 与最小示例，不得改 source 数据或取消故障注入来令测试通过。
