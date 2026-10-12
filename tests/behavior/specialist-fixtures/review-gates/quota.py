# 只对正额度放行。
def can_download(remaining):
    return remaining > 0


class Account:
    def __init__(self, remaining):
        self.remaining = remaining

    # 预扣保存额度，失败时向调用方保留原异常。
    def save(self, write):
        if self.remaining <= 0:
            return False
        self.remaining -= 1
        write()
        return True
