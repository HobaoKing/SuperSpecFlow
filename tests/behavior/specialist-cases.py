"""读取专项原始项目；评估标准位于项目外，不复制给执行者。"""
from pathlib import Path


# 固定目录内 request 为用户任务，changes 为已有差异，其余文本均为原始项目材料。
def cases():
    result = {}
    for project in sorted(Path(__file__).with_name("specialist-fixtures").iterdir()):
        if not project.is_dir():
            continue
        files, dirty = {}, {}
        for path in sorted(project.rglob("*")):
            if not path.is_file() or path.name == "request.txt":
                continue
            relative = path.relative_to(project)
            target = dirty if relative.parts[0] == "changes" else files
            name = str(Path(*relative.parts[1:])) if target is dirty else str(relative)
            target[name] = path.read_text(encoding="utf-8")
        result[project.name] = {
            "request": (project / "request.txt").read_text(encoding="utf-8").strip(),
            "files": files,
            "dirty_files": {"notes.txt": "another task: keep this draft\n", **dirty},
        }
    return result
