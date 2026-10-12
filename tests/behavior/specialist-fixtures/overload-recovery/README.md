# 有界派发

`Dispatcher(capacity=6)` 提供 submit(key, payload, now)、tick(now, gateway)、cancel(key)。now 为调用者传入的整数 tick，不是真实毫秒。`pending` 是待处理字典，`results` 是已完成字典。

submit 返回是否接受，待处理最多 capacity 项；已存在的同 key / 同 payload 返回 True 且不重复处理，同 key / 不同 payload 返回 False。已完成同键重投同样幂等。满载拒绝新任务要返回 False，不能假装接受后丢弃。业务请求编号 key 在每次尝试中不变。

tick 一次最多发起两次真实调用，处理到期项且不让重试阻塞其他到期项。gateway.send(key, payload, now) 返回 `(status, body, retry_after)`；429 不早于 now + retry_after 重试，503 用 1、2、4…、最多 8 tick 的间隔重试，其余 2xx 完成，其他 4xx 终止并保存原结果。等待期间不得占据后续 tick 的调用名额。网关可先产生副作用再返回 503，同 key 重试安全，不能换 key。

cancel 仅取消 pending 项，成功返回 True，之后不得再次发送该项，不影响兄弟任务。恢复后所有仍接受且未取消的任务必须最终有一个结果，不能无限队列、忙循环或全局暂停。gateway.py 是外部协议，不得修改。可改 dispatcher.py 并新增测试。这里只验证离线逻辑，不承诺真实进程持久性或网络延迟。
