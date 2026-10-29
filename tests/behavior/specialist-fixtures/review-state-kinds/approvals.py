# 内存存储：records 为 id -> {"value", "active"}，proposals 为 id -> {"kind", "target", "value", "status"}。
class Store:
    def __init__(self):
        self.records = {}
        self.proposals = {}


# owner 结算一条待处理提案；按类型改动目标记录，处理成功后才更新提案状态。
def settle(store, proposal_id, action):
    proposal = store.proposals[proposal_id]
    if proposal["status"] != "pending":
        raise ValueError("proposal already settled")
    if action == "reject":
        proposal["status"] = "rejected"
        return
    if action != "accept":
        raise ValueError("unknown action: " + str(action))
    kind, target = proposal["kind"], proposal["target"]
    if kind == "remove":
        del store.records[target]
    elif kind == "deactivate":
        store.records[target]["active"] = False
    elif kind == "replace":
        store.records[target]["value"] = proposal["value"]
    else:
        raise ValueError("unknown kind: " + str(kind))
    proposal["status"] = "accepted"
