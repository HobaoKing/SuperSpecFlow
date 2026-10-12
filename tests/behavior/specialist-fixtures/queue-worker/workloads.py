# 两种确定性到达形状；duration 只是模型的逻辑时间成本。
def workloads():
    steady = [{"id": i, "arrival": i // 2, "duration": 8 if i % 20 == 0 else 1} for i in range(240)]
    burst = [{"id": i, "arrival": (i // 30) * 20, "duration": 6 if i % 9 == 0 else 1} for i in range(150)]
    return {"steady": steady, "burst": burst}
