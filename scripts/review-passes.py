#!/usr/bin/env python3
"""在同一 Codex CLI 会话中完成两遍只读审查，原样保留各遍交付。"""
import argparse
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import time
from urllib.parse import quote


FIRST = """本次负责源码审查的第一遍。按上面用户指定的范围自由取证，直接交付已核实的问题、触发和影响。交付将原样保留，下一遍由同一会话继续。"""
SECOND = """继续原任务，第一份报告已保存。按用户所问的每个结果，从真实调用或使用示例写出一条最短反例，优先挑战第一遍判为正常或依赖外层保护的位置。核对调用开始、返回当下、后续交付。对因条件不足而直接返回的分支，把发起请求与条件满足的先后交换：调用者还能拿到什么，谁记住请求，条件变化由哪一行重新驱动它？反向检查撤销或替换先到、旧操作后完成时谁阻止副作用。固定其余输入，分别检查可复用结果和允许独立变化的条件。用调用点、实际返回值和最终消费者检验每条反例；缺失实现则区分已确定的缺口和附条件的影响。只交付新增发现和有反证的更正，给出具体位置和影响。沿用最初的只读范围。"""


# 单遍只读运行成功后保留原文；续接必须指向原会话，失败时不给出完整报告。
def run_pass(command, prompt, answer, expected_thread=None):
    with tempfile.TemporaryFile(mode="w+", encoding="utf-8") as input_file:
        input_file.write(prompt)
        input_file.seek(0)
        with subprocess.Popen(command, stdin=input_file, stdout=subprocess.PIPE, text=True) as process:
            thread = None
            completed = False
            for line in process.stdout:
                event = json.loads(line)
                if event.get("type") == "thread.started":
                    thread = event["thread_id"]
                elif event.get("type") == "turn.completed":
                    completed = True
                elif event.get("type") in ("turn.failed", "error"):
                    print(event.get("error") or event.get("message"), file=sys.stderr)
            status = process.wait()
    if status or not completed or not thread or (expected_thread and expected_thread != thread):
        raise RuntimeError(f"Codex 未完整交付 {answer.name}（退出码 {status}）")
    if not answer.is_file() or not answer.read_text(encoding="utf-8").strip():
        raise RuntimeError(f"Codex 未写出 {answer.name}")
    return thread


# 阻止 JSON 解码时用后一项静默覆盖前一项的历史判定。
def unique_verdict_keys(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"复核回执含重复字段 {key}")
        result[key] = value
    return result


# 读取原始报告。Markdown 按段落、列表项和表格行保留原文，JSON 允许提供预先拆开的单项发现。
def historical_items(source, content):
    body = content.decode("utf-8")
    if source.suffix.lower() == ".json":
        items = json.loads(body)
        if not isinstance(items, list) or not all(isinstance(v, str) and v.strip() for v in items):
            raise ValueError("历史 JSON 应为字符串数组，每项是一条带触发和影响的发现")
        return items
    if source.suffix.lower() not in (".md", ".txt"):
        raise ValueError("历史报告支持 Markdown、纯文本和 JSON 字符串数组")
    return [block.strip() for block in re.split(r"\n\s*\n|\n(?=\s*(?:[-*] |\d+[.)] |\|))", body)
            if block.strip() and not re.fullmatch(r"[\s|:-]+", block)]


# 首次模型调用前逐份校验并冻结历史原文。后续复核和归档共享这份快照。
def read_previous(sources):
    originals = []
    findings = {}
    for source in sources:
        if not source.is_file():
            raise ValueError(f"历史报告不是可读文件：{source}")
        content = source.read_bytes()
        try:
            claims = historical_items(source, content)
        except ValueError as error:
            raise ValueError(f"{source}：{error}") from error
        if not claims:
            raise ValueError(f"历史报告没有可供复验的内容：{source}")
        originals.append((source, content))
        for claim in claims:
            findings[f"P{len(findings) + 1}"] = claim
    return originals, findings


