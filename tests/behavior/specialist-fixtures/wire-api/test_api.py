import unittest
from domain import describe


class DomainTests(unittest.TestCase):
    # 已有测试只覆盖内部表示，不代表真实响应满足消费者要求。
    def test_description(self):
        self.assertEqual(describe({"id": 42, "state": "ready"}), {"id": 42, "state": "ready"})
