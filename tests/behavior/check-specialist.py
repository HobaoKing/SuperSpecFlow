#!/usr/bin/env python3
"""评估者对公开行为做独立核验；不将此文件复制给执行模型。"""
import argparse
import concurrent.futures
import json
from pathlib import Path
import sys
import tempfile
import threading
import time


# 检查清单独立于候选程序返回的数据，少跑、空跑或无布尔结论都不能通过。
def expected_checks(case):
    return {
        "wire-api": {
            *(f"v2/{ident}/{state}/{note}" for ident in (0, 42, 9007199254740993, 9223372036854775807)
              for state in ("ready", "ready_cached", "pending") for note in ("absent", None, "")),
            *(f"v1/{ident}/{state}" for ident in (0, 42, 9007199254740993, 9223372036854775807)
              for state in ("ready", "ready_cached", "pending")), "error/v1", "error/v2"},
        "payment-retry": {"initial", "reordered", "changed-payload", "six-day-replay", "tenant-isolation",
                          "lost-response", "new-instance-recovery", "parallel/False", "parallel/True"},
        "queue-worker": {f"{load}/{check}" for load in ("steady", "burst")
                         for check in ("identity", "cost", "capacity", "tail", "backlog")},
        "backfill-ledger": {"equal-count-fixture", "historical-reconcile", "history-isolation",
                            "interruption-observed", "resume-exact", "new-arrival", "watermark-is-id", "resume-isolation"},
        "observability": {"success-results", "success-counters", "active-loading", "failure-results",
                          "failure-counters", "recovery", "cache", "tenant-isolation", "privacy"},
        "overload-recovery": {"bounded-admission", "pending-idempotency", "cancel", "retry-after", "tick-budget",
                              "drained", "outcomes", "effects", "completed-idempotency", "backoff", "fairness"},
    }[case]


# 固定输入必须与原始 fixture 一致；只约束 README 明定不可改的文件，不禁止合法实现替换。
def input_errors(case, project):
    protected = {
        "wire-api": ("contract.json", "client.py"),
        "payment-retry": ("gateway.py",),
        "queue-worker": ("simulator.py", "workloads.py", "measure.py"),
        "backfill-ledger": ("store.py",),
        "observability": (),
        "overload-recovery": ("gateway.py",),
    }[case]
    origin = Path(__file__).with_name("specialist-fixtures") / case
    errors = []
    for name in protected:
        path = project / name
        if path.is_symlink() or not path.is_file() or path.read_bytes() != (origin / name).read_bytes():
            errors.append("固定输入缺失或变化: " + name)
    return errors


# 只接收完整且类型严格的结论；指标留作原始证据，不能替代断言或参与默认通过。
def summarize(case, results, errors=()):
    expected = expected_checks(case)
    metrics = {"metrics/steady", "metrics/burst"} if case == "queue-worker" else set()
    problems = list(errors)
    if set(results) != expected | metrics:
        problems.append("检查项不完整: missing=" + repr(sorted((expected | metrics) - set(results))) +
                        "; unexpected=" + repr(sorted(set(results) - expected - metrics)))
    valid = {name for name in expected if isinstance(results.get(name), dict) and
             type(results[name].get("passed")) is bool}
    if valid != expected:
        problems.append("检查结论必须是布尔值: " + repr(sorted(expected - valid)))
    passed = not problems and all(results[name]["passed"] for name in expected)
    return {"case": case, "passed": passed, "status": "incomplete" if problems else "passed" if passed else "failed",
            "assertions_run": len(valid), "assertions_expected": len(expected),
            "validation_errors": problems, "checks": results}


# 保留各项失败；只接受真正的布尔断言，重复记录不能覆盖先前结果。
def record(results, name, operation):
    try:
        if name in results:
            raise ValueError("重复检查项: " + name)
        value = operation()
        if type(value) is not bool:
            raise TypeError("检查操作必须返回 bool")
        results[name] = {"passed": value}
    except Exception as error:
        results[name] = {"passed": False, "error": type(error).__name__ + ": " + str(error)}


