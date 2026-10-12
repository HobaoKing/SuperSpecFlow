class Dispatcher:
    def __init__(self, capacity=6):
        self.capacity = capacity
        self.pending = {}
        self.results = {}

    # 当前入口记录请求，调用方根据返回值判断是否需要稍后再次提交。
    def submit(self, key, payload, now):
        self.pending[key] = {"payload": payload, "due": now, "attempts": 0}
        return True

    # 每轮处理队首，成功后交付原始网关结果。
    def tick(self, now, gateway):
        for key, job in list(self.pending.items())[:2]:
            status, body, retry_after = gateway.send(key, job["payload"], now)
            job["attempts"] += 1
            if 200 <= status < 300:
                self.results[key] = (status, body)
                del self.pending[key]

    # 当前仅标记取消，实际清理由派发阶段负责。
    def cancel(self, key):
        if key not in self.pending:
            return False
        self.pending[key]["cancelled"] = True
        return True
