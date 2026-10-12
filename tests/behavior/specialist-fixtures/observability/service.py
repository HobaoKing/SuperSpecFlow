from concurrent.futures import Future
import threading


class Service:
    def __init__(self):
        self._lock = threading.Lock()
        self._cache = {}
        self._pending = {}
        self._counts = dict.fromkeys(("clients", "upstream", "cache_hits", "coalesced",
                                     "successes", "failures", "active_upstream"), 0)
        self.events = []

    # 返回副本用于面板读取，避免面板直接改写内部计数。
    def metrics(self):
        with self._lock:
            return dict(self._counts)

    # 成功结果按租户和键缓存，失败保留异常；同时加载通过 Future 合并。
    def get(self, tenant, key, token, load):
        identity = (tenant, key)
        with self._lock:
            self._counts["clients"] += 1
            self._counts["upstream"] += 1
            if identity in self._cache:
                return self._cache[identity]
            owner = identity not in self._pending
            if owner:
                self._pending[identity] = Future()
            pending = self._pending[identity]
        if not owner:
            return pending.result()
        try:
            result = load()
            with self._lock:
                self._cache[identity] = result
            pending.set_result(result)
            return result
        except Exception as error:
            self.events.append({"error": str(error), "tenant": tenant, "key": key, "token": token})
            pending.set_exception(error)
            raise
        finally:
            with self._lock:
                self._pending.pop(identity)
