"""复杂行为输入：只生成项目材料，不包含给执行者的预期答案或评分。"""
import json
from pathlib import Path


# 用分散模块和高匹配量历史材料构造检索压力；保持输入确定，便于新旧技能复跑。
def cases():
    files = {
        "README.md": "# 下载状态迁移\n\n当前公开入口是 api.download(channel, state) 和 api.export_v1(state)。新增 ready_cached 应与 ready 一样可下载；其他状态（包括 exporting）不可下载。v1 只输出 ready/pending。audit 的 ready 是审计完成状态，不属于下载协议。历史导出位于 archive/，不参与运行且不得批量改写。\n",
        "api.py": "import importlib\nimport json\nfrom pathlib import Path\n\n# 按已登记渠道动态分派下载策略，未知渠道由注册表报错。\ndef download(channel, state):\n    mapping = json.loads(Path(__file__).with_name('channels.json').read_text())\n    module, symbol = mapping[channel].split(':')\n    return getattr(importlib.import_module(module), symbol)(state)\n\n# 保持旧客户端只接收 ready/pending 的协议。\ndef export_v1(state):\n    return {'status': 'ready' if state == 'ready' else 'pending'}\n",
        "audit.py": "# 审计仅接受已完成状态；与下载状态无关。\ndef complete(state):\n    return state == 'ready'\n",
        "test_api.py": "import unittest\nfrom api import download, export_v1\n\nclass ApiTests(unittest.TestCase):\n    def test_current(self):\n        self.assertTrue(download('channel-00', 'ready'))\n        self.assertFalse(download('channel-00', 'pending'))\n        self.assertEqual(export_v1('pending'), {'status': 'pending'})\n",
    }
    mapping = {}
    for index in range(24):
        module = f"packages.area_{index:02d}.reader"
        mapping[f"channel-{index:02d}"] = module + ":eligible"
        predicate = ["state == 'ready'", "state in ('ready',)", "state == AVAILABLE"][index % 3]
        files[module.replace('.', '/') + '.py'] = (
            "AVAILABLE = 'ready'\n\n# 按本渠道下载状态返回是否允许下载。\n"
            f"def eligible(state):\n    return {predicate}\n"
        )
    files["channels.json"] = json.dumps(mapping, indent=2) + "\n"
    for index in range(600):
        files[f"archive/export_{index:04d}.txt"] = "".join(
            f"history={index}/{line} state=ready archive-only payload=" + "x" * 160 + "\n"
            for line in range(32)
        )
    browser = Path(__file__).with_name("browser-fixture")
    return {
        "search-large": {
            "request": "请实现 ready_cached 下载状态，覆盖现有公开渠道并保持旧接口和其他领域行为。完成验证；保留工作区里其他任务的改动。",
            "files": files,
            "dirty_files": {"notes.txt": "another task: preserve this note\n"},
        },
        "resume-handoff": {
            "request": "下载保存失败后额度丢失，需要修复首次下载和重试，成功只扣一次，失败保留原异常并退回额度。本会话只完成问题定位、复现测试和交接计划 notes/download-plan.md，不要修复实现；把后续继续所需的状态留在这份计划中。",
            "files": {
                "README.md": "# 下载服务\n\nAccount.download 和 retry_download 是公开入口。保存失败需恢复额度并抛出原异常，非正额度拒绝且不调用保存。display_name 的用户文案不在修复范围。本项目没有发布任务。\n",
                "quota.py": "class Account:\n    def __init__(self, remaining):\n        self.remaining = remaining\n\n    # 首次下载预扣一次额度；保存失败向上抛出。\n    def download(self, save):\n        if self.remaining <= 0:\n            return False\n        self.remaining -= 1\n        save()\n        return True\n\n\ndef retry_download(account, save):\n    return account.download(save)\n\n\ndef display_name():\n    return '下载'\n",
                "test_quota.py": "import unittest\nfrom quota import Account\n\nclass QuotaTests(unittest.TestCase):\n    def test_success(self):\n        account = Account(1)\n        self.assertTrue(account.download(lambda: None))\n        self.assertEqual(account.remaining, 0)\n",
            },
            "dirty_files": {"notes.txt": "another task: initial draft\n"},
        },
        "qa-browser": {
            "request": "验收本地通知设置页，按 README 的用户契约检查真实浏览器交互、刷新后的状态和窄视口可用性；只验收不修复。允许操作隔离测试账号。报告通过、失败、未验证及实际证据。服务地址由评估者给出。",
            "files": {p.name: p.read_text() for p in sorted(browser.iterdir()) if p.is_file()},
        },
    }
