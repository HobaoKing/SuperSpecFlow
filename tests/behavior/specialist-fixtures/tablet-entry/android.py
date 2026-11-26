# 返回本端管理入口、提示锚点和已登录时可见的文案。
def screen(online):
    return ("我的/设备管理", "toolbar.start", "已登录平板设备" if online else "")
