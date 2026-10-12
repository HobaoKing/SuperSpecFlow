"""仅在随机回环端口提供隔离浏览器夹具；无外部请求或真实用户数据。"""
import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from threading import Lock
from urllib.parse import parse_qs, urlparse

ROOT = Path(__file__).parent
LOCK = Lock()
STATE = {"restricted": False, "member": False}


# 在同一临界区内保存测试状态和事件，避免并行请求导致证据交错或损坏。
def record(event):
    with LOCK:
        runtime = ROOT / "runtime"
        runtime.mkdir(exist_ok=True)
        (runtime / "state.json").write_text(json.dumps(STATE))
        with (runtime / "events.jsonl").open("a") as stream:
            stream.write(json.dumps(event) + "\n")


class Handler(BaseHTTPRequestHandler):
    # 输出 JSON 并禁止缓存，保证刷新时从当前服务端读取状态。
    def send_json(self, body, status=200):
        payload = json.dumps(body).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    # 仅提供页面和两个测试账号的状态；未知账号或路径明确拒绝。
    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path == "/":
            payload = (ROOT / "index.html").read_bytes()
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(payload)))
            self.end_headers()
            self.wfile.write(payload)
        elif parsed.path == "/api/settings":
            account = parse_qs(parsed.query).get("account", [""])[0]
            if account not in STATE:
                self.send_json({"error": "unknown account"}, 400)
                return
            body = {"account": account, "enabled": STATE[account]}
            record({"method": "GET", "body": body})
            self.send_json(body)
        else:
            self.send_json({"error": "not found"}, 404)

    # 成员保存持久状态；受限账号返回 HTTP 200 业务拒绝且不修改任何账号。
    def do_POST(self):
        if self.path != "/api/settings":
            self.send_json({"error": "not found"}, 404)
            return
        try:
            request = json.loads(self.rfile.read(int(self.headers.get("Content-Length", "0"))))
            account = request["account"]
            if account not in STATE or type(request["enabled"]) is not bool:
                raise ValueError("invalid setting")
        except (ValueError, KeyError, TypeError):
            self.send_json({"error": "invalid request"}, 400)
            return
        if account == "restricted":
            body = {"ok": False, "code": "PERMISSION_DENIED"}
        else:
            with LOCK:
                STATE[account] = request["enabled"]
            body = {"ok": True}
        record({"method": "POST", "request": request, "http_status": 200, "body": body})
        self.send_json(body)

    # 测试证据统一写入 events.jsonl，避免默认 HTTP 日志产生无关终端噪声。
    def log_message(self, format, *args):
        pass


if __name__ == "__main__":
    record({"event": "start", "revision": "browser-fixture-1"})
    server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
    print(f"http://127.0.0.1:{server.server_port}/", flush=True)
    server.serve_forever()
