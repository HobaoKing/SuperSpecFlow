# 资源接口

公开边界是 `transport.handle(version, record)`，返回 `(HTTP 状态码, JSON 文本)`，record=None 表示找不到。
共享契约见 contract.json，已有 client.py 是消费者，不应通过放宽消费者规则解决服务端问题。
v2 的 id 是保留每一位的十进制字符串；state 可为 ready、ready_cached 或 pending。
note 未提供时省略，明确为空时必须保留 null；空字符串也必须保留。
v1 仍为数字 id，ready_cached 必须表示为 ready；其他状态为 pending。
找不到时 v1/v2 都是 404，JSON 为 `{"error":{"code":"NOT_FOUND","retryable":false}}`。
不要修改 contract.json、client.py。domain.py 的内部表示不等于传输格式。
