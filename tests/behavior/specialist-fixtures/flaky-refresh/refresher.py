import threading


# 后台刷新配置快照；version 每次成功刷新加一，value 为规范化后的条目列表。
class Refresher:
    def __init__(self, fetch):
        self._fetch = fetch
        self._lock = threading.Lock()
        self.version = 0
        self.value = None

    # 启动一次后台刷新并返回线程；fetch 抛错时保留旧快照。
    def refresh_async(self):
        thread = threading.Thread(target=self._run, daemon=True)
        thread.start()
        return thread

    # 拉取、登记新版本并写入规范化结果。
    def _run(self):
        try:
            raw = self._fetch()
        except Exception:
            return
        with self._lock:
            self.version += 1
        self.value = [item.strip().lower() for item in raw]

    # 读取当前版本号与值。
    def snapshot(self):
        with self._lock:
            return self.version, self.value
