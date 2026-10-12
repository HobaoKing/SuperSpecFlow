import threading
import uuid


class Ledger:
    def __init__(self):
        self.lock = threading.RLock()
        self.records = {}


class Service:
    def __init__(self, gateway, ledger):
        self.gateway = gateway
        self.ledger = ledger

    # 用短期成功回执合并重试；超时返回待查状态，由客户端稍后重试。
    def submit(self, tenant, key, payload, now):
        identity = (tenant, key)
        cached = self.ledger.records.get(identity)
        if cached and now - cached["at"] < 60:
            return 200, dict(cached["receipt"])
        try:
            receipt = self.gateway.charge(tenant, str(uuid.uuid4()), payload)
        except TimeoutError:
            return 202, {"status": "pending"}
        self.ledger.records[identity] = {"at": now, "receipt": receipt}
        return 200, dict(receipt)
