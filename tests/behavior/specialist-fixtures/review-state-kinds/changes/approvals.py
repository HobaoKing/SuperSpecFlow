# 内存存储：records 为 id -> {"value", "active"}，archived 保存归档记录，proposals 为 id -> {"kind", "target", "value", "status"}。
class Store:
    def __init__(self):
        self.records = {}
        self.archived = {}
        self.proposals = {}


# 从当前记录中移除目标。
def _drop_target(store, proposal):
    store.records.pop(proposal["target"])


# 归档：先保存副本再移除。
def _archive_target(store, proposal):
    store.archived[proposal["target"]] = dict(store.records[proposal["target"]])
    _drop_target(store, proposal)


# 写入新值；与现值相同说明是重复提案，按清理处理。
def _write_value(store, proposal):
    record = store.records[proposal["target"]]
    if record["value"] == proposal["value"]:
        _drop_target(store, proposal)
        return
    record["value"] = proposal["value"]


# 会改动目标记录的类型及其处理函数；新增类型只需在此登记。
_HANDLERS = {
    "remove": _drop_target,
    "archive": _archive_target,
    "deactivate": _drop_target,
    "replace": _write_value,
}


# owner 结算一条待处理提案；按类型分派处理函数，处理成功后才更新提案状态。
def settle(store, proposal_id, action):
    proposal = store.proposals[proposal_id]
    if proposal["status"] != "pending":
        raise ValueError("proposal already settled")
    if action == "reject":
        proposal["status"] = "rejected"
        return
    if action != "accept":
        raise ValueError("unknown action: " + str(action))
    handler = _HANDLERS.get(proposal["kind"])
    if handler is None:
        raise ValueError("unknown kind: " + str(proposal["kind"]))
    handler(store, proposal)
    proposal["status"] = "accepted"
