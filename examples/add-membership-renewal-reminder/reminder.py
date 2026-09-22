"""会员中心续费提醒的展示判断；不访问网络、存储或系统时钟。"""
from datetime import datetime, timedelta, timezone
from typing import Optional


# 仅向未关闭本轮提醒且距到期剩余 (0, 7天] 的会员展示；缺到期时间则不展示。
# dismissed 由调用方按当前会员周期提供；比较用的时间必须带时区，否则抛 ValueError。
# 统一为 UTC 后按实际经过的 7×24 小时比较，避免本地时区或夏令时改变窗口长度。
def should_show_reminder(*, is_member: bool, dismissed: bool,
                         expires_at: Optional[datetime], now: datetime) -> bool:
    if not is_member or dismissed or expires_at is None:
        return False
    if expires_at.utcoffset() is None or now.utcoffset() is None:
        raise ValueError("提醒时间必须包含时区")
    remaining = expires_at.astimezone(timezone.utc) - now.astimezone(timezone.utc)
    return timedelta(0) < remaining <= timedelta(days=7)
