import unittest
from worker import settings
from simulator import run


class WorkerTests(unittest.TestCase):
    # 单个任务的服务成本保持不变，不能代表负载持续到达时的总等待。
    def test_one_job(self):
        result = run([{"id": 1, "arrival": 0, "duration": 1}], settings())
        self.assertEqual(result["metrics"]["service_median"], 1)
