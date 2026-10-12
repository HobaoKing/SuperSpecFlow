import json


# 按合作方现有契约解析真实 JSON，拒绝丢失精度风险的数字 id。
def consume(status, text):
    body = json.loads(text)
    if status == 404:
        assert body == {"error": {"code": "NOT_FOUND", "retryable": False}}
    else:
        assert isinstance(body["id"], str) and body["id"].isdigit()
        assert body["state"] in ("ready", "ready_cached", "pending")
    return body