# 只检查真实 JSON 边界，数据期望独立于执行者新增测试；缺省与显式 null 分开验证。
def wire_checks():
    from transport import handle
    from client import consume
    results = {}
    for ident in (0, 42, 9007199254740993, 9223372036854775807):
        for state in ("ready", "ready_cached", "pending"):
            for note in ("absent", None, ""):
                original = {"id": ident, "state": state}
                if note != "absent":
                    original["note"] = note
                expected = {**original, "id": str(ident)}
                record(results, f"v2/{ident}/{state}/{note}",
                       lambda original=original, expected=expected: consume(*handle("v2", original)) == expected)
            record(results, f"v1/{ident}/{state}", lambda ident=ident, state=state:
                   json.loads(handle("v1", {"id": ident, "state": state})[1]) ==
                   {"id": ident, "state": "ready" if state in ("ready", "ready_cached") else "pending"})
    for version in ("v1", "v2"):
        record(results, f"error/{version}", lambda version=version:
               handle(version, None)[0] == 404 and
               json.loads(handle(version, None)[1]) == {"error": {"code": "NOT_FOUND", "retryable": False}})
    return results


# 使用共享网关及新建 Service 验证生命周期；注入网关延时仅为了制造请求重叠，不作速度结论。
def payment_checks():
    from gateway import Gateway
    from service import Ledger, Service
    results = {}
    payload = {"amount": 315, "currency": "CNY"}
    gateway, ledger = Gateway(), Ledger()
    first = Service(gateway, ledger).submit("a", "order-1", payload, 0)
    record(results, "initial", lambda: first[0] == 200 and len(gateway.effects) == 1)
    record(results, "reordered", lambda: Service(gateway, ledger).submit(
        "a", "order-1", {"currency": "CNY", "amount": 315}, 1) == first)
    record(results, "changed-payload", lambda: Service(gateway, ledger).submit(
        "a", "order-1", {"amount": 316, "currency": "CNY"}, 2)[0] == 409 and len(gateway.effects) == 1)
    record(results, "six-day-replay", lambda: Service(gateway, ledger).submit(
        "a", "order-1", payload, 6 * 86400) == first and len(gateway.effects) == 1)
    separate, partitions = Gateway(), Ledger()
    left = Service(separate, partitions).submit("a", "shared-key", payload, 0)
    right = Service(separate, partitions).submit("b", "shared-key", payload, 0)
    record(results, "tenant-isolation", lambda: left[0] == right[0] == 200 and
           left[1] != right[1] and len(separate.effects) == 2)
    other, history = Gateway(), Ledger()
    other.lose_next_response = True
    unknown = Service(other, history).submit("a", "lost", payload, 10)
    record(results, "lost-response", lambda: unknown[0] in (200, 202) and len(other.effects) == 1)
    original_receipt = next(iter(other.effects.values()))["receipt"]
    record(results, "new-instance-recovery", lambda: Service(other, history).submit(
        "a", "lost", payload, 11) == (200, original_receipt) and len(other.effects) == 1)
    for different in (False, True):
        overlapping, shared = Gateway(), Ledger()
        original_charge = overlapping.charge

        # 给并发请求提供可重叠的外部等待，保留原网关的原子性及错误语义。
        def slow_charge(*args):
            time.sleep(.02)
            return original_charge(*args)

        overlapping.charge = slow_charge
        barrier = threading.Barrier(8)

        # 同时从公开入口提交；不同载荷仅改变金额，不读取执行者内部状态。
        def submit(index):
            barrier.wait(timeout=5)
            content = {**payload, "amount": payload["amount"] + (index % 2 if different else 0)}
            return Service(overlapping, shared).submit("a", "parallel", content, 0)

        with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
            responses = list(pool.map(submit, range(8)))
        statuses = sorted(status for status, _ in responses)
        expected = [200] * (4 if different else 8) + ([409] * 4 if different else [])
        record(results, f"parallel/{different}", lambda: statuses == expected and len(overlapping.effects) == 1)
    return results


