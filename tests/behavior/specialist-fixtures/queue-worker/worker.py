# 并发设置必须符合下游容量；不改变每个任务的处理语义。
def settings():
    return {"workers": 1}
