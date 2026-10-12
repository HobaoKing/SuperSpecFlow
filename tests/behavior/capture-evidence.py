#!/usr/bin/env python3
"""记录离线评估命令的真实输出与输入摘要；不执行模型，也不把退出成功等同于技能有效。"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import signal
import subprocess
import time


# 摘要只覆盖明确的离线项目文件，排除 Git 内部及解释器缓存；不跟随符号链接。
def snapshot(root):
    result = {}
    for path in sorted(root.rglob("*")):
        if {".git", "__pycache__"}.intersection(path.relative_to(root).parts):
            continue
        if path.is_symlink():
            content = ("symlink:" + os.readlink(path)).encode()
        elif path.is_file():
            content = path.read_bytes()
        else:
            continue
        result[str(path.relative_to(root))] = hashlib.sha256(content).hexdigest()
    return result


# 绑定本次请求及技能实际字节，不仅信任 fixture.json 中自述的版本号。
def inputs(fixture, case):
    requests = json.loads((fixture / "requests.json").read_text())
    result = {name: hashlib.sha256((fixture / name).read_bytes()).hexdigest()
              for name in ("fixture.json", "requests.json", "catalog.md")}
    result["skills"] = snapshot(fixture / "skills")
    result["request"] = requests[case]
    return result


# 命令参数中的绝对文件路径包括项目外评估器，记录其字节以发现换评估器后的旧结论。
def command_files(command):
    return {value: hashlib.sha256(Path(value).read_bytes()).hexdigest()
            for value in command if Path(value).is_absolute() and Path(value).is_file()}


# 输出目录必须新建且位于输入之外；无 shell 执行，超时终止整个命令进程组并保留已写日志。
def capture(args):
    fixture, output = args.fixture.resolve(), args.output.resolve()
    project = fixture / args.case
    if not project.is_dir() or fixture in (output, *output.parents) or output in fixture.parents:
        raise ValueError("需要有效场景及输入目录以外的新证据目录")
    command = args.command[1:] if args.command[:1] == ["--"] else args.command
    if not command or args.timeout <= 0:
        raise ValueError("命令不能为空，超时须大于零")
    bound_inputs, before = inputs(fixture, args.case), snapshot(project)
    output.mkdir(parents=True, exist_ok=False)
    receipt = {"schema": 1, "evidence_type": "command", "fixture": str(fixture), "case": args.case,
               "cwd": str(project), "command": command, "inputs": bound_inputs, "before": before,
               "command_files": command_files(command),
               "started_at": datetime.now(timezone.utc).isoformat(), "exit_code": None,
               "status": "spawn_error", "error": None}
    start = time.monotonic()
    with (output / "stdout.bin").open("wb") as stdout, (output / "stderr.bin").open("wb") as stderr:
        try:
            process = subprocess.Popen(command, cwd=project, stdout=stdout, stderr=stderr, start_new_session=True,
                                       env=dict(os.environ, GIT_CONFIG_GLOBAL=os.devnull, GIT_CONFIG_NOSYSTEM="1"))
            try:
                receipt["exit_code"] = process.wait(timeout=args.timeout)
                receipt["status"] = "completed" if process.returncode == 0 else "nonzero"
            except subprocess.TimeoutExpired:
                os.killpg(process.pid, signal.SIGKILL)
                receipt["exit_code"] = process.wait()
                receipt["status"] = "timeout"
        except OSError as error:
            receipt["error"] = repr(error)
    receipt["duration_seconds"] = time.monotonic() - start
    receipt["after"] = snapshot(project)
    receipt["inputs_unchanged"] = inputs(fixture, args.case) == bound_inputs
    receipt["artifacts"] = snapshot(output)
    (output / "receipt.json").write_text(json.dumps(receipt, ensure_ascii=False, indent=2) + "\n")
    return 0 if receipt["status"] == "completed" and receipt["inputs_unchanged"] else 1


# 核对日志是否缺失/变动及输入是否过期；哈希证明可追溯性，不证明命令内容正确或抵御恶意重写。
def verify(output):
    try:
        receipt = json.loads((output / "receipt.json").read_text())
        fixture = Path(receipt["fixture"])
        actual = snapshot(output)
        actual.pop("receipt.json", None)
        checks = {"logs_intact": actual == receipt["artifacts"] and set(actual) == {"stdout.bin", "stderr.bin"},
                  "inputs_current": inputs(fixture, receipt["case"]) == receipt["inputs"],
                  "project_current": snapshot(Path(receipt["cwd"])) == receipt["after"],
                  "command_files_current": command_files(receipt["command"]) == receipt["command_files"],
                  "command_completed": receipt["status"] == "completed" and receipt["exit_code"] == 0,
                  "inputs_unchanged": receipt["inputs_unchanged"] is True}
        result = {"passed": all(checks.values()), "checks": checks}
    except (OSError, ValueError, KeyError, TypeError) as error:
        result = {"passed": False, "error": repr(error)}
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0 if result["passed"] else 1


# capture 只负责运行与留证，verify 只读回；两者都不覆盖原有证据。
def main():
    parser = argparse.ArgumentParser(description=__doc__)
    actions = parser.add_subparsers(dest="action", required=True)
    run = actions.add_parser("run")
    run.add_argument("fixture", type=Path)
    run.add_argument("case")
    run.add_argument("output", type=Path)
    run.add_argument("--timeout", type=float, default=60)
    run.add_argument("command", nargs=argparse.REMAINDER)
    check = actions.add_parser("verify")
    check.add_argument("output", type=Path)
    args = parser.parse_args()
    return capture(args) if args.action == "run" else verify(args.output)


if __name__ == "__main__":
    raise SystemExit(main())
