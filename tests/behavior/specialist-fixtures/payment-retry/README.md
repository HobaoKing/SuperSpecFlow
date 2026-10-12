# 支付重试

公开入口 `Service(gateway, ledger).submit(tenant, key, payload, now)` 返回 `(状态码, 内容)`。
payload 包含整数分 amount 和大写三字母 currency。相同 tenant/key 是一次业务意图，载荷字段顺序不影响一致性。
首次成功 200；七天重试窗口内同载荷返回原 receipt，换载荷必须 409 且不产生新扣款，不同 tenant 互不影响。
七天内包括 Service 实例重新创建及并发请求，效果至多一次。第八天起允许清理记录，不要求自动清理或键复用。
网关响应超时可能已扣款：本次可返回 202，重试必须查明或安全收敛为原成功，不能换一次新业务意图扣款。
ledger 是多 Service 共享的 Ledger；gateway 的公开能力见 gateway.py。可改 service.py，不得改网关语义或靠串行测试回避并发。
now 是服务端秒数，由测试传入。这里没有真实支付服务；Ledger 和 Gateway 是共享内存对象，此项目不承诺真实进程崩溃后的磁盘持久化。