# 固定模拟器核验用户等待及工作守恒，同时返回原始指标供前后对比，不把 tick 当真实延迟。
def queue_checks():
    from simulator import run
    from workloads import workloads
    from worker import settings
    results = {}
    config = settings()
    for name, jobs in workloads().items():
        actual = run(jobs, config)
        original = run(jobs, {"workers": 1})
        results[f"metrics/{name}"] = {"before": original["metrics"], "after": actual["metrics"]}
        record(results, name + "/identity", lambda: sorted(job["id"] for job in actual["completed"]) == sorted(job["id"] for job in jobs))
        record(results, name + "/cost", lambda: all(job["finish"] - job["start"] == job["duration"] for job in actual["completed"]))
        record(results, name + "/capacity", lambda: max(point["active"] for point in actual["backlog"]) <= 4)
        record(results, name + "/tail", lambda: actual["metrics"]["end_to_end_p95"] < original["metrics"]["end_to_end_p95"])
        record(results, name + "/backlog", lambda: actual["metrics"]["max_queue"] < original["metrics"]["max_queue"])
    return results


# 从独立源集合推导账目预期，在真实 SQLite 中核对重复、缺失、金额、隔离和跨连接恢复。
def backfill_checks():
    from store import connect
    from backfill import run
    results = {}
    source = [(index * 5 + 3, "b" if index % 7 == 0 else "a", index * (-13 if index % 3 == 0 else 17), int(index % 11 != 0)) for index in range(1, 62)]
    expected = sorted((ident, tenant, amount) for ident, tenant, amount, eligible in source if tenant == "a" and eligible)
    sibling = [(999, "b", 310)]

    # 每次使用新的真实数据库，历史污染和中断恢复独立，避免一个失败掩盖另一个。
    def prepare(path):
        connection = connect(path)
        connection.executemany("INSERT INTO source VALUES(?,?,?,?)", source)
        connection.executemany("INSERT INTO target VALUES(?,?,?)", sibling)
        connection.commit()
        return connection

    with tempfile.TemporaryDirectory(prefix="ssf-backfill-check-") as directory:
        history = prepare(str(Path(directory) / "history.sqlite"))
        polluted = expected[:-1] + [expected[0]]
        history.executemany("INSERT INTO target VALUES(?,?,?)", polluted)
        history.commit()
        record(results, "equal-count-fixture", lambda: len(polluted) == len(expected) and sorted(polluted) != expected)
        run(history, "a", 7)
        record(results, "historical-reconcile", lambda: history.execute(
            "SELECT source_id,tenant,amount FROM target WHERE tenant='a' ORDER BY source_id").fetchall() == expected)
        record(results, "history-isolation", lambda: history.execute("SELECT * FROM target WHERE tenant='b'").fetchall() == sibling)
        history.close()
        path = str(Path(directory) / "resume.sqlite")
        connection = prepare(path)
        interrupted = False
        try:
            run(connection, "a", 7, interrupt_after=2)
        except InterruptedError:
            interrupted = True
        record(results, "interruption-observed", lambda: interrupted)
        connection.close()
        connection = connect(path)
        run(connection, "a", 7)
        record(results, "resume-exact", lambda: connection.execute(
            "SELECT source_id,tenant,amount FROM target WHERE tenant='a' ORDER BY source_id").fetchall() == expected)
        connection.execute("INSERT INTO source VALUES(?,?,?,?)", (10001, "a", -93, 1))
        connection.commit()
        run(connection, "a", 7)
        record(results, "new-arrival", lambda: connection.execute(
            "SELECT source_id,tenant,amount FROM target WHERE tenant='a' ORDER BY source_id").fetchall() == expected + [(10001, "a", -93)])
        record(results, "watermark-is-id", lambda: connection.execute("SELECT watermark FROM checkpoint WHERE tenant='a'").fetchone()[0] >= 10001)
        record(results, "resume-isolation", lambda: connection.execute("SELECT * FROM target WHERE tenant='b'").fetchall() == sibling)
        connection.close()
    return results


