import unittest
from approvals import Store, settle


# 构造一条目标记录和一条待处理提案。
def pending(kind, value=None):
    store = Store()
    store.records["r1"] = {"value": "old", "active": True}
    store.proposals["p1"] = {"kind": kind, "target": "r1", "value": value, "status": "pending"}
    return store


class SettleTests(unittest.TestCase):
    # 接受 remove 提案应移除目标记录并标记提案为 accepted。
    def test_accept_remove_deletes_record(self):
        store = pending("remove")
        settle(store, "p1", "accept")
        self.assertNotIn("r1", store.records)
        self.assertEqual(store.proposals["p1"]["status"], "accepted")

    # 拒绝提案不应改动目标记录，仅将提案状态置为 rejected。
    def test_reject_keeps_record(self):
        store = pending("remove")
        settle(store, "p1", "reject")
        self.assertEqual(store.records["r1"], {"value": "old", "active": True})
        self.assertEqual(store.proposals["p1"]["status"], "rejected")

    # 已结算提案再次执行任何动作都必须抛出 ValueError。
    def test_settled_proposal_cannot_settle_again(self):
        store = pending("remove")
        settle(store, "p1", "accept")
        with self.assertRaises(ValueError):
            settle(store, "p1", "reject")
