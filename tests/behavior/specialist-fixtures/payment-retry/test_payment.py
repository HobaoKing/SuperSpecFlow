import unittest
from gateway import Gateway
from service import Ledger, Service


class PaymentTests(unittest.TestCase):
    # 常规立即重试沿用回执，原测试未覆盖响应丢失或长时间重投递。
    def test_immediate_retry(self):
        gateway = Gateway()
        service = Service(gateway, Ledger())
        first = service.submit("a", "checkout", {"amount": 300, "currency": "CNY"}, 0)
        self.assertEqual(service.submit("a", "checkout", {"amount": 300, "currency": "CNY"}, 1), first)
        self.assertEqual(len(gateway.effects), 1)
