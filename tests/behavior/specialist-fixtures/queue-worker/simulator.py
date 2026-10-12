from collections import deque
import math
import statistics


# 模拟固定下游容量，返回完整生命周期及队列轨迹；超容量或未排空直接报错。
def run(jobs, config):
    workers = config["workers"]
    if not isinstance(workers, int) or not 1 <= workers <= 4:
        raise ValueError("downstream capacity is four")
    incoming = deque(sorted((dict(job) for job in jobs), key=lambda job: job["arrival"]))
    queue, active, completed, backlog = deque(), [], [], []
    tick = 0
    while incoming or queue or active:
        while incoming and incoming[0]["arrival"] <= tick:
            queue.append(incoming.popleft())
        remaining = []
        for job in active:
            if job["finish"] == tick:
                completed.append(job)
            else:
                remaining.append(job)
        active = remaining
        while queue and len(active) < workers:
            job = queue.popleft()
            job["start"] = tick
            job["finish"] = tick + job["duration"]
            active.append(job)
        backlog.append({"tick": tick, "queued": len(queue), "active": len(active),
                        "oldest_age": tick - queue[0]["arrival"] if queue else 0})
        tick += 1
        if tick > 100000:
            raise RuntimeError("queue did not drain")
    waits = sorted(job["finish"] - job["arrival"] for job in completed)
    service = [job["finish"] - job["start"] for job in completed]
    return {"completed": completed, "backlog": backlog,
            "metrics": {"service_median": statistics.median(service) if service else 0,
                        "end_to_end_p95": waits[math.ceil(len(waits) * .95) - 1] if waits else 0,
                        "max_queue": max((point["queued"] for point in backlog), default=0),
                        "max_queue_age": max((point["oldest_age"] for point in backlog), default=0),
                        "drained_at": tick - 1}}
