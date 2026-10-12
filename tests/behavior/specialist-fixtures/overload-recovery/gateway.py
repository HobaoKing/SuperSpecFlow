class Gateway:
    def __init__(self, recover_at=5):
        self.recover_at = recover_at
        self.calls = []
        self.effects = {}
        self.lost = set()

    # 模拟限流、永久拒绝和成功后丢响应；业务效果按原请求键幂等。
    def send(self, key, payload, now):
        self.calls.append((key, payload, now))
        if payload == "invalid":
            return 400, "invalid", 0
        if now < self.recover_at:
            return 429, "busy", 3
        self.effects.setdefault(key, "receipt:" + key)
        if payload == "lose-response" and key not in self.lost:
            self.lost.add(key)
            return 503, "unknown", 0
        return 200, self.effects[key], 0
