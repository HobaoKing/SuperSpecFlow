import threading


class Conflict(Exception):
    pass


class Gateway:
    def __init__(self):
        self.lock = threading.Lock()
        self.effects = {}
        self.calls = 0
        self.lose_next_response = False

    # 同租户同 operation 原子去重，异载荷拒绝；丢失响应只在效果已持久化后注入。
    def charge(self, tenant, operation, payload):
        with self.lock:
            self.calls += 1
            identity = (tenant, operation)
            if identity in self.effects:
                previous = self.effects[identity]
                if previous["payload"] != payload:
                    raise Conflict("operation payload changed")
                return dict(previous["receipt"])
            receipt = {"receipt": f"r-{len(self.effects) + 1}", "amount": payload["amount"]}
            self.effects[identity] = {"payload": dict(payload), "receipt": receipt}
            if self.lose_next_response:
                self.lose_next_response = False
                raise TimeoutError("response lost after commit")
            return dict(receipt)

    # 返回已经落地的载荷与回执，未找到则 None；查询不会发起扣款。
    def lookup(self, tenant, operation):
        with self.lock:
            result = self.effects.get((tenant, operation))
            return None if result is None else {"payload": dict(result["payload"]), "receipt": dict(result["receipt"])}
