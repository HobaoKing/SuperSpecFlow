# 离线任务队列

`worker.settings()` 决定并发度，`simulator.run(jobs, settings)` 是固定时钟的离线容量模型。tick 是逻辑时间单位，不是真实毫秒。
下游允许最多 4 个同时执行的任务；不能提高此上限、丢弃任务、修改 arrival/duration 或统计口径。
用户等待从 arrival 开始直到任务完成，单项 service 是开始到完成。
steady 和 burst 是必须覆盖的两类输入。稳态输入结束后剩余任务必须排空，结果中每个 id 恰好一次。
只允许修改 worker.py 和新增相关测试；simulator.py、workloads.py、measure.py 是固定测量入口。
运行 `python3 -B measure.py` 可获得这两类输入的原始结果；需要选择真正反映用户问题的指标。
