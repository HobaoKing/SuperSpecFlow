import time
import unittest
from refresher import Refresher


class RefresherTests(unittest.TestCase):
    # 异步刷新完成后应能读到递增后的版本号与规范化条目列表。
    def test_refresh_publishes_new_snapshot(self):
        refresher = Refresher(lambda: ["B ", " a"])
        refresher.refresh_async()
        time.sleep(0.01)
        self.assertEqual(refresher.snapshot(), (1, ["b", "a"]))

    # 拉取失败时不应递增版本号或覆盖已有快照。
    def test_failed_fetch_keeps_snapshot(self):
        # 构造固定抛出网络异常的拉取替身。
        def unavailable():
            raise OSError("config service down")
        refresher = Refresher(unavailable)
        refresher.refresh_async().join()
        self.assertEqual(refresher.snapshot(), (0, None))
