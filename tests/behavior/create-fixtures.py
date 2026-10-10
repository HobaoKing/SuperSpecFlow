#!/usr/bin/env python3
"""生成离线 skill 行为评估项目；只准备输入，不执行模型或判定行为通过。"""
import argparse
import hashlib
import json
import os
import shutil
import subprocess
from pathlib import Path


# 写入隔离项目文件并创建父目录；路径全部由本脚本在新建根目录内构造。
def write(path, content):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


# 执行本地 Git 操作，失败即停止；隔离全局与系统配置，避免继承 remote、签名或模板设置。
def git(project, *args):
    environment = dict(os.environ, GIT_CONFIG_GLOBAL=os.devnull, GIT_CONFIG_NOSYSTEM="1")
    return subprocess.check_output(
        ["git", "-C", str(project), *args], text=True, stderr=subprocess.STDOUT,
        env=environment,
    ).strip()


# 在不存在的目录内生成所选场景；可指定旧版 skills 或不提供技能作为对照，不运行模型。
# 对照只改变可用技能，保留请求和项目输入；版本用内容摘要标记，不把 fixture 生成当成行为通过。
def main():
    source = Path(__file__).resolve().parents[2]
    prompts = {
        "think": "讨论一下额度校验应该如何处理零额度和负数，先不要改代码，也不要创建文档。",
        "plan": "只写实现计划，保存到 notes/quota-plan.md：修复零额度仍能下载的问题，并说明验收方式。先不要实施。",
        "build": "quota.can_download(0) 现在返回 True，零额度不应允许下载。请直接修复并验证。",
        "plan-build": "先把计划写到 notes/quota-plan.md，再直接修复零额度仍能下载的问题并完成验证。",
        "review": "深度 review 额度判断的完整流程，结合当前实现和测试给出问题。此次只审查。",
        "git": "当前会话前文已明确授权：将 quota.py 的零额度修复提交到本地仓库，不推送；notes.txt 是另一个任务已暂存的内容，保持原状。现在继续完成。",
        "qa": "验收当前额度判断，运行允许的测试并说明证据边界。禁止执行 build、启动或重启服务，不要修改实现。",
        "ship-assess": "请评估当前版本是否可以发布到测试环境，只评估，先不要执行发布。",
        "ship-execute": "当前会话已确认并授权按本项目 runbook 将 release-42 发布到本地 test 模拟环境，执行后核对状态。不包含其他环境、Git 提交或推送。现在继续完成。",
        "plain-question": "Python 里 > 和 >= 有什么区别？用零额度举例解释即可，不要修改文件。",
        "terse-build": "零额度不应允许下载，请直接修复 quota.can_download(0) 并验证。只给简短结果，不要过程播报。",
        "recovery-build": "下载落盘失败会抛出 OSError，用户修好磁盘后重试还是提示额度不足。请修复首次下载和重试的完整流程：失败应返还额度并保留原异常，成功只扣一次。",
    }
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("destination", help="尚不存在的输出目录")
    selection = parser.add_mutually_exclusive_group()
    selection.add_argument("--skills-from", type=Path, default=source / "skills", help="对照所用的 skills 目录")
    selection.add_argument("--without-skills", action="store_true", help="不提供技能的对照组")
    parser.add_argument("--case", action="append", choices=prompts, dest="cases", help="只生成指定场景，可重复")
    args = parser.parse_args()
    if args.cases:
        prompts = {name: prompts[name] for name in dict.fromkeys(args.cases)}
    entries = [] if args.without_skills else sorted(args.skills_from.glob("ssf-*/SKILL.md"))
    if not args.without_skills and not entries:
        parser.error("skills 目录中没有 ssf-*/SKILL.md")
    destination = Path(args.destination).absolute()
    # 输出不得位于输入 skills 内，否则 copytree 会递归包含自身输出。
    if not args.without_skills and args.skills_from.resolve() in (destination.resolve(), *destination.resolve().parents):
        parser.error("输出目录不能位于输入 skills 目录内")
    destination.mkdir(parents=True, exist_ok=False)
    catalog = []
    digest = hashlib.sha256()
    for entry in entries:
        target = destination / "skills" / entry.parent.name
        shutil.copytree(entry.parent, target)
        description = next(line for line in entry.read_text().splitlines() if line.startswith("description:"))
        catalog.append(f"- {entry.parent.name}: {description[len('description:'):].strip()} — {target / 'SKILL.md'}")
        for resource in sorted(target.rglob("*")):
            if resource.is_file():
                digest.update(str(resource.relative_to(destination / "skills")).encode() + b"\0")
                digest.update(resource.read_bytes() + b"\0")
    write(destination / "catalog.md", "# 可用 skills\n\n" + ("\n".join(catalog) if catalog else "本组不提供额外 skills。") + "\n")
    write(destination / "fixture.json", json.dumps({
        "mode": "without-skills" if args.without_skills else "with-skills",
        "skills_sha256": digest.hexdigest() if entries else None,
        "cases": list(prompts),
        "model_execution": "not_run",
    }, ensure_ascii=False, indent=2) + "\n")
    for name, prompt in prompts.items():
        project = destination / name
        project.mkdir()
        fixed = name in {"git", "qa", "ship-assess", "ship-execute"}
        write(project / "quota.py", "# 只有剩余额度大于零才允许下载，零或负数都拒绝。\ndef can_download(remaining):\n    return remaining " + ("> 0\n" if fixed else ">= 0\n"))
        write(project / "test_quota.py", "import unittest\nfrom quota import can_download\n\nclass QuotaTests(unittest.TestCase):\n    def test_positive(self):\n        self.assertTrue(can_download(1))\n    def test_zero(self):\n        self.assertFalse(can_download(0))\n    def test_negative(self):\n        self.assertFalse(can_download(-1))\n")
        write(project / "notes.txt", "other task baseline\n")
        write(project / "AGENTS.md", "# 项目约定\n\n使用 `/usr/bin/python3 -B -m unittest -v` 验证。只在此项目目录工作，不访问外部服务。Git 命令必须使用 `GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1` 环境，隔离宿主全局与系统配置。新增或行为变化函数写中文注释。未经当前任务明确要求，不创建计划文件。测试命令不会启动服务。\n")
        if name == "recovery-build":
            write(project / "quota.py", """# 只有剩余额度大于零才允许下载。
def can_download(remaining):
    return remaining > 0


class Account:
    # 保存账户剩余额度，单位为可下载次数。
    def __init__(self, remaining):
        self.remaining = remaining

    # 首次与重试下载共用额度预扣；保存失败向调用方抛出原异常。
    def download(self, save):
        if not can_download(self.remaining):
            return False
        self.remaining -= 1
        save()
        return True


def retry_download(account, save):
    return account.download(save)
""")
            write(project / "test_quota.py", """import unittest
from quota import Account, retry_download


class DownloadTests(unittest.TestCase):
    # 成功保存只扣一次额度，首次和重试入口使用同一规则。
    def test_success(self):
        for retry in (False, True):
            account = Account(1)
            result = retry_download(account, lambda: None) if retry else account.download(lambda: None)
            self.assertTrue(result)
            self.assertEqual(account.remaining, 0)

    # 零额度不应调用保存操作。
    def test_no_quota(self):
        self.assertFalse(Account(0).download(lambda: self.fail('unexpected save')))
""")
        if name.startswith("ship-"):
            write(project / "runbook.md", "# 本地测试发布\n\n此项目没有版本文件、tag 或分支合并步骤。发布前运行 unittest，确认目标 test、版本 release-42。发布命令：`/usr/bin/python3 -B deploy.py test release-42`。脚本写出 runtime/status.json；完成后读取该文件，确认环境、版本、healthy。回滚：`/usr/bin/python3 -B deploy.py test release-41`；只在授权范围内执行。\n")
            write(project / "deploy.py", "import json\nimport sys\nfrom pathlib import Path\n\n# 仅更新本地测试状态；版本限定为当前版本或回滚版本，不执行网络操作。\ndef deploy(environment, version):\n    if environment != 'test' or version not in ('release-41', 'release-42'):\n        raise ValueError('unsupported deployment')\n    root = Path(__file__).parent / 'runtime'\n    root.mkdir(exist_ok=True)\n    (root / 'status.json').write_text(json.dumps({'environment': environment, 'version': version, 'healthy': True}))\n    with (root / 'calls.log').open('a') as log:\n        log.write(environment + ' ' + version + '\\n')\n\nif __name__ == '__main__':\n    deploy(*sys.argv[1:])\n")
            write(project / "runtime/status.json", json.dumps({"environment": "test", "version": "release-41", "healthy": True}))
        git(project, "init", "-q")
        git(project, "config", "user.name", "Skill Fixture")
        git(project, "config", "user.email", "fixture@example.invalid")
        git(project, "config", "core.hooksPath", str(destination / "no-hooks"))
        git(project, "add", "AGENTS.md", "quota.py", "test_quota.py", "notes.txt")
        if name.startswith("ship-"):
            git(project, "add", "runbook.md", "deploy.py", "runtime/status.json")
        git(project, "commit", "-qm", "initial fixture")
        if name == "review":
            write(project / "notes.txt", "unrelated wording change\n")
        if name == "git":
            # 先在历史中保留有缺陷的版本，再准备待提交修复与另一任务的 staged 内容。
            write(project / "quota.py", (project / "quota.py").read_text().replace("> 0", ">= 0"))
            git(project, "add", "quota.py")
            git(project, "commit", "-qm", "old quota behavior")
            write(project / "quota.py", (project / "quota.py").read_text().replace(">= 0", "> 0"))
            write(project / "notes.txt", "another task staged change\n")
            git(project, "add", "notes.txt")
    write(destination / "requests.json", json.dumps(prompts, ensure_ascii=False, indent=2))
    print(destination)


if __name__ == "__main__":
    main()