# 用真实线程制造合并等待和共享异常，检查调用者计数、物理调用及低敏诊断的守恒。
def observability_checks():
    from service import Service
    results = {}
    service = Service()
    calls = []

    # 加载由事件控制，先观察所有调用进入，再释放；超时也释放线程以保留失败证据。
    def concurrent_batch(key, count, failure=None):
        entered, release = threading.Event(), threading.Event()

        # 仅 owner 应进入加载；原值和原异常都携带敏感哨兵，检查诊断不能泄漏。
        def load():
            calls.append(key)
            entered.set()
            if not release.wait(5):
                raise TimeoutError("fixture loader timeout")
            if failure:
                raise failure
            return "CONTENT_SECRET"

        with concurrent.futures.ThreadPoolExecutor(max_workers=count) as pool:
            before = service.metrics()["clients"]
            futures = [pool.submit(service.get, "TENANT_SECRET", key, "TOKEN_SECRET", load) for _ in range(count)]
            entered.wait(2)
            deadline = time.monotonic() + 2
            while service.metrics()["clients"] < before + count and time.monotonic() < deadline:
                time.sleep(.001)
            active = service.metrics()["active_upstream"]
            release.set()
            values = []
            for future in futures:
                try:
                    values.append(future.result(timeout=3))
                except Exception as error:
                    values.append(error)
        return active, values

    active, values = concurrent_batch("KEY_SECRET", 6)
    record(results, "success-results", lambda: values == ["CONTENT_SECRET"] * 6 and calls == ["KEY_SECRET"])
    record(results, "active-loading", lambda: active == 1 and service.metrics()["active_upstream"] == 0)
    record(results, "success-counters", lambda: service.metrics() == dict(
        clients=6, upstream=1, cache_hits=0, coalesced=5, successes=6, failures=0, active_upstream=0))
    record(results, "cache", lambda: service.get("TENANT_SECRET", "KEY_SECRET", "TOKEN_SECRET", lambda: "wrong") ==
           "CONTENT_SECRET" and service.metrics()["cache_hits"] == 1 and service.metrics()["upstream"] == 1)
    failure = ValueError("EXCEPTION_SECRET")
    _, values = concurrent_batch("FAILED_SECRET", 4, failure)
    record(results, "failure-results", lambda: all(value is failure for value in values) and len(calls) == 2)
    record(results, "failure-counters", lambda: service.metrics() == dict(
        clients=11, upstream=2, cache_hits=1, coalesced=8, successes=7, failures=4, active_upstream=0))
    record(results, "recovery", lambda: service.get("TENANT_SECRET", "FAILED_SECRET", "TOKEN_SECRET", lambda: "recovered") ==
           "recovered" and service.metrics()["successes"] == 8 and service.metrics()["upstream"] == 3)
    record(results, "tenant-isolation", lambda: service.get("OTHER_SECRET", "KEY_SECRET", "TOKEN_SECRET", lambda: "other") == "other")
    record(results, "privacy", lambda: bool(service.events) and "SECRET" not in json.dumps(
        {"metrics": service.metrics(), "events": service.events}, ensure_ascii=False))
    return results


