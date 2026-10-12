import unittest
from quota import can_download


class QuotaTests(unittest.TestCase):
    # 正额度应允许下载。
    def test_positive(self):
        self.assertTrue(can_download(1))

    # 零和负额度都应拒绝下载。
    def test_denied(self):
        self.assertFalse(can_download(0))
        self.assertFalse(can_download(-1))
