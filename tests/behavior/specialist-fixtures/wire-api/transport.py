import json
from domain import describe


# 将资源对象输出到旧版或当前接口；不存在时返回可解析的错误响应。
def handle(version, record):
    if record is None:
        return 404, json.dumps({"error": "NOT_FOUND"})
    body = describe(record)
    if version == "v1":
        body["state"] = "ready" if body["state"] == "ready" else "pending"
    body = {key: value for key, value in body.items() if value is not None}
    return 200, json.dumps(body)