# 固定时钟验证有界准入、限流等待、取消及恢复；输出只证明模拟业务语义，不当生产性能。
def overload_checks():
    from dispatcher import Dispatcher
    from gateway import Gateway
    results = {}
    dispatcher, gateway = Dispatcher(6), Gateway()
    jobs = {"a": "normal", "b": "lose-response", "c": "normal", "d": "invalid", "e": "normal", "f": "normal"}
    accepted = [dispatcher.submit(key, payload, 0) for key, payload in jobs.items()]
    record(results, "bounded-admission", lambda: all(accepted) and dispatcher.submit("overflow", "normal", 0) is False and
           len(dispatcher.pending) <= 6)
    record(results, "pending-idempotency", lambda: dispatcher.submit("a", "normal", 0) is True and
           dispatcher.submit("a", "changed", 0) is False)
    dispatcher.tick(0, gateway)
    cancelled = dispatcher.cancel("c")
    for now in range(1, 31):
        dispatcher.tick(now, gateway)
    record(results, "cancel", lambda: cancelled is True and dispatcher.cancel("c") is False and
           all(key != "c" for key, _, _ in gateway.calls))
    record(results, "retry-after", lambda: all(
        times[index + 1] - instant >= 3 for key in jobs
        for times in [[now for called, _, now in gateway.calls if called == key]]
        for index, instant in enumerate(times[:-1]) if instant < gateway.recover_at and jobs[key] != "invalid"))
    record(results, "tick-budget", lambda: all(sum(instant == now for _, _, instant in gateway.calls) <= 2 for now in range(31)))
    record(results, "drained", lambda: not dispatcher.pending and set(dispatcher.results) == set(jobs) - {"c"})
    record(results, "outcomes", lambda: dispatcher.results == {key: (400, "invalid") if payload == "invalid" else
           (200, "receipt:" + key) for key, payload in jobs.items() if key != "c"})
    record(results, "effects", lambda: set(gateway.effects) == {"a", "b", "e", "f"} and
           all(payload == jobs[key] for key, payload, _ in gateway.calls if key in jobs))
    calls_before = len(gateway.calls)
    replay = dispatcher.submit("a", "normal", 31)
    conflict = dispatcher.submit("a", "changed", 31)
    dispatcher.tick(31, gateway)
    record(results, "completed-idempotency", lambda: replay is True and conflict is False and len(gateway.calls) == calls_before)

    class Unavailable:
        def __init__(self):
            self.calls = []

        # 慢任务持续 503，其他任务直接成功，用外部调用记录核对退避与公平性。
        def send(self, key, payload, now):
            self.calls.append((key, now))
            return (503, "busy", 0) if key == "slow" else (200, key, 0)

    retry, unavailable = Dispatcher(), Unavailable()
    retry.submit("slow", "normal", 0)
    for now in range(24):
        if now == 2:
            retry.submit("fast", "normal", now)
        retry.tick(now, unavailable)
    record(results, "backoff", lambda: [now for key, now in unavailable.calls if key == "slow"] == [0, 1, 3, 7, 15, 23])
    record(results, "fairness", lambda: ("fast", 2) in unavailable.calls and retry.results.get("fast") == (200, "fast"))
    return results


# 一个进程只加载一个项目；候选主动退出也算未完成，避免零退出码掩盖未执行检查。
def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("case", choices=("wire-api", "payment-retry", "queue-worker", "backfill-ledger",
                                        "observability", "overload-recovery"))
    parser.add_argument("project", type=Path)
    args = parser.parse_args()
    sys.path.insert(0, str(args.project.resolve()))
    checks = {"wire-api": wire_checks, "payment-retry": payment_checks,
              "queue-worker": queue_checks, "backfill-ledger": backfill_checks,
              "observability": observability_checks, "overload-recovery": overload_checks}
    errors = input_errors(args.case, args.project)
    try:
        results = {} if errors else checks[args.case]()
    except BaseException as error:
        results = {"checker-error": {"passed": False, "error": repr(error)}}
    errors.extend(error for error in input_errors(args.case, args.project) if error not in errors)
    outcome = summarize(args.case, results, errors)
    print(json.dumps(outcome, ensure_ascii=False, indent=2))
    return 0 if outcome["passed"] else 1


if __name__ == "__main__":
    sys.exit(main())
