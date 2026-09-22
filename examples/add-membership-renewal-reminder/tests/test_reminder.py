import unittest
from datetime import datetime, timezone, timedelta
from reminder import should_show_reminder


class ReminderTests(unittest.TestCase):
    # 固定时钟保证边界结果可重复，不依赖机器日期或时区。
    def setUp(self):
        self.now = datetime(2026, 9, 22, 12, tzinfo=timezone.utc)

    # 未到期且剩余不超过七个完整日才提醒，包含七日边界。
    def test_expiry_window(self):
        cases = [
            (datetime(2026, 9, 21, 12, tzinfo=timezone.utc), False),
            (datetime(2026, 9, 22, 12, tzinfo=timezone.utc), False),
            (datetime(2026, 9, 22, 12, 0, 1, tzinfo=timezone.utc), True),
            (datetime(2026, 9, 25, 12, tzinfo=timezone.utc), True),
            (datetime(2026, 9, 29, 12, tzinfo=timezone.utc), True),
            (datetime(2026, 9, 29, 12, 0, 1, tzinfo=timezone.utc), False),
        ]
        for expires_at, expected in cases:
            with self.subTest(expires_at=expires_at):
                self.assertEqual(should_show_reminder(
                    is_member=True, dismissed=False,
                    expires_at=expires_at, now=self.now), expected)

    # 非会员或已关闭本轮提醒时，不能被再次提醒。
    def test_membership_and_dismissal(self):
        for is_member, dismissed in [(False, False), (True, True), (False, True)]:
            with self.subTest(is_member=is_member, dismissed=dismissed):
                self.assertFalse(should_show_reminder(
                    is_member=is_member, dismissed=dismissed,
                    expires_at=datetime(2026, 9, 23, 12, tzinfo=timezone.utc),
                    now=self.now))

    # 缺少到期时间时不猜测会员期限。
    def test_missing_expiration(self):
        self.assertFalse(should_show_reminder(
            is_member=True, dismissed=False, expires_at=None, now=self.now))

    # 不同时区表达同一时刻，应得到相同边界结果。
    def test_different_timezone(self):
        self.assertTrue(should_show_reminder(
            is_member=True, dismissed=False,
            expires_at=datetime(2026, 9, 29, 20,
                                tzinfo=timezone(timedelta(hours=8))),
            now=self.now))

    # 缺少时区时拒绝隐式使用机器本地时间。
    def test_naive_datetime_is_rejected(self):
        aware_expiry = datetime(2026, 9, 23, 12, tzinfo=timezone.utc)
        for expires_at, now in [
            (aware_expiry.replace(tzinfo=None), self.now),
            (aware_expiry, self.now.replace(tzinfo=None)),
        ]:
            with self.subTest(expires_at=expires_at, now=now):
                with self.assertRaises(ValueError):
                    should_show_reminder(is_member=True, dismissed=False,
                                         expires_at=expires_at, now=now)


if __name__ == "__main__":
    unittest.main()