# 在已绑定的原会话中复核并归档冻结的原件；回执必须覆盖每项结论和证据。
def check_previous(dest, originals, findings, common, session):
    original = (dest / "review.md").read_bytes()
    folder = Path(tempfile.mkdtemp(prefix="previous-", dir=dest))
    archive = folder / "sources"
    archive.mkdir()
    for index, (source, content) in enumerate(originals, 1):
        (archive / f"{index}-{source.name}").write_bytes(content)
    (folder / "input.json").write_text(json.dumps(findings, ensure_ascii=False, indent=2), encoding="utf-8")
    labels = {"confirmed": "仍成立", "refuted": "已反证", "unverified": "未核实"}
    item = {"type": "object", "additionalProperties": False, "required": ["status", "evidence"],
            "properties": {"status": {"type": "string", "enum": list(labels)}, "evidence": {"type": "string"}}}
    schema = {"type": "object", "properties": dict.fromkeys(findings, item),
              "required": list(findings), "additionalProperties": False}
    schema_path = folder / "schema.json"
    schema_path.write_text(json.dumps(schema), encoding="utf-8")
    prompt = ("继续在原只读范围审查。以下 JSON 是待核实的既有问题。逐项以当前源码、调用方和触发条件"
              "给出仍成立、已反证或未核实，以及位置和证据。历史说法本身不能证明成立。\n" +
              json.dumps(findings, ensure_ascii=False))
    answer = folder / "verdicts.json"
    run_pass(["codex", "exec", "resume", *common, "--output-schema", str(schema_path),
              "-o", str(answer), session, "-"], prompt, answer, session)
    checks = json.loads(answer.read_text(encoding="utf-8"), object_pairs_hook=unique_verdict_keys)
    if not isinstance(checks, dict) or checks.keys() != findings.keys():
        raise ValueError("回执未覆盖全部历史发现")
    rows = []
    for key, claim in findings.items():
        verdict = checks[key]
        if (not isinstance(verdict, dict) or verdict.get("status") not in labels
                or not isinstance(verdict.get("evidence"), str) or not verdict["evidence"].strip()):
            raise ValueError(f"{key} 缺少有效结论或证据")
        rows.append(f"**{key} · {labels[verdict['status']]}**　{claim}\n\n{verdict['evidence']}")
    links = [f"[历史原件 {i}](sources/{quote(f'{i}-{source.name}')})" for i, (source, _) in enumerate(originals, 1)]
    supplement = "\n\n## 既有发现逐项复核\n\n" + " · ".join(links) + "\n\n" + "\n\n".join(rows) + "\n"
    (folder / "review.md").write_bytes(original + supplement.encode())
    print(folder / "review.md")


# 新审查从标准输入读取任务并独占输出目录；历史续查只允许在原项目目录追加，不接受新题。
def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--output", type=Path, help="从标准输入开始新审查，写入尚不存在的目录")
    mode.add_argument("--resume", type=Path, help="从原项目目录续查已完成的报告，需传入 --check-previous")
    parser.add_argument("--model", help="两遍均使用的 Codex 模型，默认沿用宿主配置")
    parser.add_argument("--effort", choices=("low", "medium", "high", "xhigh"), help="两遍相同的推理强度")
    parser.add_argument("--check-previous", type=Path, action="append", help="可重复指定历版 Markdown、文本或 JSON；独立审查完成后再逐项复验")
    args = parser.parse_args()
    dest = (args.output or args.resume).resolve()
    project = str(Path.cwd().resolve())
    common = ["--json", "--skip-git-repo-check", "-c", 'sandbox_mode="read-only"', "-c", 'approval_policy="never"']
    if args.model:
        common.extend(["--model", args.model])
    if args.effort:
        common.extend(["-c", f'model_reasoning_effort="{args.effort}"'])
    if args.output and dest.exists():
        parser.error("新审查需要尚不存在的输出目录；续查请使用 --resume")
    originals, findings = read_previous(args.check_previous or [])
    if args.resume:
        if not originals:
            parser.error("--resume 需要至少一份 --check-previous 历史报告")
        if not sys.stdin.isatty() and sys.stdin.read().strip():
            parser.error("续查不接受新任务；新任务请使用 --output 指定新目录")
        receipt = json.loads((dest / "run.json").read_text(encoding="utf-8"))
        if not isinstance(receipt, dict) or receipt.get("project") != project:
            parser.error("请从报告记录的原项目目录续查；旧报告无目录记录时可作为历史原件传入新审查")
        thread = receipt.get("thread")
        if not isinstance(thread, str) or not thread.strip():
            parser.error("报告缺少可续查的会话编号")
        check_previous(dest, originals, findings, common, thread)
        return
    prompt = sys.stdin.read().strip()
    if not prompt:
        parser.error("请通过标准输入提供审查任务")
    dest.mkdir(parents=True, exist_ok=False)
    first, second = dest / "first.md", dest / "supplement.md"
    start = time.monotonic()
    thread = run_pass(["codex", "exec", "--sandbox", "read-only", *common, "-o", str(first), "-"],
                      prompt + "\n\n" + FIRST, first)
    first_done = time.monotonic()
    run_pass(["codex", "exec", "resume", *common, "-o", str(second), thread, "-"], SECOND, second, thread)
    finished = time.monotonic()
    report = "# 审查结果\n\n".encode() + first.read_bytes()
    report += "\n\n## 补查与更正\n\n".encode() + second.read_bytes()
    (dest / "review.md").write_bytes(report)
    receipt = {"project": project, "thread": thread, "first_seconds": round(first_done - start, 3),
               "supplement_seconds": round(finished - first_done, 3)}
    (dest / "run.json").write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    if originals:
        check_previous(dest, originals, findings, common, thread)
    else:
        print(dest / "review.md")


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, ValueError) as error:
        sys.exit(str(error))
