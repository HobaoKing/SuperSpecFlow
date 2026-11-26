class Preview:
    def __init__(self):
        self.active = "main"
        self.drafts = {}
        self.cache = {}
        self.visible = None

    # 切换界面时立即展示目标工作区已有的预览。
    def select(self, workspace):
        self.active = workspace
        self.visible = self.cache.get(workspace)

    # 返回交给后台队列的工作，实际执行时再读取草稿。
    def enqueue(self):
        owner = self.active
        return lambda: (owner, self.drafts[self.active].upper())

    # 缓存结果并向已打开的预览窗更新内容。
    def complete(self, result):
        owner, text = result
        self.cache[owner] = text
        self.visible = text
