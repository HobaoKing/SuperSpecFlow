import unittest
from quota import can_download


class QuotaTests(unittest.TestCase):
    # 将原正数、零、负数覆盖合并为参数化测试，保持所有行为断言。
    def test_values(self):
        for remaining, expected in ((1, True), (0, False), (-1, False)):
            with self.subTest(remaining=remaining):
                self.assertEqual(can_download(remaining), expected)
