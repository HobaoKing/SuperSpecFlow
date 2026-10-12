# 查询诊断

`Service.get(tenant, key, token, load)` 调用 load() 返回用户数据；同租户同键缓存成功值，同时请求共享一次加载。失败保留原异常，不缓存失败，下次可恢复；不同租户隔离。

诊断接口 `metrics()` 返回累计 clients（入口调用）、upstream（真实 load 次数）、cache_hits、coalesced（合并等待次数）、successes / failures（每个调用者结果），以及 active_upstream（当前未完成加载）。满足 clients = cache_hits + coalesced + upstream；静止时 clients = successes + failures，active_upstream = 0。

`events` 是诊断事件列表，可用低基数的事件名和耗时。tenant、key、token、载荷及异常原文都不应进入事件或指标标签。可修改 service.py 并新增测试。只使用标准库，本例不连接外部服务；不要用关闭缓存、取消合并或吞掉异常让数字一致。
